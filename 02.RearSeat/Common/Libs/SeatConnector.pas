{
  Ver.240828.00


  # ������ Suffix
  - XXX Pin: Ŀ���� PIN ���� (1���� ����)
  - XXX Ch: DAQ ä��(0���� ����)

  # TO DO
  - ConManager: ���� Json(SuperObject) ���
  - AssignByXXX(CanName: stirng; Con: TBaseSeatConnector) �Լ��� Con��ü �ʱ�ȭ
  . Json ������ Pin Name, �ֿ� ��� Pin ���


  Ver.241207.00
  - �ټ� ���� ����: AddCarTypePath
  - ���� �޸�(Dic) ���� ó�� �ɼ�

  Ver.250212.00
  - ĳ�� ó�� ����

  Ver.250513.00
  - Items -> Pins �Ӽ��� ����
  - Json �׸�� ����
  - ���̾ �ѹ� ���� ���� �� json ���� �߰�

}

unit SeatConnector;

interface

uses
    Classes, SysUtils, BaseDIO, BaseAD, IniFiles, SuperObject,
    Generics.Collections;

type
    TWiringNumber = record
        Number: string;
        Electrode: string;
    end;

    TWiringSet = class
    private
        mTypeID: Integer;
        mWiringNumbers: TArray<TWiringNumber>;
    public
        constructor Create;
        destructor Destroy; override;

        function Read(WiringObj: ISuperObject): Boolean;
        procedure WriteAsWiringNumber(Strings: TStrings; StartIdx: Integer = 0);

        property TypeID: Integer read mTypeID;
        property WiringNumbers: TArray<TWiringNumber> read mWiringNumbers;
    end;

    TBaseSeatConnector = class;

    PSeatPinInfo = ^TSeatPinInfo;

    TSeatPinInfo = packed record
    private
        mPinNo: Integer;
        mParentCon: TBaseSeatConnector;
    public
        mName: string;
        mRemark: string;

        function GetCurr: Double;
        function GetVolt: Double;

        function IsOn: Boolean;
        procedure OnOff(Value: Boolean);
    end;

    TSeatPinInfos = array of TSeatPinInfo;

    TSeatConnectorList = TList<TBaseSeatConnector>;

    TSpecificPinNos = TDictionary<string, TArray<Integer>>;

    TBaseSeatConnector = class
    protected
        mTypeID: Integer;
        mID, mName, mTitle: string;

        mSeatPinInfos: TSeatPinInfos;
        mSpecificPinNos: TSpecificPinNos; // Ư�� �뵵 �ɵ� ���

        mAD: TBaseAD;
        mDIO: TBaseDIO;

        mStartCurrCh: Integer; // SW Ŀ���� Pin�� ���εǴ� mAD ���� ���� CH
        mStartVoltCh: Integer; // ���ζǴ� SW Ŀ���� Pin�� ���εǴ� mAD ���� ���� CH

        mStartDOCh: Integer; // 1�� SW Ŀ���ʹ� �ؼ�, LINK���� ���� mDIO CH

        mTarVolt: Double;

        function PinToCh(PinNo: Integer): Integer; virtual; // DO Ch�� ����
        function IsValidPinNo(PinNo: Integer): Boolean; virtual;

        function FindPinByName(Name: string): Integer;

        function GetPins(PinNo: Integer): PSeatPinInfo;

    public
        constructor Create(AD: TBaseAD; StartVoltCh: Integer; DIO: TBaseDIO = nil; StartDOCh: Integer = -1); overload;
        constructor Create(AD: TBaseAD; StartCurrCh, StartVoltCh: Integer; DIO: TBaseDIO = nil; StartDOCh: Integer = -1); overload;
        destructor Destroy; override;

        procedure Clear;
        function IsEmpty: Boolean; virtual;
        function IsConnected: Boolean; virtual; // ü�� ����: Ư�� Pin On�̸�..


        function IsCurrReadable: Boolean; virtual; // ���� �б� ����?
        function IsVoltReadable: Boolean; virtual; // ���� �б� ����?

        function GetPinCurr(PinNo: Integer): Double;
        function GetPinVolt(PinNo: Integer): Double;

        function IsTarVoltPin(PinNo: Integer): Boolean;
        // TarVolt  50% �̻� ON���� ����
        function IsVoltOnPin(PinNo: Integer): Boolean;
        // Ŀ���� ������ ��ü ���� ��� ��, 2V�̻� ON���� ����
        function IsGndVolt(PinNo: Integer): Boolean;

        function IsPinOn(PinNo: Integer): Boolean;
        procedure PinSwOn(PinNo: Integer);
        procedure PinSwOff(PinNo: Integer);

        procedure SetZeroPins; virtual;
        procedure ResetZeroPins; virtual;

        procedure WriteAsPinName(Strings: TStrings; StartIdx: Integer = 0); virtual;

        function Read(ConObj: ISuperObject): Boolean; virtual;

        function PinCount: Integer;

        function GetSpecificPinNos(Name: string): TArray<Integer>;
        function GetSpecificPinNoVoltChs(Name: string): TArray<Integer>;
        function GetSpecificPinNoVolt(Name: string; PinIdx: Integer): Double;

        property TypeID: Integer read mTypeID;
        property Name: string read mName write mName;
        property ID: string read mID;
        property Title: string read mTitle write mTitle;

        property AD: TBaseAD read mAD;
        property DIO: TBaseDIO read mDIO;

        property TarVolt: Double read mTarVolt write mTarVolt; // IsTarVoltOnPin
        property Pins[PinNo: Integer]: PSeatPinInfo read GetPins; default;
    end;

    TPairPin = packed record
    public
        procedure Clear;
        function IsEmpty: Boolean;

        case Integer of
            0:
                (mPlus, mMinus: Integer);
            1:
                (mVCC, mGnd: Integer);
            2:
                (mUp, mDn: Integer);
            3:
                (mFwd, mBwd: Integer);
            4:
                (mA, mB: Integer);

            5:
                (mItems: array[0..1] of Integer);

    end;

    TLedPin = packed record
    public
        procedure Clear;

        case Integer of // ���� mMin �߰�?
            0:
                (mHi, mLo: Integer);
            1:
                (mItems: array[0..1] of Integer);
    end;

    TPwrSwPinType = (pspNone, pspRecl, pspLSupt1, pspLSupt2);

    TMainConnector = class(TBaseSeatConnector)
    private
    public
        function Read(ConObj: ISuperObject): Boolean; override;

        function IsConnected: Boolean; override; //
    end;

    TSwConnector = class(TBaseSeatConnector)
    private
        mPins: array[TPwrSwPinType] of TPairPin;

        function PinToCh(PinNo: Integer): Integer; override;

        function PinToDirCh(PinNo: Integer): Integer;
        function PinToLinkCh(PinNo: Integer): Integer;

        function FindMotorPins: Boolean;

    public
        destructor Destroy; override;

        procedure SetZeroPins; override;
        procedure ResetZeroPins; override;

        function IsEmpty: Boolean; override;
        function IsPinExists(SwPinType: TPwrSwPinType): Boolean;

        // ���� �۵� ����
        procedure SetDir(SwPinType: TPwrSwPinType; IsFwd: Boolean); // �ؼ�
        procedure ResetDir(SwPinType: TPwrSwPinType); // �ؼ� Off
        procedure SetLink(SwPinType: TPwrSwPinType; OnOff: Boolean); // LINK

        function IsAnyDirPinOn: Boolean;
        function IsAnyLinkPinOn: Boolean;

        function GetCurrCh(SwPinType: TPwrSwPinType): Integer;
        function GetCurr(SwPinType: TPwrSwPinType; IsFwd: Boolean): Double;
        function GetVolt(SwPinType: TPwrSwPinType; IsFwd: Boolean): Double;

        // --------------------------------------------
        function Read(ConObj: ISuperObject): Boolean; override;
        function IsConnected: Boolean; override; // ü�� ����: Ư�� Pin On�̸�..
    end;

    TCushMatConnector = class(TBaseSeatConnector)
    private
    public
        function Read(ConObj: ISuperObject): Boolean; override;
    end;

    TBackMatConnector = class(TBaseSeatConnector)
    private
    public
        function Read(ConObj: ISuperObject): Boolean; override;
    end;

    THeadMatConnector = class(TBaseSeatConnector)
    private
    public
        function Read(ConObj: ISuperObject): Boolean; override;
    end;

    TBlowConnector = class(TBaseSeatConnector)
    private
    public
        function Read(ConObj: ISuperObject): Boolean; override;
    end;

    TSeatConManager = class
    private
        mWiringSets: TObjectList<TWiringSet>;

        mConObj: ISuperObject; // mSOs .. ���� ���� ������ ������ �迭�� ����, json ���� ����� �̸� �������, �޸𸮿� ������ ���� Load�� ��
        mConDic: TDictionary<string, ISuperObject>; // ĳ�� ó���� ���

        mMaxCacheCount: Integer;

        mCurCarTypeName: string;
        mCarTypePathList: TStringList;

        function FindWiringSetByType(TypeID: Integer): TWiringSet;
        function FindConObjectByID(ID: string): ISuperObject;
        function FindConObjectByName(Name: string; PartialMatch: Boolean = True): ISuperObject;

        function _AssignByID(ID: string; Connector: TBaseSeatConnector): Boolean;
        function _AssignByTypeID(TypeID, ConIdx: Integer; Connector: TBaseSeatConnector): Boolean; // ���� TypeID�� Connector�� �ټ��� ��� ConIdx�� �Ҵ�, ConIdx�� json�� ��� ����(Order)
        function _AssignByName(Name: string; Connector: TBaseSeatConnector): Boolean;

        function Add(CarTypeName: string; ConObj: ISuperObject): Boolean;

    public
        constructor Create;
        destructor Destroy; override;

        function AssignByID(ID: string; Connector: TBaseSeatConnector): Boolean;
        function AssignByName(Name: string; Connector: TBaseSeatConnector): Boolean;
        function AssignByNames(const Names: array of string; const Connectors: array of TBaseSeatConnector): Boolean;

        function LoadWiringSets: Boolean;
        function GetWiringSetByType(TypeID: Integer): TWiringSet;

        function Load(FilePath: string): Boolean;
        function LoadByCarType(CarTypeName: string): Boolean;
        function AddCarTypePath(CarTypeName, Path: string; IsLoad: Boolean): Boolean;
        function AddCarTypePaths(CarTypeNames, Paths: array of string; IsLoad: Boolean): Boolean;


        // function CreateConnector(TypeID: Integer): TBaseSeatConnector; // Factory?

        property CurCarType: string read mCurCarTypeName;
        property MaxCacheCount: Integer read mMaxCacheCount write mMaxCacheCount;
    end;

