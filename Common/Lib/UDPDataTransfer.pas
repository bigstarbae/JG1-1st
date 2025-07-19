unit UDPDataTransfer;

interface

uses
    IdUDPClient, IdUDPServer, IdSocketHandle, SysUtils, Classes, Generics.Collections,
    TypInfo, StrUtils, IdGlobal, IdStack;

type
    TDataType = (dtFile, dtRecord, dtBuffer);

    TDataReceivedEvent = procedure(Sender: TObject; DataType: TDataType; DataStream: TMemoryStream) of object;

    TUDPDataTransfer = class
    private
        mUDPClient: TIdUDPClient;
        mUDPServer: TIdUDPServer;
        mUniqueID: string;
        mChunkSize: Integer;
        mMemoryStream: TMemoryStream;
        mChunkData: TDictionary<Integer, TBytes>;
        mOnDataReceived: TDataReceivedEvent;
        mSubnetMask: string;
        mReceivedMessageIDs: TList<string>;
        mMaxMessageIDs: Integer;

        procedure OnUDPRead(AThread: TIdUDPListenerThread; AData: TBytes; ABinding: TIdSocketHandle);
        procedure ProcessReceivedData(DataType: TDataType);
        function GetActive: Boolean;
        procedure SetActive(const Value: Boolean);
        procedure ConfigureBindings;
        function GetSubnetBroadcastAddress(const AIP: string): string;
        function GenerateUniqueID: string;
    public
        constructor Create(const AUniqueID: string = ''; AChunkSize: Integer = 4096;
                          AServerPort: Integer = 5000;
                          const ASubnetMask: string = '192.168.0.';
                          AMaxMessageIDs: Integer = 100);
        destructor Destroy; override;

        procedure Broadcast(const Data: Pointer; DataSize: Integer; DataType: TDataType;
                          const FileName: string = ''); overload;
        procedure Broadcast(const Data: TBytes; DataType: TDataType;
                          const FileName: string = ''); overload;
        procedure BroadcastToSpecificSubnet(const Data: Pointer; DataSize: Integer;
                                           DataType: TDataType;
                                           const FileName: string = ''); overload;

        procedure StartServer;
        procedure StopServer;

        property Active: Boolean read GetActive write SetActive;
        property OnDataReceived: TDataReceivedEvent read mOnDataReceived write mOnDataReceived;
        property SubnetMask: string read mSubnetMask write mSubnetMask;
    end;

implementation

uses Windows;

constructor TUDPDataTransfer.Create(const AUniqueID: string; AChunkSize: Integer;
                                   AServerPort: Integer; const ASubnetMask: string;
                                   AMaxMessageIDs: Integer);
begin
    mChunkSize := AChunkSize;
    mMemoryStream := TMemoryStream.Create;
    mChunkData := TDictionary<Integer, TBytes>.Create;
    mSubnetMask := ASubnetMask;
    mReceivedMessageIDs := TList<string>.Create;
    mMaxMessageIDs := AMaxMessageIDs;

    // ���� ID ���� ����
    if AUniqueID <> '' then
        mUniqueID := AUniqueID
    else
        mUniqueID := GenerateUniqueID;

    mUDPClient := TIdUDPClient.Create(nil);
    mUDPClient.BroadcastEnabled := True;
    mUDPClient.Port := AServerPort;

    mUDPServer := TIdUDPServer.Create(nil);
    mUDPServer.DefaultPort := AServerPort;
    mUDPServer.OnUDPRead := OnUDPRead;

    ConfigureBindings;

    StartServer;
end;

function TUDPDataTransfer.GenerateUniqueID: string;
var
    Guid: TGUID;
begin
    CreateGuid(Guid);
    Result := GUIDToString(Guid);
end;

procedure TUDPDataTransfer.ConfigureBindings;
var
    Binding: TIdSocketHandle;
    LocalIPs: TStringList;
    I: Integer;
    SubnetBroadcast: string;
begin
    mUDPServer.Bindings.Clear;

    // ���� IP �ּ� ��� ��������
    LocalIPs := TStringList.Create;
    try
        GStack.AddLocalAddressesToList(LocalIPs);

        // Ư�� �뿪�� ����ũ�� ���� IP ã��
        for I := 0 to LocalIPs.Count - 1 do
        begin
            if Pos(mSubnetMask, LocalIPs[I]) = 1 then // �뿪�� ����ũ�� ��ġ�ϴ� IP
            begin
                // ����� ��ε�ĳ��Ʈ �ּ� ���
                SubnetBroadcast := GetSubnetBroadcastAddress(LocalIPs[I]);

                // ���ε� �߰�
                Binding := mUDPServer.Bindings.Add;
                Binding.IP := LocalIPs[I];
                Binding.Port := mUDPServer.DefaultPort;

                // Ư�� �뿪�뿡 ���ε��Ǿ����� �α׷� ���
                OutputDebugString(PChar(Format('Bound to IP: %s, Subnet Broadcast: %s',
                                 [LocalIPs[I], SubnetBroadcast])));
                Break; // ù ��°�� ã�� IP���� ���ε�
            end;
        end;
    finally
        LocalIPs.Free;
    end;
