unit UDPBroadcaster;

interface

uses
    SysUtils, Classes, IdUDPServer, IdUDPClient, IdGlobal, IdSocketHandle,
    SuperObject, Generics.Collections;

type
    TDataReceivedEvent = procedure(Sender: TObject; const JSONData: ISuperObject) of object;

    TUDPBroadcaster = class
    private
        FUDPServer: TIdUDPServer;
        FUDPClient: TIdUDPClient;
        FPort: Integer;
        FSenderID: string;
        FSubnetMask: string;  // 특정 대역대 마스크 (예: '192.168.0.')
        FOnReceiveData: TDataReceivedEvent;
        FReceivedMessageIDs: TList<string>;  // 중복 메시지 필터링용 리스트
        FMaxMessageIDs: Integer;
        procedure UDPServerRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
        function CreateJSONMessage(const AMsgType, AData: string): string;
        function GenerateUniqueID: string;
        procedure ConfigureBindings;
        function GetSubnetBroadcastAddress(const AIP: string): string;
    public
        constructor Create(APort: Integer; const ACustomID: string = ''; const ASubnetMask: string = '192.168.0.'; AMaxMessageIDs: Integer = 100);
        destructor Destroy; override;
        procedure BroadcastMessage(const AMsgType, AData: string);  // 기본 브로드캐스트
        procedure BroadcastToSpecificSubnet(const AMsgType, AData: string);  // 특정 서브넷 브로드캐스트
        property OnReceiveData: TDataReceivedEvent read FOnReceiveData write FOnReceiveData;
        property SubnetMask: string read FSubnetMask write FSubnetMask;  // 특정 대역대 마스크 속성
    end;

implementation

uses
    Dialogs, IdStack, Windows;

constructor TUDPBroadcaster.Create(APort: Integer; const ACustomID: string; const ASubnetMask: string; AMaxMessageIDs: Integer);
begin
    inherited Create;
    FPort := APort;
    FSubnetMask := ASubnetMask;  // 특정 대역대 마스크 설정
    FReceivedMessageIDs := TList<string>.Create;  // 중복 메시지 필터링용 리스트 초기화
    FMaxMessageIDs := AMaxMessageIDs;

    // 고유 ID 생성 로직
    if ACustomID <> '' then
        FSenderID := ACustomID
    else
        FSenderID := GenerateUniqueID;

    FUDPServer := TIdUDPServer.Create(nil);
    FUDPServer.DefaultPort := FPort;
    FUDPServer.OnUDPRead := UDPServerRead;

    ConfigureBindings;
    FUDPServer.Active := True;

    FUDPClient := TIdUDPClient.Create(nil);
    FUDPClient.BroadcastEnabled := True;
    FUDPClient.Port := FPort;
end;

procedure TUDPBroadcaster.ConfigureBindings;
var
    Binding: TIdSocketHandle;
    LocalIPs: TStringList;
    I: Integer;
    SubnetBroadcast: string;
begin
    FUDPServer.Bindings.Clear;

    // 로컬 IP 주소 목록 가져오기
    LocalIPs := TStringList.Create;
    try
        GStack.AddLocalAddressesToList(LocalIPs);

        // 특정 대역대 마스크를 가진 IP 찾기
        for I := 0 to LocalIPs.Count - 1 do
        begin
            if Pos(FSubnetMask, LocalIPs[I]) = 1 then  // 대역대 마스크와 일치하는 IP
            begin
                // 서브넷 브로드캐스트 주소 계산
                SubnetBroadcast := GetSubnetBroadcastAddress(LocalIPs[I]);

                // 바인딩 추가
                Binding := FUDPServer.Bindings.Add;
                Binding.IP := LocalIPs[I];
                Binding.Port := FPort;

                // 특정 대역대에 바인딩되었음을 로그로 출력
                OutputDebugString(PChar(Format('Bound to IP: %s, Subnet Broadcast: %s', [LocalIPs[I], SubnetBroadcast])));
                Break;  // 첫 번째로 찾은 IP에만 바인딩
            end;
        end;
    finally
        LocalIPs.Free;
    end;
end;

function TUDPBroadcaster.GenerateUniqueID: string;
var
    Guid: TGUID;