var
    gConMan: TSeatConManager;

implementation

uses
    Log, Math, AsyncCalls, TypInfo;

function ObjectHasKey(const Obj: ISuperObject; const Key: string): Boolean;
var
    Dummy: ISuperObject;
begin
    Result := Obj.AsObject.Find(Key, Dummy);
end;

{ TBaseSeatConnector }

constructor TBaseSeatConnector.Create(AD: TBaseAD; StartVoltCh: Integer; DIO: TBaseDIO; StartDOCh: Integer);
begin
    Create(AD, -1, StartVoltCh, DIO, StartDOCh);
end;

procedure TBaseSeatConnector.Clear;
begin
    mID := '';
    mName := '';
    mTypeID := 0;
    mSeatPinInfos := nil;
end;

constructor TBaseSeatConnector.Create(AD: TBaseAD; StartCurrCh, StartVoltCh: Integer; DIO: TBaseDIO; StartDOCh: Integer);
begin
    mSpecificPinNos := TSpecificPinNos.Create;

    mTarVolt := 13.5;

    mAD := AD;
    mStartCurrCh := StartCurrCh;
    mStartVoltCh := StartVoltCh;

    if DIO = nil then
        Exit;

    mDIO := DIO;
    mStartDOCh := StartDOCh;

end;

