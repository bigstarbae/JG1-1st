unit CanOperForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, BaseCAN;

type
  TfrmCanOper = class(TForm)
    Panel2: TPanel;
    btnCanWrite: TSpeedButton;
    btnLoadFrames: TSpeedButton;
    btnSaveFrames: TSpeedButton;
    Shape3: TShape;
    btnUnRWIDApply: TSpeedButton;
    lblUnusedRIDs: TLabel;
    lblUnusedWIDs: TLabel;
    lblRead: TLabel;
    lblWrite: TLabel;
    btnUsedRWIDApply: TSpeedButton;
    btnSaveEnv: TSpeedButton;
    lblRef: TLabel;
    mmoCanFrames: TMemo;
    chkAllFrames: TCheckBox;
    mmoUnusedRIDs: TMemo;
    mmoUnusedWIDs: TMemo;
    mmoUsedWIDs: TMemo;
    mmoUsedRIDs: TMemo;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    GroupBox12: TGroupBox;
    btnLimitSet: TSpeedButton;
    btnLimitClear: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButton15: TSpeedButton;
    SpeedButton16: TSpeedButton;
    SpeedButton17: TSpeedButton;
    SpeedButton18: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton19: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure btnCanWriteClick(Sender: TObject);
    procedure btnLoadFramesClick(Sender: TObject);
    procedure btnSaveFramesClick(Sender: TObject);
    procedure btnUsedRWIDApplyClick(Sender: TObject);
    procedure btnUnRWIDApplyClick(Sender: TObject);
    procedure btnSaveEnvClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }

    mCFrame:    TCANFrame;

    mCAN:       TBaseCAN;
  public
    { Public declarations }
    procedure SetCAN(CAN: TBaseCAN);
  end;

var
  frmCanOper: TfrmCanOper;

implementation
uses
    Log, DataUnit, TsWorkUnit, TimeChecker, IntervalCaller, SysEnv;

{$R *.dfm}

procedure TfrmCanOper.btnCanWriteClick(Sender: TObject);
var
  i: Integer;
  LineIndex: Integer;
  Cmt: string;
begin
    if chkAllFrames.Checked then
    begin
        for i := 0 to mmoCanFrames.Lines.Count - 1 do
        begin
            if mmoCanFrames.Lines[i] = '' then
                continue;
            Cmt := mCFrame.FromStrEx(mmoCanFrames.Lines[i]);
            if not mCAN.Write(mCFrame) then
            begin
                gLog.Error('%s:%s 쓰기 실패 ', [Cmt, mCFrame.ToStr]);
            end;
        end;

    end
    else
    begin
        LineIndex := mmoCanFrames.Perform(EM_LINEFROMCHAR, mmoCanFrames.SelStart, 0);
        if mmoCanFrames.Lines[LineIndex] <> '' then
        begin
            Cmt := mCFrame.FromStrEx(mmoCanFrames.Lines[LineIndex]);
            if not mCAN.Write(mCFrame) then
            begin
                gLog.Error('%s:%s 쓰기 실패 ', [Cmt, mCFrame.ToStr]);
            end;

        end;
    end;

end;

function SaveMemoToFile(const Memo: TMemo; const FileName: string): Boolean;
var
    FileStream: TFileStream;
begin
    Result := False;
    try
        FileStream := TFileStream.Create(FileName, fmCreate or fmOpenWrite);
        try
            Memo.Lines.SaveToStream(FileStream);
            Result := True;
        finally
            FileStream.Free;
        end;
    except
    // Exception 처리
        gLog.Error('파일로 저장 실패', []);
    end;
end;

function LoadMemoFromFile(const Memo: TMemo; const FileName: string): Boolean;
var
    FileStream: TFileStream;
begin
    Result := False;
    try
        FileStream := TFileStream.Create(FileName, fmOpenRead);
        try
            Memo.Lines.LoadFromStream(FileStream);
            Result := True;
        finally
            FileStream.Free;
        end;
    except
    // Exception 처리
        gLog.Error('파일에서 읽기 실패', []);
    end;
end;

procedure TfrmCanOper.btnLoadFramesClick(Sender: TObject);
begin
    if dlgOpen.Execute then
    begin
        LoadMemoFromFile(mmoCanFrames, dlgOpen.FileName);
    end;
end;

procedure TfrmCanOper.btnSaveEnvClick(Sender: TObject);
begin
    gSysEnv.rCanIDFilter.Read(mmoUsedRIDs.Lines, mmoUsedWIDs.Lines);
    gSysEnv.rCanIDFilter.ReadUnused(mmoUnusedRIDs.Lines, mmoUnusedWIDs.Lines);
    gSysEnv.Save(eiCanIDFilter);
end;

procedure TfrmCanOper.btnSaveFramesClick(Sender: TObject);
begin
    if dlgSave.Execute then
    begin
        SaveMemoToFile(mmoCanFrames, dlgSave.FileName);
    end;
end;

procedure TfrmCanOper.btnUnRWIDApplyClick(Sender: TObject);
begin
    gSysEnv.rCanIDFilter.ReadUnused(mmoUnusedRIDs.Lines, mmoUnusedWIDs.Lines);
end;

procedure TfrmCanOper.btnUsedRWIDApplyClick(Sender: TObject);
begin
    gSysEnv.rCanIDFilter.Read(mmoUsedRIDs.Lines, mmoUsedWIDs.Lines);
end;

procedure TfrmCanOper.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmCanOper.FormShow(Sender: TObject);
begin
    gSysEnv.rCanIDFilter.Write(mmoUsedRIDs.Lines, mmoUsedWIDs.Lines);
    gSysEnv.rCanIDFilter.WriteUnused(mmoUnusedRIDs.Lines, mmoUnusedWIDs.Lines);
end;

procedure TfrmCanOper.SetCAN(CAN: TBaseCAN);
begin
    mCAN := CAN;
end;

end.
