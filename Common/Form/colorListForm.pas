unit colorListForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TfrmColorList = class(TForm)
    gbColorList: TGroupBox;
    ColorBox1: TColorBox;
    bbtnOK: TBitBtn;
    BitBtn4: TBitBtn;
    bbtnApply: TBitBtn;
    Edit1: TEdit;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    DlgColor: TColorDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure bbtnApplyClick(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    mRs : TModalResult ;
  public
    { Public declarations }

    procedure SetFrm(aBuf:Pointer; aCount:integer) ;
    procedure SetNames(aName: string; IsData:boolean) ;
  end;

var
  frmColorList: TfrmColorList;

implementation
uses
    DataUnit, LangTran ;

var
    lpIsData: boolean ;
    lpName  : string ;
    lpColor : pColorList ;

{$R *.dfm}
procedure SetUserColor(aColorBox:TColorBox; aColor:TColor);
begin
    with aColorBox do
    begin
        if Items.IndexOfObject(TObject(aColor)) >= 0 then Selected := aColor
        else
        begin
            AddItem(Format('$%s', [IntToHex(integer(aColor),8)]), TObject(aColor));
            ItemIndex := Items.Count-1 ;
        end ;
    end ;
end ;

procedure TfrmColorList.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree ;
end;

procedure TfrmColorList.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//
end;

procedure TfrmColorList.FormCreate(Sender: TObject);
begin
//
    lpColor := nil ;
end;

procedure TfrmColorList.FormDestroy(Sender: TObject);
begin
    bbtnApply.Enabled := false ;
end;

procedure TfrmColorList.FormShow(Sender: TObject);
var
    i   : integer ;
    com : TComponent ;
    sTm, nM : string ;
begin
    for i := 0 to 7 do
    begin
        sTm := GetGraphLineName(lpName, i, lpIsData) ;
        nM  := Format('Edit%d', [i+1]) ;
        com := FindComponent(nM) ;
        if com <> nil then
            with com as TEdit do Text := sTm ;

        com := FindComponent(Format('ColorBox%d', [i+1])) ;
        if com <> nil then SetUserColor(TColorBox(com), lpColor^[i]) ;
    end ;

    bbtnApply.Enabled := false ;
    mRs := mrCancel ;

    //ChangeCaption(Self);
	TLangTran.ChangeCaption(self);
end;

procedure TfrmColorList.SetFrm(aBuf:Pointer; aCount:integer) ;
var
    i, Gap : integer ;
begin
    lpColor := aBuf ;

    Gap := (ColorBox1.Height - Edit1.Height) div 2 ;
    for i := 1 to aCount-1 do
    begin
        with TColorBox.Create(Self) do
        begin
            Parent := gbColorList ;
            Top    := ColorBox1.Top + ((ColorBox1.Height + 5) * i) ;
            Left   := ColorBox1.Left ;
            Name   := Format('ColorBox%d', [i+1]) ;
            Tag    := i ;

            OnChange := ColorBox1Change ;
        end ;

        with TEdit.Create(Self) do
        begin
            Parent := gbColorList ;
            Ctl3D  := false ;
            Top    := ColorBox1.Top + ((ColorBox1.Height + 5) * i)+ Gap ;
            Left   := Edit1.Left ;
            Name   := Format('Edit%d', [i+1]) ;
            Text   := '' ;
            Tag    := i ;

            OnChange := ColorBox1Change ;
        end ;

        with TButton.Create(Self) do
        begin
            Parent := gbColorList ;
            Ctl3D  := false ;
            Top    := ColorBox1.Top + ((ColorBox1.Height + 5) * i) ;
            Left   := Button1.Left ;
            Name   := Format('Button%d', [i+1]) ;
            Caption:= Button1.Caption ;
            Width  := Button1.Width ;
            Height := Button1.Height ;
            Tag    := i ;

            OnClick := Button1Click ;
        end ;
    end ;
end ;

procedure TfrmColorList.SetNames(aName:string; IsData:boolean) ;
begin
    lpIsData := IsData ;
    lpName   := aName ;
    Caption  := lpName +' '+Caption ;
end ;

procedure TfrmColorList.ColorBox1Change(Sender: TObject);
begin
    if not Showing then Exit ;
    bbtnApply.Enabled := true ;
end;

procedure TfrmColorList.bbtnApplyClick(Sender: TObject);
var
    i   : integer ;
    sTm : string ;
    com : TComponent ;
begin
    for i := 0 to 7 do
    begin
        sTm := '' ;

        com := FindComponent(Format('Edit%d', [i+1])) ;
        if com = nil then Continue ;
        with com as TEdit do sTm := Text ;

        com := FindComponent(Format('ColorBox%d', [i+1])) ;
        if com = nil then Continue ;
        with com as TColorBox do lpColor^[i] := Selected ;

        SetGraphLineName(lpName, sTm, i, lpIsData) ;
    end ;

    with Sender as TBitBtn do Enabled := false ;
    mRs := mrOK ;
end;

procedure TfrmColorList.bbtnOKClick(Sender: TObject);
begin
    if bbtnApply.Enabled then bbtnApply.Click ;

    ModalResult := mRs ;
end;

procedure TfrmColorList.Button1Click(Sender: TObject);
var
    com: TComponent ;
begin
    com := FindComponent(Format('ColorBox%d', [TButton(Sender).Tag+1])) ;
    if not Assigned(com) then Exit ;
    
    with DlgColor do
    begin
        Color := TColorBox(com).Selected ;
        CustomColors.Clear ;
        if Execute then
        begin
            SetUserColor(TColorBox(com), Color);
            bbtnApply.Enabled := true ;
        end ;
    end ;
end;

end.