destructor TBaseSeatConnector.Destroy;
var
    i: Integer;
begin
    mSeatPinInfos := nil;

    if Assigned(mDIO) then
    begin
        for i := 1 to PinCount do
            mDIO.SetIO(PinToCh(i), False);
    end;

    mSpecificPinNos.Free;

    inherited;
end;

function TBaseSeatConnector.FindPinByName(Name: string): Integer;
var
    i: Integer;
begin
    Result := 0;
    for i := 0 to PinCount - 1 do
    begin
        if Pos(Name, mSeatPinInfos[i].mName) > 0 then
            Exit(i + 1);
    end;

end;

function TBaseSeatConnector.GetPins(PinNo: Integer): PSeatPinInfo;
begin
    Result := nil;

    if IsValidPinNo(PinNo) then
        Result := @mSeatPinInfos[PinNo - 1]
    else
        raise Exception.CreateFmt('PinNo "%d" not found in the TBaseSeatConnector.GetPins().', [PinNo]);
end;

function TBaseSeatConnector.GetPinCurr(PinNo: Integer): Double;
begin
    if IsEmpty or (mStartCurrCh <= 0) then
        Exit(0);

    if IsValidPinNo(PinNo) then
        Result := mAD.GetValue(mStartCurrCh + PinNo - 1)
    else
        gLog.Error('GetPinCurr: ����PinNo(%d)�� ����(1~%d)�� ������ϴ�', [PinNo, PinCount]);
end;

function TBaseSeatConnector.GetPinVolt(PinNo: Integer): Double;
begin
    if IsEmpty or (mStartVoltCh < 0) then
        Exit(0);

    if IsValidPinNo(PinNo) then
        Result := mAD.GetValue(mStartVoltCh + PinNo - 1)
    else
        gLog.Error('GetPinVolt: ����PinNo(%d)�� ����(1~%d)�� ������ϴ�', [PinNo, PinCount]);
end;

function TBaseSeatConnector.GetSpecificPinNoVolt(Name: string; PinIdx: Integer): Double;
begin
    Result := GetPinVolt(GetSpecificPinNos(Name)[PinIdx]);
end;

function TBaseSeatConnector.GetSpecificPinNoVoltChs(Name: string): TArray<Integer>;
var
    i: Integer;
begin
    Result := GetSpecificPinNos(Name);

    for i := 0 to Length(Result) - 1 do
        Result[i] := mStartVoltCh + Result[i] - 1;

end;

function TBaseSeatConnector.GetSpecificPinNos(Name: string): TArray<Integer>;
begin
    if mSpecificPinNos.Count = 0 then
    begin
        SetLength(Result, 0);
        Exit;
    end;

    if mSpecificPinNos.TryGetValue(Name, Result) then
        Exit
    else
        raise Exception.CreateFmt('Name "%s" not found in the GetSpecificPinNos().', [Name]);

end;

function TBaseSeatConnector.IsConnected: Boolean;
var
    i: Integer;
begin
    Result := False;

    for i := 1 to PinCount do
    begin
        if not IsVoltOnPin(i) then
            Exit;
    end;

    Result := True;
end;

function TBaseSeatConnector.IsCurrReadable: Boolean;
begin
    Result := mStartCurrCh >= 0;
end;

function TBaseSeatConnector.IsEmpty: Boolean;
begin
    Result := PinCount = 0;
end;

function TBaseSeatConnector.IsGndVolt(PinNo: Integer): Boolean;
begin
    Result := (GetPinVolt(PinNo) > -0.5) or (GetPinVolt(PinNo) < 0.5);

end;

function TBaseSeatConnector.IsPinOn(PinNo: Integer): Boolean;
begin
    if IsValidPinNo(PinNo) then
        Result := mDIO.IsIO(PinToCh(PinNo))
    else
        gLog.Error('IsPinOn: ����PinNo(%d)�� ����(1~%d)�� ������ϴ�', [PinNo, PinCount]);

end;

