unit TechSupportForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ReferBaseForm, Grids, ExtCtrls, StdCtrls, Label3D, SuperObject;

type
  TfrmTechSupport = class(TfrmReferBase)
    imgQRCode: TImage;
    sgTSList: TStringGrid;
    lblURL: TLabel3D;
    procedure sgTSListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblURLClick(Sender: TObject);
  private
    { Private declarations }
    mURLs: array of string;

    function LoadTSList: boolean;
  public
    { Public declarations }
  end;

var
  frmTechSupport: TfrmTechSupport;

implementation
uses
    shellapi, SysEnv, Math, Global, LangTran;

{$R *.dfm}

{ TfrmTechSupport }

procedure TfrmTechSupport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    inherited;
    mURLs := nil;
end;

procedure TfrmTechSupport.FormShow(Sender: TObject);
var
    CanSel: boolean;
begin
    inherited;

    sgTSList.Cells[0, 0] := ' No';
    sgTSList.Cells[1, 0] := _TR(' 내 역');

    if LoadTSList then
        sgTSListSelectCell(sgTSList, 1, 1, CanSel);

end;

procedure TfrmTechSupport.lblURLClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PWideChar(lblURL.Caption), '', '', SW_SHOWNORMAL);

end;

function TfrmTechSupport.LoadTSList: boolean;
var
    TSList: TSuperArray;
    TSJson: ISuperObject;
    FilePath: string;
    i: integer;

begin
    Result := false;

    FilePath := GetEnvPath('TechSupport.json');

    if not FileExists(FilePath)  then
    begin
        ShowMessage('기술 지원 정의 파일이 없습니다     .\Env폴더내 TechSupport.json파일을 확인 하세요');
        Exit;
    end;


    TSJson := TSuperObject.ParseFile(FilePath, true);      // 한글일 경우 UTF-16 파일 형식 필수

    TSList := TSJson.A['TECH_SUPPORT_LIST'];

    sgTSList.RowCount := Max(2, TSList.Length + 1);

    SetLength(mURLs, TSList.Length);

    for i := 0 to TSList.Length - 1 do
    begin
        sgTSList.Cells[0, i + 1] := ' ' + IntToStr(i + 1);
        sgTSList.Cells[1, i + 1] := ' ' + TSList[i].S['TITLE'];
        mURLs[i] := TSList[i].S['URL'];
    end;

    Result := TSList.Length > 0;
end;

procedure TfrmTechSupport.sgTSListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  //
    if Length(mURLs) = 0 then Exit;

    DrawQRCode(imgQRCode, mURLs[ARow - 1]);
    lblURL.Caption := mURLs[ARow - 1];
end;

end.