end;

function TUDPDataTransfer.GetSubnetBroadcastAddress(const AIP: string): string;
var
    IPParts: TStringList;
begin
    IPParts := TStringList.Create;
    try
        IPParts.Delimiter := '.';
        IPParts.DelimitedText := AIP;

        // ����� ��ε�ĳ��Ʈ �ּ� ��� (Ŭ���� C ��Ʈ��ũ ����)
        Result := Format('%s.%s.%s.255', [IPParts[0], IPParts[1], IPParts[2]]);
    finally
        IPParts.Free;
    end;
end;

destructor TUDPDataTransfer.Destroy;
begin
    StopServer;
    mUDPClient.Free;
    mUDPServer.Free;
    mMemoryStream.Free;
    mChunkData.Free;
    mReceivedMessageIDs.Free;
    inherited;
end;

function TUDPDataTransfer.GetActive: Boolean;
begin
    Result := mUDPServer.Active;
end;

procedure TUDPDataTransfer.StartServer;
begin
    if not mUDPServer.Active then
    begin
        ConfigureBindings;
        mUDPServer.Active := True;
    end;
end;

procedure TUDPDataTransfer.StopServer;
begin
    if mUDPServer.Active then
        mUDPServer.Active := False;
end;

procedure TUDPDataTransfer.Broadcast(const Data: Pointer; DataSize: Integer;
                                   DataType: TDataType; const FileName: string);
var
    Buffer: TBytes;
    DataStream: TStream;
    BytesRead, ChunkNumber: Integer;
    FullMessage: string;
    MessageID: string;
begin
    if DataType = dtFile then
        DataStream := TFileStream.Create(FileName, fmOpenRead)
    else
    begin
        DataStream := TMemoryStream.Create;
        DataStream.WriteBuffer(Data^, DataSize);
        DataStream.Position := 0;
    end;

    try
        SetLength(Buffer, mChunkSize);
        ChunkNumber := 0;
        MessageID := GenerateUniqueID;

        while DataStream.Position < DataStream.Size do
        begin
            BytesRead := DataStream.Read(Buffer[0], mChunkSize);
            FullMessage := Format('%s|%s|%d|%s|%s', [mUniqueID, GetEnumName(TypeInfo(TDataType),
                          Ord(DataType)), ChunkNumber, MessageID,
                          TEncoding.UTF8.GetString(Buffer, 0, BytesRead)]);
            mUDPClient.Broadcast(FullMessage, mUDPServer.DefaultPort);
            Inc(ChunkNumber);
            Sleep(10);  // ���� �� ���� �߰�
        end;

        // ���� �Ϸ� ǥ�� (EOF)
        FullMessage := Format('%s|%s|EOF|%s|', [mUniqueID, GetEnumName(TypeInfo(TDataType),
                      Ord(DataType)), MessageID]);
        mUDPClient.Broadcast(FullMessage, mUDPServer.DefaultPort);
    finally
        DataStream.Free;
    end;
end;

procedure TUDPDataTransfer.BroadcastToSpecificSubnet(const Data: Pointer; DataSize: Integer;
                                                    DataType: TDataType; const FileName: string);
var
    Buffer: TBytes;
    DataStream: TStream;
    BytesRead, ChunkNumber: Integer;
    FullMessage: string;
    MessageID: string;
    LocalIPs: TStringList;
    I: Integer;
    SubnetBroadcast: string;