function TBaseSeatConnector.IsTarVoltPin(PinNo: Integer): Boolean;
begin
    Result := (mTarVolt * 0.5) <= GetPinVolt(PinNo);

    // gLog.Debug('%s(%d): %f <= %f', [BoolToStr(Result, True), PinNo, (mTarVolt * 0.5), GetPinVolt(PinNo)]);
end;

function TBaseSeatConnector.IsValidPinNo(PinNo: Integer): Boolean;
begin
    Result := PinNo in [1..PinCount];
end;

function TBaseSeatConnector.IsVoltOnPin(PinNo: Integer): Boolean;
begin
    Result := GetPinVolt(PinNo) >= 2.0;
end;

function TBaseSeatConnector.IsVoltReadable: Boolean;
begin
    Result := mStartVoltCh >= 0;
end;

function TBaseSeatConnector.PinCount: Integer;
begin
    Result := Length(mSeatPinInfos);
end;

procedure TBaseSeatConnector.PinSwOff(PinNo: Integer);
begin
    if IsValidPinNo(PinNo) then
        mDIO.SetIO(PinToCh(PinNo), False)
    else
        gLog.Error('PinSwOff: ����PinNo(%d)�� ����(1~%d)�� ������ϴ�', [PinNo, PinCount]);

end;

procedure TBaseSeatConnector.PinSwOn(PinNo: Integer);
begin
    if IsValidPinNo(PinNo) then
        mDIO.SetIO(PinToCh(PinNo), True)
    else
        gLog.Error('PinSwOn: ����PinNo(%d)�� ����(1~%d)�� ������ϴ�', [PinNo, PinCount]);

end;

function TBaseSeatConnector.PinToCh(PinNo: Integer): Integer;
begin
    if IsValidPinNo(PinNo) then
        Result := mStartDOCh + (PinNo - 1)
    else
        gLog.Error('PinToCh: ����PinNo(%d)�� ����(1~%d)�� ������ϴ�', [PinNo, PinCount]);
end;

function TBaseSeatConnector.Read(ConObj: ISuperObject): Boolean;
var
    TypeID, i, Count: Integer;
    PinNames: TSuperArray;
    Iter: TSuperObjectIter;
    Pins: TArray<Integer>;
begin
    Result := True;
    try
        TypeID := ConObj.i['TYPE'];

        mTypeID := TypeID;
        mID := ConObj.S['ID'];
        mName := ConObj.S['CONNECTOR_NAME'];
        PinNames := ConObj.A['PIN_NAMES'];
        Count := Max(0, PinNames.Length);
        SetLength(mSeatPinInfos, Count);

        for i := 0 to Count - 1 do
        begin
            mSeatPinInfos[i].mName := PinNames[i].AsString;
            mSeatPinInfos[i].mPinNo := i + 1;
            mSeatPinInfos[i].mParentCon := Self;
        end;

        // �ΰ� �� ���� ó�� -----------------------------------------
        mSpecificPinNos.Clear;

        if ObjectFindFirst(ConObj, Iter) then
        begin
            try
                repeat

                    if (Iter.Key = 'PIN_NAMES') or (Iter.Key = 'TYPE') then
                        continue;

                    if Iter.Val.IsType(stArray) then
                    begin
                        if Iter.Val.AsArray.Length = 0 then
                            continue;

                        SetLength(Pins, Iter.Val.AsArray.Length);
                        for i := 0 to Iter.Val.AsArray.Length - 1 do
                            Pins[i] := Iter.Val.AsArray[i].AsInteger;
                    end
                    else if Iter.Val.IsType(stInt) then
                    begin
                        SetLength(Pins, 1);
                        Pins[0] := Iter.Val.AsInteger;
                    end
                    else
                        continue;

                    // gLog.Panel(Format('Key: %s, Value: %s', [Iter.key, Iter.Val.AsString]));
                    mSpecificPinNos.Add(Iter.Key, Pins);

                until not ObjectFindNext(Iter);
            finally
                ObjectFindClose(Iter);
            end;
        end

    except
        Result := False;
    end;
end;

procedure TBaseSeatConnector.ResetZeroPins;
begin
    gLog.Debug('ResetZeroPins ���� �� ��', []);
end;

procedure TBaseSeatConnector.SetZeroPins;
begin
    gLog.Debug('SetZeroPins ���� �� ��', []);
end;

procedure TBaseSeatConnector.WriteAsPinName(Strings: TStrings; StartIdx: Integer);
var
    i: Integer;
begin
    for i := 0 to PinCount - 1 do
    begin
        Strings.Strings[StartIdx + i] := mSeatPinInfos[i].mName;
    end;

end;

    { TSwConnector }

destructor TSwConnector.Destroy;
begin

    inherited;
end;

function TSwConnector.FindMotorPins: Boolean;
begin
    mPins[pspRecl].mFwd := FindPinByName('RECL FWD');
    mPins[pspRecl].mBwd := FindPinByName('RECL BWD');

    mPins[pspLSupt1].mFwd := FindPinByName('LSUPT FWD');
    mPins[pspLSupt1].mBwd := FindPinByName('LSUPT BWD');

    mPins[pspLSupt2].mUp := FindPinByName('BOLSTER UP');
    mPins[pspLSupt2].mDn := FindPinByName('BOLSTER DN');

    Result := not IsEmpty;
end;

