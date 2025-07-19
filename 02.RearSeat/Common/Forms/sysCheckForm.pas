unit sysCheckForm;

//포트가 사용가능한지만 체크...
//생성은 반드시 다른 통신관련 클래스 보다 먼저

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Buttons;

type
  TfrmsysCheck = class(TForm)
    pgbTimer: TProgressBar;
    cpuUsageTimer: TTimer;
    labLog: TLabel;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cpuUsageTimerTimer(Sender: TObject);
  private
    { Private declarations }
    mLock: boolean ;
    mProc: integer ;

    function IsSystemReady(): boolean ;
  public
    { Public declarations }
    function  Execute() : Boolean ; overload ;
  end;

var
  frmsysCheck: TfrmsysCheck;

implementation
uses
    ComUnit, DataUnit, RS232, LangTran ;

{$R *.dfm}

procedure TfrmsysCheck.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmsysCheck.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//
end;

procedure TfrmsysCheck.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmsysCheck.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmsysCheck.FormShow(Sender: TObject);
begin
    pgbTimer.Position := 0 ;
    pgbTimer.Max:= 120 ;
    mLock := false ;
    mProc := 0 ;
    cpuUsageTimer.Enabled:= true ;
	TLangTran.ChangeCaption(self);
end;

procedure TfrmsysCheck.cpuUsageTimerTimer(Sender: TObject);
begin
    if mLock then Exit ;
    mLock := true ;
    pgbTimer.Position := pgbTimer.Position + 1 ;
    if IsSystemReady or (pgbTimer.Position >= pgbTimer.Max) then
    begin
        ModalResult := mrOK ;
    end ;
    mLock := false ;
end;

function TfrmsysCheck.Execute(): Boolean;
begin
    Result:= ShowModal = mrOK ;
end;

function TfrmsysCheck.IsSystemReady: boolean;
var
    nC: TRs232 ;
    nB: TDevComInfo ;
begin
    Result:= false ;
    nC:= TRS232.Create ;
    try
        nB:= GetDevComInfo(TDevComORD(mProc));
        labLog.Caption:= 'COM'+IntToStr(nB.rAPort)+' connecting...' ;
        if nC.Open(TCommPorts(nB.rAPort-1),
                              9600,
                              8,
                              0,
                              0,
                              1024,
                              false) then
        begin
            Inc(mProc) ;
            Result:= ord(High(TDevComORD)) < mProc ;
        end;
    finally
        nC.Close ;
        nC.Free ;
    end;
end;

end.
