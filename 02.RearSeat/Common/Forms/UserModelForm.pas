unit UserModelForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, EditForm;

type
    TfrmUserModel = class(TForm)
        Panel2: TPanel;
        tvList: TTreeView;
        pnlDock: TPanel;
        Panel4: TPanel;
        sbtnsave: TSpeedButton;
        sbtnSaveAll: TSpeedButton;
        Panel18: TPanel;
        sbtnClose: TSpeedButton;
        pnlTitle: TPanel;
        sdlgSave: TSaveDialog;
        pnlImpOpt: TPanel;
        cbOverWrite: TCheckBox;
        cbPartName: TCheckBox;
        cbPartNo: TCheckBox;
        cbTypes: TCheckBox;
        cbSpecChk: TCheckBox;
        btnCopy: TSpeedButton;
        btnPaste: TSpeedButton;
        Splitter1: TSplitter;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure tvListChange(Sender: TObject; Node: TTreeNode);
        procedure FormShow(Sender: TObject);
        procedure sbtnsaveClick(Sender: TObject);
        procedure sbtnSaveAllClick(Sender: TObject);
        procedure sbtnCloseClick(Sender: TObject);
        procedure sbtnExitClick(Sender: TObject);
        procedure pnlTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure btnCopyClick(Sender: TObject);
        procedure btnPasteClick(Sender: TObject);
    private
    { Private declarations }
        mEditor: TfrmEdit;
        mIdx, mCopyMdlIdx: Integer;

        procedure ListUpdates(AInit: boolean = false);
        procedure OnMyChange(Sender: TObject; AStatus: integer);
    public
    { Public declarations }
    end;

var
    frmUserModel: TfrmUserModel;

implementation

uses
    ModelUnit, Log, DataUnit, myUtils, KiiMessages, SelModelForm,
    CustomOpenDialog, LangTran;

{$R *.dfm}

procedure TfrmUserModel.btnCopyClick(Sender: TObject);
begin
    mCopyMdlIdx := mIdx;
    btnPaste.Enabled := true;
end;

procedure TfrmUserModel.btnPasteClick(Sender: TObject);
begin
    if mCopyMdlIdx <> mIdx then
    begin
        gModels.CopyTo(mCopyMdlIdx, mIdx);
        ListUpdates;
        with mEditor do
            SetFrm(mIdx);
        sbtnsave.Enabled := true;
    end;
end;

procedure TfrmUserModel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
    frmUserModel := nil;
end;

procedure TfrmUserModel.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    SendToForm(gUsrMsg, SYS_VISIBLE_LOG, 1);
end;

procedure TfrmUserModel.FormCreate(Sender: TObject);
begin
    if not Assigned(mEditor) then
    begin
        mEditor := TfrmEdit.Create(Self);
        with mEditor do
        begin
            Parent := pnlDock;
            BorderStyle := bsNone;
            Align := alClient;

            OnUserChange := OnMyChange;
            SetFrm(1);
            Show;
        end;
    end;
end;

procedure TfrmUserModel.FormDestroy(Sender: TObject);
begin
    if Assigned(mEditor) then
        mEditor.Close;
    mEditor := nil;
end;

procedure TfrmUserModel.FormShow(Sender: TObject);
var
    i, std: integer;
begin
    ListUpdates(true);
    if not Assigned(gModels) then
        exit;
    std := gModels.GetUsrIndex(0) - 1;
    for i := 0 to tvList.Items.Count - 1 do
    begin
        if (std = i) and not tvList.Items.Item[i].Selected then
        begin
            tvList.Items.Item[i].Selected := true;
            break;
        end;
    end;
    TLangTran.ChangeCaption(self);
end;

procedure TfrmUserModel.ListUpdates(AInit: boolean);
var
    i: integer;
    nNode: TTreeNode;
    sTm: string;
begin
    nNode := nil;
    if AInit then
        tvList.Items.Clear;
    if not Assigned(gModels) then
        exit;
    for i := 1 to _MAX_MODEL_COUNT do
    begin
        with gModels.GetModels(i) do
        begin
            if rPartName = '' then
                sTm := Format('%d.', [i])
            else
                sTm := Format('%d. %s', [i, rPartName]);

            with tvList.Items do
            begin
                if AInit then
                    nNode := Add(nNode, sTm)
                else
                begin
                    if not Assigned(nNode) then
                        nNode := GetFirstNode
                    else
                        nNode := nNode.GetNext;

                    if not Assigned(nNode) then
                        Continue;

                    if nNode.Text <> sTm then
                    begin
                        nNode.Text := sTm;
                    end;
                end;
            end;
        end;
    end;
end;

procedure TfrmUserModel.OnMyChange(Sender: TObject; AStatus: integer);
begin
    sbtnSave.Enabled := AStatus = 1;
    sbtnSaveAll.Enabled := sbtnSave.Enabled;
end;

procedure TfrmUserModel.pnlTitleMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    ReleaseCapture();
    PostMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
end;

procedure TfrmUserModel.sbtnCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmUserModel.sbtnExitClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmUserModel.sbtnSaveAllClick(Sender: TObject);
var
    i: integer;
    nP: TPoint;
    nB: array of boolean;
begin
    if not Assigned(mEditor) then
        Exit;

    frmSelModels := TfrmSelModels.Create(nil);
    nP.X := Screen.Width div 2 - frmSelModels.Width div 2;
    nP.Y := Screen.Height div 2 - frmSelModels.Height div 2;

    frmSelModels.SetInit(-1);
    if not frmSelModels.Execute(nP.X, nP.Y) then
        Exit;

    SetLength(nB, _MAX_MODEL_COUNT);
    for i := 0 to _MAX_MODEL_COUNT - 1 do
    begin
        nB[i] := frmSelModels.IsChecked(i);
    end;

    mEditor.Save(nB);
    ListUpdates;
    if Length(nB) > 0 then
        SetLength(nB, 0);
end;

procedure TfrmUserModel.sbtnsaveClick(Sender: TObject);
begin
    if not Assigned(mEditor) then
        Exit;

    mEditor.Save([]);
    ListUpdates;
end;

procedure TfrmUserModel.tvListChange(Sender: TObject; Node: TTreeNode);
begin
    if not Assigned(mEditor) then
        Exit;

    mIdx := Node.Index + 1;

    with mEditor do
        SetFrm(mIdx);
end;

end.