function TSwConnector.GetCurr(SwPinType: TPwrSwPinType; IsFwd: Boolean): Double;
begin
    if IsFwd then
    begin
        Result := GetPinCurr(mPins[SwPinType].mFwd);
            // gLog.Panel('%s ���� ����:%f', [GetEnumName(TypeInfo(TPwrSwPinType), Ord(SwPinType)), Result], 200);
    end
    else
    begin
        Result := GetPinCurr(mPins[SwPinType].mBwd);
            // gLog.Panel('%s ���� ����:%f', [GetEnumName(TypeInfo(TPwrSwPinType), Ord(SwPinType)), Result], 200);
    end;
end;

function TSwConnector.GetCurrCh(SwPinType: TPwrSwPinType): Integer;
begin
    Result := mStartCurrCh + mPins[SwPinType].mFwd - 1;
end;

function TSwConnector.GetVolt(SwPinType: TPwrSwPinType; IsFwd: Boolean): Double;
begin
    if IsFwd then
        Result := GetPinVolt(mPins[SwPinType].mFwd)
    else
        Result := GetPinVolt(mPins[SwPinType].mBwd);
end;

function TSwConnector.IsAnyDirPinOn: Boolean;
var
    It: TPwrSwPinType;
begin
    Result := False;
    for It := Low(TPwrSwPinType) to High(TPwrSwPinType) do
    begin
        if mPins[It].IsEmpty then
            continue;

        if mDIO.IsIO(PinToDirCh(mPins[It].mFwd)) then
            Exit(True);
        if mDIO.IsIO(PinToDirCh(mPins[It].mBwd)) then
            Exit(True);

    end;
end;

function TSwConnector.IsAnyLinkPinOn: Boolean;
var
    It: TPwrSwPinType;
begin
    Result := False;
    for It := Low(TPwrSwPinType) to High(TPwrSwPinType) do
    begin
        if mPins[It].IsEmpty then
            continue;

        if mDIO.IsIO(PinToLinkCh(mPins[It].mFwd)) then
            Exit(True);
        if mDIO.IsIO(PinToLinkCh(mPins[It].mBwd)) then
            Exit(True);

    end;

end;

function TSwConnector.IsConnected: Boolean;
begin
    if mSpecificPinNos.Count = 0 then
        Exit(False);

    Result := IsTarVoltPin(GetSpecificPinNos('PWR_PLUS_PINS')[0]);
end;

function TSwConnector.IsEmpty: Boolean;
begin
    Result := (mPins[pspRecl].mFwd = 0);
end;

function TSwConnector.IsPinExists(SwPinType: TPwrSwPinType): Boolean;
begin
    Result := not mPins[SwPinType].IsEmpty;
end;


function TSwConnector.PinToCh(PinNo: Integer): Integer;
begin
    raise Exception.Create('TSwConnector.PinToCh ��� �� ��');
    Result := 0;

        // Result := inherited PinToCh(PinNo);
end;

function TSwConnector.PinToDirCh(PinNo: Integer): Integer;
begin
    Result := mStartDOCh + (PinNo - 1) * 2;
end;

function TSwConnector.PinToLinkCh(PinNo: Integer): Integer;
begin
    Result := mStartDOCh + (PinNo - 1) * 2 + 1
end;

function TSwConnector.Read(ConObj: ISuperObject): Boolean;
begin
    Result := inherited Read(ConObj);

    mTitle := 'SwCon';

    if not Result then
        Exit;
end;

procedure TSwConnector.SetDir(SwPinType: TPwrSwPinType; IsFwd: Boolean);
begin
    if not Assigned(mDIO) then
        Exit;

    mDIO.SetIO(PinToDirCh(mPins[SwPinType].mFwd), IsFwd);
    mDIO.SetIO(PinToDirCh(mPins[SwPinType].mBwd), not IsFwd);
end;

procedure TSwConnector.ResetDir(SwPinType: TPwrSwPinType);
begin
    if not Assigned(mDIO) then
        Exit;

    mDIO.SetIO(PinToDirCh(mPins[SwPinType].mFwd), False);
    mDIO.SetIO(PinToDirCh(mPins[SwPinType].mBwd), False);
end;

procedure TSwConnector.ResetZeroPins;
var
    It: TPwrSwPinType;
begin
    for It := Low(TPwrSwPinType) to High(TPwrSwPinType) do
    begin
        if mPins[It].IsEmpty then
            continue;
        mAD.ResetZero(GetCurrCh(It));
    end;
end;

procedure TSwConnector.SetLink(SwPinType: TPwrSwPinType; OnOff: Boolean);
begin
    if not Assigned(mDIO) then
        Exit;

    if mDIO.IsIO(PinToDirCh(mPins[SwPinType].mFwd)) then // ���� �� �ؼ��� ��ũ ON�� ���  ��ؿ� + �ɷ��� �����ؾ� �Ѵٰ� ��, OFF�� ��������� �ڵ�� �̴�� ����
    begin
        mDIO.SetIO(PinToLinkCh(mPins[SwPinType].mBwd), OnOff);
        mDIO.SetIO(PinToLinkCh(mPins[SwPinType].mFwd), OnOff);

    end
    else
    begin
        mDIO.SetIO(PinToLinkCh(mPins[SwPinType].mFwd), OnOff);
        mDIO.SetIO(PinToLinkCh(mPins[SwPinType].mBwd), OnOff);
    end;

end;

procedure TSwConnector.SetZeroPins;
var
    It: TPwrSwPinType;
begin
    for It := Low(TPwrSwPinType) to High(TPwrSwPinType) do
    begin
        if mPins[It].IsEmpty then
            continue;
        mAD.SetZero(GetCurrCh(It));
    end;

