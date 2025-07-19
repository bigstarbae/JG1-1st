{
    240927.00 : Common 자격을 얻기 위해 개선:
}

unit DioReferForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls,
    ReferBaseForm, DioForm, BaseDIO, BaseAD, BaseCounter;

type
    TReqADsEvent = reference to procedure(var ADs: array of TBaseAD);
    TReqDIOsEvent = reference to procedure(var ADs: array of TBaseDIO);

    TfrmDioReferForm = class(TForm)
        Panel2: TPanel;
        Panel1: TPanel;
        bbtnOK: TBitBtn;
        btnUndock: TButton;
        pcSubForms: TPageControl;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure bbtnOKClick(Sender: TObject);
        procedure btnUndockClick(Sender: TObject);
        procedure pcSubFormsChange(Sender: TObject);

    private
    { Private declarations }
        mSubForms: array of TfrmReferBase;
        mStationNames: array of string;


        procedure SubFormStatus(Sender: TObject; AStatus: integer);

        procedure SubFormUndock(Sender: TObject; Client: TControl; NewTarget: TWinControl; var Allow: Boolean);
        procedure SubFormEndDock(Sender, Target: TObject; X, Y: Integer);

        procedure AddSubForm(SubForm: TfrmReferBase);

    public
    { Public declarations }
        class var mIsShow: Boolean;
        class procedure CloseForm;

        constructor Create(AOwner: TComponent; StationNames: array of string); overload;
        procedure SetStation(StIdx: Integer);

        procedure AddADs(FormName: string; ADs: array of TBaseAD); overload;
        procedure AddADs(FormName: string; ReqADsFunc: TReqADsEvent); overload;       // 콜백함수로 설정시

        procedure AddDIOs(FormName: string; DIOs: array of TBaseDIO; TotChCount: Integer); overload;
        procedure AddDIOs(FormName: string; ReqDIOsFunc: TReqDIOsEvent; TotChCount: Integer); overload;    // 콜백함수로 설정시

        procedure AddLIO(FormName: string; LIO: TBaseDIO; TotChCount, StationCount: Integer; WordDataReadFunc: TWordDataReadFunc);

        procedure AddCTs(FormName: string; CTs: array of TBaseCounter); overload;

    end;

var
    frmDioReferForm: TfrmDioReferForm;

implementation

uses
    Global, ADForm, IniFiles, myUtils, lanIOUnit,
    IODef, LangTran;

{$R *.dfm}

var
    gSingleInstDRForm: TfrmDioReferForm;

procedure TfrmDioReferForm.btnUndockClick(Sender: TObject);
begin
    if not mSubForms[pcSubForms.ActivePageIndex].IsUndocked then
    begin
        mSubForms[pcSubForms.ActivePageIndex].Undocking;
        btnUndock.Enabled := False;
        //FormStyle := fsNormal;         // 항상위 해제
    end;
end;

constructor TfrmDioReferForm.Create(AOwner: TComponent; StationNames: array of string);
var
    i: Integer;
begin
    inherited Create(AOwner);

    SetLength(mStationNames, Length(StationNames));
    for i := 0 to Length(mStationNames) - 1 do
    begin
        mStationNames[i] := StationNames[i];
    end;
end;

procedure TfrmDioReferForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
    i: Integer;
begin
    mIsShow := False;
    for i := 0 to Length(mSubForms) - 1 do
        mSubForms[i] := nil;

    Action := CaFree;

end;

procedure TfrmDioReferForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    Ini: TIniFile;
    i: Integer;
begin
    Ini := TIniFile.Create(GetIniFiles);
    try
        Ini.WriteInteger('DIO_REFER', 'WIDTH', Width);
        Ini.WriteInteger('DIO_REFER', 'HEIGHT', Height);
    finally
        Ini.Free;
    end;

    for i := 0 to Length(mSubForms) - 1 do
    begin
        if Assigned(mSubForms[i]) then
            mSubForms[i].Close;
    end;
end;

procedure TfrmDioReferForm.SubFormStatus(Sender: TObject; AStatus: integer);
begin
    if AStatus = -1 then
        mSubForms[TfrmReferBase(Sender).Tag] := nil;

end;