begin
    CreateGuid(Guid);
    Result := GUIDToString(Guid);
end;

destructor TUDPBroadcaster.Destroy;
begin
    FUDPServer.Active := False;
    FUDPServer.Free;
    FUDPClient.Free;
    FReceivedMessageIDs.Free;
    inherited;
end;

function TUDPBroadcaster.CreateJSONMessage(const AMsgType, AData: string): string;
var
    JSON: ISuperObject;
begin
    JSON := SO;
    JSON.S['messageType'] := AMsgType;
    JSON.S['sender'] := FSenderID;
    JSON.S['timestamp'] := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', Now);
    JSON.S['messageID'] := GenerateUniqueID;  // 메시지 고유 ID 추가
    JSON.O['data'] := SO(AData);
    Result := JSON.AsString;
end;

// 기본 브로드캐스트 (전체 네트워크)
procedure TUDPBroadcaster.BroadcastMessage(const AMsgType, AData: string);
var
    JSONMessage: string;
begin
    JSONMessage := CreateJSONMessage(AMsgType, AData);
    FUDPClient.Broadcast(JSONMessage, FPort);  // 기본 브로드캐스트
end;

// 특정 서브넷 브로드캐스트 (특정 대역대 마스크)
procedure TUDPBroadcaster.BroadcastToSpecificSubnet(const AMsgType, AData: string);
var
    JSONMessage: string;
    SubnetBroadcast: string;
    LocalIPs: TStringList;
    I: Integer;
begin
    JSONMessage := CreateJSONMessage(AMsgType, AData);

    // 로컬 IP 주소 목록 가져오기
    LocalIPs := TStringList.Create;
    try
        GStack.AddLocalAddressesToList(LocalIPs);

        // 특정 대역대 마스크를 가진 IP 찾기
        for I := 0 to LocalIPs.Count - 1 do
        begin
            if Pos(FSubnetMask, LocalIPs[I]) = 1 then  // 대역대 마스크와 일치하는 IP
            begin
                // 서브넷 브로드캐스트 주소 계산
                SubnetBroadcast := GetSubnetBroadcastAddress(LocalIPs[I]);

                // 특정 서브넷에 브로드캐스트 전송
                FUDPClient.Send(SubnetBroadcast, FPort, JSONMessage);
                Break;  // 첫 번째로 찾은 IP에만 전송
            end;
        end;
    finally
        LocalIPs.Free;
    end;
end;

// 서브넷 브로드캐스트 주소 계산
function TUDPBroadcaster.GetSubnetBroadcastAddress(const AIP: string): string;
var
    IPParts: TStringList;
    I: Integer;
begin
    IPParts := TStringList.Create;
    try
        IPParts.Delimiter := '.';
        IPParts.DelimitedText := AIP;

        // 서브넷 브로드캐스트 주소 계산 (클래스 C 네트워크 가정)
        Result := Format('%s.%s.%s.255', [IPParts[0], IPParts[1], IPParts[2]]);
    finally
        IPParts.Free;
    end;
end;

procedure TUDPBroadcaster.UDPServerRead(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
var
    ReceivedMessage: string;
    JSONObject: ISuperObject;
    MessageID: string;
begin
    ReceivedMessage := BytesToString(AData);
    JSONObject := SO(ReceivedMessage);

    // 루프백 인터페이스에서 수신된 메시지 무시
    if ABinding.PeerIP = '127.0.0.1' then
        Exit;

    // 메시지 고유 ID 확인
    MessageID := JSONObject.S['messageID'];

    // 중복 메시지 필터링
    if not FReceivedMessageIDs.Contains(MessageID) then
    begin

        if FReceivedMessageIDs.Count >= FMaxMessageIDs then
              FReceivedMessageIDs.Delete(0);

        FReceivedMessageIDs.Add(MessageID);  // 고유 ID 저장

        // 자신이 보낸 메시지 필터링
        if JSONObject.S['sender'] <> FSenderID then
        begin
            if Assigned(FOnReceiveData) then
                FOnReceiveData(Self, JSONObject);  // JSON 데이터 전달
        end;
    end;
end;

end.