end;

    { TSeatConManager }

function TSeatConManager.AddCarTypePath(CarTypeName, Path: string; IsLoad: Boolean): Boolean;
var
    ConObj: ISuperObject;
begin
    Result := True;

    mCarTypePathList.Add(CarTypeName + '=' + Path);

    if IsLoad then
    begin
        try
            ConObj := TSuperObject.ParseFile(Path, True);
        except
            Exit(False);
        end;

        Add(CarTypeName, ConObj);
    end;
end;

function TSeatConManager.AddCarTypePaths(CarTypeNames, Paths: array of string; IsLoad: Boolean): Boolean;
var
    i: Integer;
begin
    Result := True;

    if Length(CarTypeNames) <> Length(Paths) then
    begin
        gLog.Error('AddCarTypePaths: CarTypeNames�� Paths�� ���� ����ġ', []);
        Exit(False);
    end;

    for i := 0 to Length(CarTypeNames) - 1 do
    begin
        if not AddCarTypePath(CarTypeNames[i], Paths[i], IsLoad) then
            Result := False;
    end;

end;

function TSeatConManager._AssignByID(ID: string; Connector: TBaseSeatConnector): Boolean;
var
    ConObj: ISuperObject;
begin
    Result := False;

    ConObj := FindConObjectByID(ID);
    if ConObj = nil then
        Exit;

    Result := Connector.Read(ConObj);

end;

function TSeatConManager._AssignByName(Name: string; Connector: TBaseSeatConnector): Boolean;
var
    ConObj: ISuperObject;
begin
    Result := False;

    ConObj := FindConObjectByName(Name, True);

    if ConObj = nil then
        Exit;

    Result := Connector.Read(ConObj);
end;

function TSeatConManager._AssignByTypeID(TypeID, ConIdx: Integer; Connector: TBaseSeatConnector): Boolean;
var
    ConTypes, Iter: ISuperObject;
    CurIdx: Integer;
begin
    Result := False;

    ConTypes := mConObj.O['TYPES'];

    if ConTypes = nil then
        Exit;

    CurIdx := 0;
    for Iter in ConTypes do
    begin
        if (TypeID = Iter.i['TYPE']) then
        begin
            if ConIdx = CurIdx then
            begin
                Connector.Read(Iter);
                Exit(True)
            end
            else
                Inc(CurIdx);
        end;

    end;

end;

function TSeatConManager.AssignByID(ID: string; Connector: TBaseSeatConnector): Boolean;
var
    i: Integer;
    ConObj: ISuperObject;
begin
    Result := False;

    for ConObj in mConDic.Values do
    begin
        mConObj := ConObj;
        if _AssignByID(ID, Connector) then
            Exit(True);
    end;

    for i := 0 to mCarTypePathList.Count - 1 do
    begin
        if LoadByCarType(mCarTypePathList.Names[i]) then
        begin
            if _AssignByID(ID, Connector) then
                Exit(True);
        end;
    end;

end;

function TSeatConManager.AssignByName(Name: string; Connector: TBaseSeatConnector): Boolean;
var
    ConObj: ISuperObject;
begin
    Result := False;

    for ConObj in mConDic.Values do
    begin
        mConObj := ConObj;
        if _AssignByName(Name, Connector) then
            Exit(True);
    end;
end;

constructor TSeatConManager.Create;
begin
    mWiringSets := TObjectList<TWiringSet>.Create(True); // True: ��ü �ڵ� ����

    mCarTypePathList := TStringList.Create;
    mConDic := TDictionary<string, ISuperObject>.Create;

    mMaxCacheCount := 3;
end;

destructor TSeatConManager.Destroy;
begin
    mWiringSets.Free;
    mCarTypePathList.Free;
    mConDic.Free;
    inherited;
end;

function TSeatConManager.FindWiringSetByType(TypeID: Integer): TWiringSet;
var
    i: Integer;
begin
    Result := nil;

    for i := 0 to mWiringSets.Count - 1 do
    begin
        if mWiringSets[i].TypeID = TypeID then
        begin
            Result := mWiringSets[i];
            Break;
        end;
    end;
end;

function TSeatConManager.GetWiringSetByType(TypeID: Integer): TWiringSet;
begin
    Result := FindWiringSetByType(TypeID);
end;

function TSeatConManager.LoadWiringSets: Boolean;
var
    WiringSets: TSuperArray;
    WiringObj: ISuperObject;
    WiringSet: TWiringSet;
    i: Integer;
begin
    Result := False;

    if mConObj = nil then
        Exit;

        // ���� ���̾ ��Ʈ �ʱ�ȭ
    mWiringSets.Clear;

        // WIRING_SETS �迭 ��������
    if not ObjectHasKey(mConObj, 'WIRING_SETS') then
        Exit;

    WiringSets := mConObj.A['WIRING_SETS'];
    if WiringSets = nil then
        Exit;

        // �� ���̾ ��Ʈ �б�
    for i := 0 to WiringSets.Length - 1 do
    begin
        WiringObj := WiringSets[i];
        WiringSet := TWiringSet.Create;

        if WiringSet.Read(WiringObj) then
            mWiringSets.Add(WiringSet)
        else
            WiringSet.Free; // �б� ���� �� ��ü ����
    end;

    Result := (mWiringSets.Count > 0);
end;

function TSeatConManager.FindConObjectByID(ID: string): ISuperObject;
var
    Connectors: TSuperArray;
    Iter: ISuperObject;
    i: Integer;
    NormalizedName: string;