procedure TfrmDioReferForm.FormCreate(Sender: TObject);
begin


    {
    for i := 0 to pcSubForms.PageCount - 1 do
    begin
        pcSubForms.Pages[i].UseDockManager := True;
        pcSubForms.Pages[i].DockSite := True;
    end;

    frmDio := TfrmDio.Create(Self, 1);
    with frmDio do
    begin
        Caption := 'LAN IO';
        for i := 0 to gTsWorks.Count - 1 do
        begin
            BeginRCh := i * (_LAN_IO_CH_COUNT div 2);     // DIO 의 1/2 -> DI -> DI의 1/2 -> DI 2공정 시작
            AddDIO(gLanDIO, BeginRCh, BeginRCh + _LAN_IO_CH_COUNT, _LAN_IO_CH_COUNT * gTsWorks.Count, gTsWorks.Items[i].Name);

        end;

        WDataReadFunc := gLanDIO.GetDataIoAsWord;
        Parent := tabLanIo;
        BorderStyle := bsNone;
        Align := alClient;
        Show;

        mSubForms[0] := frmDio;
    end;

    frmDio := TfrmDio.Create(Self, 0);
    with frmDio do
    begin

        for i := 0 to gTsWorks.Count - 1 do
            AddDIO(gTsPwrWorks[i].DIO, 0, _DIO_CH_COUNT div 2, _DIO_CH_COUNT, gTsWorks.Items[i].Name);

        frmDio.Caption := 'DIO';
        Parent := tabInIo;
        BorderStyle := bsNone;
        Align := alClient;
        Show;

        mSubForms[1] := frmDio;
    end;

    frmAD := TfrmAD.Create(Self);
    with frmAD do
    begin

        for i := 0 to gTsWorks.Count - 1 do
            AddAD(gTsPwrWorks[i].AD, gTsPwrWorks[i].Name);
        frmDio.Caption := 'AD';
        Parent := tsAD;
        BorderStyle := bsNone;
        Align := alClient;
        Show;

        mSubForms[2] := frmAD;
    end;
    }

end;




procedure TfrmDioReferForm.AddSubForm(SubForm: TfrmReferBase);
var
    Idx: Integer;
begin
    Idx := Length(mSubForms);
    SetLength(mSubForms, Idx + 1);
    mSubForms[Idx] := SubForm;
    mSubForms[Idx].Tag := Idx;
    mSubForms[Idx].OnUserChange := SubFormStatus;
    mSubForms[Idx].OnUnDock := SubFormUndock;
    mSubForms[Idx].OnEndDock := SubFormEndDock;

end;


procedure TfrmDioReferForm.AddADs(FormName: string; ReqADsFunc: TReqADsEvent);
var
    ADs: array of TBaseAD;
begin

    SetLength(ADs, Length(mStationNames));

    ReqADsFunc(ADs);

    AddADs(FormName, ADs);

end;


procedure TfrmDioReferForm.AddCTs(FormName: string; CTs: array of TBaseCounter);
begin

end;

procedure TfrmDioReferForm.AddADs(FormName: string; ADs: array of TBaseAD);
var
    i: Integer;
    ADForm: TfrmAD;
    TS: TTabSheet;
    StName: string;
begin

    TS := TTabSheet.Create(pcSubForms);
    TS.PageControl := pcSubForms;
    TS.Caption := FormName;


    ADForm:= TfrmAD.Create(Self) ;

    with ADForm do
    begin
        Caption := FormName;
        Parent := TS;

        for i := 0 to Length(ADs) - 1 do
        begin
            if Length(mStationNames) = 0 then
                StName := '#' + IntToStr(i + 1)
            else
                StName := mStationNames[i];

            ADForm.AddAD(ADs[i], StName);
        end;

        BorderStyle := bsNone;
        Align := alClient;
        Show ;
    end ;

    AddSubForm(ADForm);

end;

procedure TfrmDioReferForm.AddDIOs(FormName: string; DIOs: array of TBaseDIO; TotChCount: Integer);
var
    i: Integer;
    DIOForm: TfrmDio ;
    TS: TTabSheet;
    StName: string;
