unit AComReferForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, UserComLibEx ;

type
  TfrmAComRefer = class(TForm)
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cbxBaud: TComboBox;
    cbxDataBit: TComboBox;
    cbxParity: TComboBox;
    cbxStop: TComboBox;
    Bevel1: TBevel;
    labsubCaption: TLabel;
    bbtnCancel: TBitBtn;
    bbtnOK: TBitBtn;
    bbtnApply: TBitBtn;
    Label1: TLabel;
    cbxFlow: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbxBaudChange(Sender: TObject);
    procedure bbtnApplyClick(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
  private
    { Private declarations }
    mParam   : pComParam ;

    procedure Initial ;
    procedure Save ;
    procedure Load ;
  public
    { Public declarations }
    procedure SetFrm(AParam: pComParam) ;
  end;

var
  frmAComRefer: TfrmAComRefer;

implementation
uses
    IniFiles, myUtils, RS232, DataUnit, LangTran;

{$R *.DFM}
//------------------------------------------------------------------------------
// TfrmComRefer
//------------------------------------------------------------------------------
procedure TfrmAComRefer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action:= caFree ;
end;

procedure TfrmAComRefer.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    //
end;

procedure TfrmAComRefer.FormCreate(Sender: TObject);
begin
    Initial ;
end;

procedure TfrmAComRefer.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmAComRefer.FormShow(Sender: TObject);
begin
    cbxBaud.ItemIndex    := 0 ;
    cbxDataBit.ItemIndex := 0 ;
    cbxStop.ItemIndex    := 0 ;
    cbxParity.ItemIndex  := 0 ;

    Load ;

    bbtnApply.Enabled := false ;
end;

procedure TfrmAComRefer.SetFrm(AParam: pComParam) ;
begin
    mParam := AParam ;
end ;

procedure TfrmAComRefer.Initial ;
var
    i : integer ;
begin
    cbxBaud.Clear ;
    for i := 0 to High(aryBaudRate) do
        cbxBaud.Items.AddObject(IntToStr(aryBaudRate[i]), TObject(aryBaudRate[i])) ;

    cbxParity.Clear ;
    for i := 0 to High(aryParityTxt) do
        cbxParity.Items.AddObject(aryParityTxt[i], TObject(aryParity[i])) ;

    cbxStop.Clear ;
    for i := 0 to High(aryStopTxt) do
        cbxStop.Items.AddObject(aryStopTxt[i], TObject(aryStopBits[i])) ;

    cbxDataBit.Clear ;
    for i := 0 to High(aryDataBit) do
        cbxDataBit.Items.AddObject(IntToStr(aryDataBit[i]), TObject(aryDataBit[i])) ;

    cbxFlow.Clear ;
    cbxFlow.Items.Add(_TR('사용안함'));
    cbxFlow.Items.Add(_TR('하드웨어'));
end ;

procedure TfrmAComRefer.cbxBaudChange(Sender: TObject);
begin
    bbtnApply.Enabled := true ;
end;

procedure TfrmAComRefer.Load ;
//var
//    Param : TComParam ;
begin
    if Assigned(mParam) then
    begin
        with mParam^ do
        begin
            labsubCaption.Caption := Format(_TR('COM%d 통신설정'), [ord(rPort)+1]) ;
            with cbxBaud do
            begin
                if Items.IndexOfObject(TObject(rBaudRate)) >= 0 then
                    ItemIndex := Items.IndexOfObject(TObject(rBaudRate))
            end ;

            with cbxDataBit do
            begin
                if Items.IndexOfObject(TObject(rDataBit)) >= 0 then
                    ItemIndex := Items.IndexOfObject(TObject(rDataBit))
            end ;

            with cbxStop do
            begin
                if Items.IndexOfObject(TObject(rStopBIt)) >= 0 then
                    ItemIndex := Items.IndexOfObject(TObject(rStopBIt))
            end ;

            with cbxParity do
            begin
                if Items.IndexOfObject(TObject(rParity)) >= 0 then
                    ItemIndex := Items.IndexOfObject(TObject(rParity))
            end ;
            cbxFlow.ItemIndex := integer(rwHand) ;
        end ;
    end ;
end ;

procedure TfrmAComRefer.Save ;
//var
//    Param : TComParam ;
begin
    if not Assigned(mParam) then Exit ;

    with mParam^ do
    begin
        rBaudRate := DWORD(cbxBaud.Items.Objects[cbxBaud.ItemIndex]) ;
        rDataBit  := WORD(cbxDataBit.Items.Objects[cbxDataBit.ItemIndex]) ;
        rParity   := WORD(cbxParity.Items.Objects[cbxParity.ItemIndex]) ;
        rStopBIt  := WORD(cbxStop.Items.Objects[cbxStop.ItemIndex]) ;
        rwHand    := cbxFlow.ItemIndex = 1 ;
    end ;

    bbtnApply.Enabled := false ;
end ;

procedure TfrmAComRefer.bbtnApplyClick(Sender: TObject);
begin
    Save ;
end;

procedure TfrmAComRefer.bbtnOKClick(Sender: TObject);
begin
    if bbtnApply.Enabled then Save ;
    Close ;
end;

end.