begin
    Result := nil;
    Connectors := mConObj.A['CONNECTORS'];

    if Connectors = nil then
        Exit;

        // �˻��� ID ����ȭ (���� ����, �빮�� ��ȯ)
    NormalizedName := StringReplace(UpperCase(ID), ' ', '', [rfReplaceAll]);

    for i := 0 to Connectors.Length - 1 do
    begin
        Iter := Connectors[i];
        if Pos(NormalizedName, UpperCase(Iter.S['ID'])) > 0 then
            Exit(Iter);
    end;
end;

function TSeatConManager.FindConObjectByName(Name: string; PartialMatch: Boolean): ISuperObject;
var
    Connectors: TSuperArray;
    Iter: ISuperObject;
    i: Integer;
    NormalizedName1, NormalizedName2: string;
begin
    Result := nil;
    Connectors := mConObj.A['CONNECTORS'];

    if Connectors = nil then
        Exit;

        // �˻��� �̸� ����ȭ (���� ����, �빮�� ��ȯ)
    NormalizedName1 := StringReplace(UpperCase(Name), ' ', '', [rfReplaceAll]);

    for i := 0 to Connectors.Length - 1 do
    begin
        Iter := Connectors[i];

        if not ObjectHasKey(Iter, 'CONNECTOR_NAME') then
            continue;

            // Ŀ���� �̸� ����ȭ
        NormalizedName2 := StringReplace(UpperCase(Iter.S['CONNECTOR_NAME']), ' ', '', [rfReplaceAll]);

            // ��Ī ��Ŀ� ���� �˻�
        if PartialMatch then
        begin
                // �κ� ���ڿ� �˻� (�����)
            if (Pos(NormalizedName1, NormalizedName2) > 0) or (Pos(NormalizedName2, NormalizedName1) > 0) then
                Exit(Iter);
        end
        else
        begin
                // ��Ȯ�� ��ġ �˻�
            if NormalizedName1 = NormalizedName2 then
                Exit(Iter);
        end;
    end;
end;

function TSeatConManager.Add(CarTypeName: string; ConObj: ISuperObject): Boolean;
var
    Key, FirstKey: string;
begin
    Result := False;

    if mConDic.Count > mMaxCacheCount then
    begin

        for Key in mConDic.Keys do
        begin
            FirstKey := Key;
            Break;
        end;

        mConDic.Remove(FirstKey);
    end;

    if not mConDic.ContainsKey(CarTypeName) then
    begin
        mConDic.Add(CarTypeName, ConObj);
        Result := True;
    end;
end;

function TSeatConManager.Load(FilePath: string): Boolean;
begin
    Result := False;

    try
        mConObj := TSuperObject.ParseFile(FilePath, True);
    except
        Exit;
    end;

    mCurCarTypeName := mConObj.S['CAR'];
    Result := mConObj <> nil;

    if Result then
    begin
        Add(mCurCarTypeName, mConObj);

        LoadWiringSets;
    end;
end;

function TSeatConManager.LoadByCarType(CarTypeName: string): Boolean;
begin
    if mConDic.ContainsKey(CarTypeName) then
    begin
        mConObj := mConDic[CarTypeName];
        mCurCarTypeName := mConObj.S['CAR'];
        Exit(True);
    end;

    Result := Load(mCarTypePathList.Values[CarTypeName]);

end;

function TSeatConManager.AssignByNames(const Names: array of string; const Connectors: array of TBaseSeatConnector): Boolean;
var
    i, j: Integer;
    FoundMatch: Boolean;
    ConObj: ISuperObject;
begin
    Result := True;

        // �迭 ���� Ȯ��
    if Length(Names) <> Length(Connectors) then
    begin
        gLog.Error('AssignByNames: Names�� Connectors �迭 ���̰� ��ġ���� �ʽ��ϴ�', []);
        Exit(False);
    end;

        // �� �̸��� ���� Ŀ���� �Ҵ� �õ�
    for i := 0 to Length(Names) - 1 do
    begin
        FoundMatch := False;

            // ĳ�õ� ��� �������� �˻�
        for ConObj in mConDic.Values do
        begin
            mConObj := ConObj;
            if _AssignByName(Names[i], Connectors[i]) then
            begin
                FoundMatch := True;
                gLog.Debug('Ŀ���� �Ҵ� ����: %s', [Names[i]]);
                Break;
            end;
        end;

            // ĳ�ÿ��� ã�� ���� ��� ��� ���Ͽ��� �˻�
        if not FoundMatch then
        begin
            for j := 0 to mCarTypePathList.Count - 1 do
            begin
                if LoadByCarType(mCarTypePathList.Names[j]) then
                begin
                    if _AssignByName(Names[i], Connectors[i]) then
                    begin
                        FoundMatch := True;
                        gLog.Debug('Ŀ���� �Ҵ� ����: %s', [Names[i]]);
                        Break;
                    end;
                end;
            end;
        end;

            // ��Ī ���� �� ��� ������Ʈ
        if not FoundMatch then
        begin
            gLog.Error('Ŀ���� �Ҵ� ����: %s�� �ش��ϴ� Ŀ���͸� ã�� �� �����ϴ�', [Names[i]]);
            Result := False;
        end;
    end;
end;

    { TPairPin }

procedure TPairPin.Clear;
var
    i: Integer;
