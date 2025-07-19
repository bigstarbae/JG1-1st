unit HVDIOCtrler;

interface

uses
    HVTester, BaseDIO, BaseAD;


type

    THVDIOCtrler = class(TBaseHVCtrler)
    private
        mDIO: TBaseDIO;

        mDOSw,
        mDILed1, mDILed2: integer;
        function GetIOFromAI(aAiCh: integer): boolean;

    public
        constructor Create(DIO: TBaseDIO; AD: TBaseAD); overload;
        constructor Create(DIO: TBaseDIO; DOSw, DILed2, DILed1: integer; AD: TBaseAD; AICurr: integer; AutoFree: boolean = false); overload;
        destructor Destroy; override;

        procedure Init(DOSw, DILed2, DILed1, AICurr: integer);

        // Base
        function SwOn(CurStep: integer): boolean; override;
        function SwOff(CurStep: integer): boolean; override;
        function GetLedData: BYTE; override;

        function GetDOSwVal: boolean; override;   // 그래프용
        function GetStateStr: string; override;

    end;


implementation

uses
    Log, SysUtils;

{ THVDIOCtrler }

constructor THVDIOCtrler.Create(DIO: TBaseDIO; DOSw, DILed2, DILed1: integer; AD: TBaseAD; AICurr: integer; AutoFree: boolean);
begin

    mDIO := DIO;
    mAD := AD;

    Init(DOSw, DILed2, DILed1, AICurr);
end;

constructor THVDIOCtrler.Create(DIO: TBaseDIO; AD: TBaseAD);
begin

    mDIO := DIO;
    mAD := AD;

end;

destructor THVDIOCtrler.Destroy;
begin

  inherited;
end;

procedure THVDIOCtrler.Init(DOSw, DILed2, DILed1, AICurr: integer);
begin

    mDOSw := DOSw;
    mDILed2 := DILed2;
    mDILed1 := DILed1;

    mAICurrCh := AICurr;
end;



function THVDIOCtrler.GetDOSwVal: boolean;
begin
    Result := mDIO.IsIO(mDOSw);
end;

function THVDIOCtrler.SwOn(CurStep: integer): boolean;
begin

    mDIO.SetIO(mDOSw, true);
    //gLog.Panel('%s: %d단 SW(%d) ON', [mHVTest.Name, mHVTest.CurStep, mDOSw]);
    Result := true;
end;


function THVDIOCtrler.SwOff(CurStep: integer): boolean;
begin
    mDIO.SetIO(mDOSw, false);
    //gLog.Panel('%s: %d단 SW(%d) OFF', [mHVTest.Name, mHVTest.CurStep, mDOSw]);
    Result := true;
end;

function THVDIOCtrler.GetIOFromAI(aAiCh:integer): boolean;
begin
    Result := mAD.GetVolt(aAiCh) > 2.0;
end;


function THVDIOCtrler.GetLedData: BYTE;
begin
    Result := mDIO.GetIO(mDILed1) or mDIO.GetIO(mDILed2) shl 1;
end;

function THVDIOCtrler.GetStateStr: string;
begin
    // Debug용도
    Result := Format('%d', [mAD.GetDigital(mAICurrCh)]);
end;

end.