begin
    if DataType = dtFile then
        DataStream := TFileStream.Create(FileName, fmOpenRead)
    else
    begin
        DataStream := TMemoryStream.Create;
        DataStream.WriteBuffer(Data^, DataSize);
        DataStream.Position := 0;
    end;

    try
        SetLength(Buffer, mChunkSize);
        ChunkNumber := 0;
        MessageID := GenerateUniqueID;

        // ���� IP �ּ� ��� ��������
        LocalIPs := TStringList.Create;
        try
            GStack.AddLocalAddressesToList(LocalIPs);

            // Ư�� �뿪�� ����ũ�� ���� IP ã��
            for I := 0 to LocalIPs.Count - 1 do
            begin
                if Pos(mSubnetMask, LocalIPs[I]) = 1 then // �뿪�� ����ũ�� ��ġ�ϴ� IP
                begin
                    // ����� ��ε�ĳ��Ʈ �ּ� ���
                    SubnetBroadcast := GetSubnetBroadcastAddress(LocalIPs[I]);

                    while DataStream.Position < DataStream.Size do
                    begin
                        BytesRead := DataStream.Read(Buffer[0], mChunkSize);
                        FullMessage := Format('%s|%s|%d|%s|%s', [mUniqueID,
                                      GetEnumName(TypeInfo(TDataType), Ord(DataType)),
                                      ChunkNumber, MessageID,
                                      TEncoding.UTF8.GetString(Buffer, 0, BytesRead)]);
                        mUDPClient.Send(SubnetBroadcast, mUDPServer.DefaultPort, FullMessage);
                        Inc(ChunkNumber);
                        Sleep(10);  // ���� �� ���� �߰�
                    end;

                    // ���� �Ϸ� ǥ�� (EOF)
                    FullMessage := Format('%s|%s|EOF|%s|', [mUniqueID,
                                  GetEnumName(TypeInfo(TDataType), Ord(DataType)), MessageID]);
                    mUDPClient.Send(SubnetBroadcast, mUDPServer.DefaultPort, FullMessage);
                    Break; // ù ��°�� ã�� IP���� ����
                end;
            end;
        finally
            LocalIPs.Free;
        end;
    finally
        DataStream.Free;
    end;
end;

procedure TUDPDataTransfer.Broadcast(const Data: TBytes; DataType: TDataType; const FileName: string);
begin
    Broadcast(@Data[0], Length(Data), DataType, FileName);
end;

procedure TUDPDataTransfer.SetActive(const Value: Boolean);
begin
    if Value then
        StartServer
    else
        StopServer;
end;

procedure TUDPDataTransfer.OnUDPRead(AThread: TIdUDPListenerThread; AData: TBytes; ABinding: TIdSocketHandle);
var
    ReceivedMessage, MessageID, DataTypeStr, ChunkIdentifier, MessageUniqueID, ActualData: string;
    DataType: TDataType;
    ChunkNumber: Integer;
    ChunkBytes: TBytes;
begin
    // ������ �������̽����� ���ŵ� �޽��� ����
    if ABinding.PeerIP = '127.0.0.1' then
        Exit;

    ReceivedMessage := TEncoding.UTF8.GetString(AData);

    if Pos('|', ReceivedMessage) > 0 then
    begin
        MessageID := Copy(ReceivedMessage, 1, Pos('|', ReceivedMessage) - 1);
        if MessageID <> mUniqueID then
            Exit; // ���� ���α׷� Ȯ��

        ReceivedMessage := Copy(ReceivedMessage, Pos('|', ReceivedMessage) + 1, Length(ReceivedMessage));
        DataTypeStr := Copy(ReceivedMessage, 1, Pos('|', ReceivedMessage) - 1);
        ReceivedMessage := Copy(ReceivedMessage, Pos('|', ReceivedMessage) + 1, Length(ReceivedMessage));
        ChunkIdentifier := Copy(ReceivedMessage, 1, Pos('|', ReceivedMessage) - 1);
        ReceivedMessage := Copy(ReceivedMessage, Pos('|', ReceivedMessage) + 1, Length(ReceivedMessage));
        MessageUniqueID := Copy(ReceivedMessage, 1, Pos('|', ReceivedMessage) - 1);

        // �ߺ� �޽��� ���͸�
        if mReceivedMessageIDs.Contains(MessageUniqueID) then
            Exit;

        if mReceivedMessageIDs.Count >= mMaxMessageIDs then
            mReceivedMessageIDs.Delete(0);

        mReceivedMessageIDs.Add(MessageUniqueID);

        if ChunkIdentifier <> 'EOF' then
            ActualData := Copy(ReceivedMessage, Pos('|', ReceivedMessage) + 1, Length(ReceivedMessage));

        DataType := TDataType(GetEnumValue(TypeInfo(TDataType), DataTypeStr));

        if ChunkIdentifier = 'EOF' then
        begin
            ProcessReceivedData(DataType);
            mMemoryStream.Clear;
            mChunkData.Clear;
            Exit;
        end;

        if TryStrToInt(ChunkIdentifier, ChunkNumber) then
        begin
            ChunkBytes := TEncoding.UTF8.GetBytes(ActualData);
            mChunkData.AddOrSetValue(ChunkNumber, ChunkBytes);

            // ûũ �����͸� �޸� ��Ʈ���� �߰�
            mMemoryStream.Position := mMemoryStream.Size;
            mMemoryStream.WriteBuffer(ChunkBytes[0], Length(ChunkBytes));
        end;
    end;
end;

procedure TUDPDataTransfer.ProcessReceivedData(DataType: TDataType);
begin
    if Assigned(mOnDataReceived) then
    begin
        mMemoryStream.Position := 0;  // ��Ʈ�� ��ġ�� ó������ �̵�
        mOnDataReceived(Self, DataType, mMemoryStream);
    end;

    mMemoryStream.Clear;
end;

end.