begin
    for i := 0 to Length(mItems) - 1 do
        mItems[i] := 0;
end;

function TPairPin.IsEmpty: Boolean;
begin
    Result := (mFwd = 0) or (mBwd = 0);
end;

    { TLedPin }

procedure TLedPin.Clear;
var
    i: Integer;
begin
    for i := 0 to Length(mItems) - 1 do
        mItems[i] := 0;
end;

    { TSeatPinInfo }

function TSeatPinInfo.GetCurr: Double;
begin
    Result := mParentCon.GetPinCurr(mPinNo);
end;

function TSeatPinInfo.GetVolt: Double;
begin
    Result := mParentCon.GetPinVolt(mPinNo);
end;

function TSeatPinInfo.IsOn: Boolean;
begin
    Result := mParentCon.IsPinOn(mPinNo);
end;

procedure TSeatPinInfo.OnOff(Value: Boolean);
begin
    if Value then
        mParentCon.PinSwOn(mPinNo)
    else
        mParentCon.PinSwOff(mPinNo);
end;

    { TWiringSet }

constructor TWiringSet.Create;
begin
    inherited;
    mTypeID := 0;
    SetLength(mWiringNumbers, 0);
end;

destructor TWiringSet.Destroy;
begin
    SetLength(mWiringNumbers, 0);
    inherited;
end;

function TWiringSet.Read(WiringObj: ISuperObject): Boolean;
var
    Numbers: TSuperArray;
    i, Count: Integer;
begin
    Result := False;

    if WiringObj = nil then
        Exit;

    try
            // TYPE �б�

        if ObjectHasKey(WiringObj, 'TYPE') then
            mTypeID := WiringObj.i['TYPE']
        else
            Exit;

            // WIRING_NUMBERS �迭 �б�
        if not ObjectHasKey(WiringObj, 'WIRING_NUMBERS') then
            Exit;

        Numbers := WiringObj.A['WIRING_NUMBERS'];
        Count := Numbers.Length;

        if Count <= 0 then
            Exit;

        SetLength(mWiringNumbers, Count);

        for i := 0 to Count - 1 do
        begin
                // ���� �빮�� Ű�� ��� (NUMBER, ELECTRODE)
            if ObjectHasKey(Numbers[i], 'NUMBER') then
                mWiringNumbers[i].Number := Numbers[i].S['NUMBER']
            else if ObjectHasKey(Numbers[i], '�ѹ���') then // �ѱ� Ű ����
                mWiringNumbers[i].Number := Numbers[i].S['�ѹ���'];

            if ObjectHasKey(Numbers[i], 'ELECTRODE') then
                mWiringNumbers[i].Electrode := Numbers[i].S['ELECTRODE']
            else if ObjectHasKey(Numbers[i], '����') then // �ѱ� Ű ����
                mWiringNumbers[i].Electrode := Numbers[i].S['����'];
        end;
        Result := True;
    except
        on E: Exception do
        begin
                // ���� ó�� (�α� ��)
            SetLength(mWiringNumbers, 0);
            Result := False;
        end;
    end;
end;

procedure TWiringSet.WriteAsWiringNumber(Strings: TStrings; StartIdx: Integer);
var
    i: Integer;
begin
    if Length(mWiringNumbers) = 0 then
        Exit;

    for i := 0 to Length(mWiringNumbers) - 1 do
    begin
        if StartIdx + i < Strings.Count then
        begin
            if mWiringNumbers[i].Electrode <> '' then
                Strings.Strings[StartIdx + i] := Format('%s (%s)', [mWiringNumbers[i].Number, mWiringNumbers[i].Electrode])
            else
                Strings.Strings[StartIdx + i] := mWiringNumbers[i].Number;
        end
        else
        begin
            if mWiringNumbers[i].Electrode <> '' then
                Strings.Add(Format('%s (%s)', [mWiringNumbers[i].Number, mWiringNumbers[i].Electrode]))
            else
                Strings.Add(mWiringNumbers[i].Number);
        end;
    end;
end;

    { TMainConnector }

function TMainConnector.IsConnected: Boolean;
begin

end;

function TMainConnector.Read(ConObj: ISuperObject): Boolean;
var
    i: Integer;
    SOArray: TSuperArray;
begin
    Result := inherited Read(ConObj);

    if not Result then
        Exit;

end;

    { TBackMatConnector }

function TBackMatConnector.Read(ConObj: ISuperObject): Boolean;
var
    i: Integer;
    SOArray: TSuperArray;
begin
    Result := inherited Read(ConObj);

    if Result then
        Exit;
end;


{ TBlowConnector }
function TBlowConnector.Read(ConObj: ISuperObject): Boolean;
var
    i: Integer;
    SOArray: TSuperArray;
begin
    Result := inherited Read(ConObj);

    if Result then
        Exit;
end;

{ TCushMatConnector }

function TCushMatConnector.Read(ConObj: ISuperObject): Boolean;
var
    i: Integer;
    SOArray: TSuperArray;
begin
    Result := inherited Read(ConObj);

    if Result then
        Exit;
end;

{ THeadMatConnector }

function THeadMatConnector.Read(ConObj: ISuperObject): Boolean;
var
    i: Integer;
    SOArray: TSuperArray;
begin
    Result := inherited Read(ConObj);

    if Result then
        Exit;
end;

initialization
    gConMan := TSeatConManager.Create;


finalization
    if Assigned(gConMan) then
        gConMan.Free;

end.