begin

    TS := TTabSheet.Create(pcSubForms);
    TS.PageControl := pcSubForms;
    TS.Caption := FormName;


    DIOForm:= TfrmDio.Create(Self, ftDIO) ;

    with DIOForm do
    begin
        Caption := FormName;
        Parent := TS;


        for i := 0 to Length(DIOs) - 1 do
        begin
            if Length(mStationNames) = 0 then
                StName := '#' + IntToStr(i + 1)
            else
                StName := mStationNames[i];

            DIOForm.AddDIO(DIOs[i], 0, TotChCount div 2, TotChCount, StName);
        end;

        BorderStyle := bsNone;
        Align := alClient;
        Show ;
    end ;

    AddSubForm(DIOForm);

end;

procedure TfrmDioReferForm.AddDIOs(FormName: string; ReqDIOsFunc: TReqDIOsEvent; TotChCount: Integer);
var
    DIOs: array of TBaseDIO;
begin

    SetLength(DIOs, Length(mStationNames));

    ReqDIOsFunc(DIOs);

    AddDIOs(FormName, DIOs, TotChCount);

end;

procedure TfrmDioReferForm.AddLIO(FormName: string; LIO: TBaseDIO; TotChCount, StationCount: Integer; WordDataReadFunc: TWordDataReadFunc);
var
    i, BeginRCh: Integer;
    DIOForm: TfrmDio ;
    TS: TTabSheet;
    StName: string;
begin

    TS := TTabSheet.Create(pcSubForms);
    TS.PageControl := pcSubForms;
    TS.Caption := FormName;


    DIOForm:= TfrmDio.Create(Self, ftLIO) ;

    with DIOForm do
    begin
        Caption := FormName;
        Parent := TS;

        for i := 0 to StationCount - 1 do
        begin
            if Length(mStationNames) = 0 then
                StName := '#' + IntToStr(i + 1)
            else
                StName := mStationNames[i];

            BeginRCh := i * (TotChCount div 2);
            AddDIO(LIO, BeginRCh, BeginRCh + (TotChCount div 2) * StationCount, TotChCount, StName);
        end;

        WDataReadFunc := WordDataReadFunc;

        BorderStyle := bsNone;
        Align := alClient;
        Show ;
    end ;

    AddSubForm(DIOForm);
end;

procedure TfrmDioReferForm.SubFormEndDock(Sender: TObject;Target: TObject; X, Y: Integer);
begin
    btnUndock.Enabled := not mSubForms[TForm(Sender).Tag].IsUndocked;
end;

procedure TfrmDioReferForm.SubFormUndock(Sender: TObject; Client: TControl; NewTarget: TWinControl; var Allow: Boolean);
begin
    TfrmReferBase(Sender).Width := pcSubForms.Pages[0].Width;
    TfrmReferBase(Sender).Height := pcSubForms.Pages[0].Height;
end;

procedure TfrmDioReferForm.FormShow(Sender: TObject);
var
    i: Integer;
    Ini: TIniFile;
begin
    mIsShow := true;
    gSingleInstDRForm := Self;

    BorderStyle := bsSizeable;
    FormStyle := fsStayOnTop;

    for i := 0 to pcSubForms.PageCount - 1 do
    begin
        pcSubForms.Pages[i].UseDockManager := True;
        pcSubForms.Pages[i].DockSite := True;
    end;

    Ini := TIniFile.Create(GetIniFiles);
    try
        Width := Ini.ReadInteger('DIO_REFER', 'WIDTH', Width);
        Height := Ini.ReadInteger('DIO_REFER', 'HEIGHT', Height);
    finally
        Ini.Free;
        TLangTran.ChangeCaption(self);
    end;
end;

procedure TfrmDioReferForm.pcSubFormsChange(Sender: TObject);
begin
    btnUndock.Enabled := not mSubForms[pcSubForms.TabIndex].IsUndocked;
end;

class procedure TfrmDioReferForm.CloseForm;
begin
    if mIsShow then
    begin
        gSingleInstDRForm.Close;
    end;
end;

procedure TfrmDioReferForm.SetStation(StIdx: Integer);
begin
    mSubForms[0].SetStation(StIdx);

    if Assigned(mSubForms[1]) then
    begin
        mSubForms[1].SetStation(StIdx);
    end;
end;




procedure TfrmDioReferForm.bbtnOKClick(Sender: TObject);
begin
    Close;
end;


end.

