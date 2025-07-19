unit StateViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, TsWorkUnit, ExtCtrls, StdCtrls, _GClass, AbMTrend;

type
  TfrmStateView = class(TForm)
    tvState: TTreeView;
    tmrPoll: TTimer;
    Panel3: TPanel;
    cbxStation: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrPollTimer(Sender: TObject);
    procedure tvStateAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages,
      DefaultDraw: Boolean);
    procedure cbxStationChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmStateView: TfrmStateView;

implementation
uses
    BaseFSM, BaseTsWork;

{$R *.dfm}


procedure TfrmStateView.FormShow(Sender: TObject);
var
    i: integer;
begin

    for i := 0 to gTsWorks.Count - 1 do
    begin
        cbxStation.Items.Add(gTsWorks.Items[i].Name);
    end;

    cbxStation.ItemIndex := 0;

    cbxStationChange(nil);

end;

procedure TfrmStateView.tmrPollTimer(Sender: TObject);
begin
    tvState.Refresh;
end;

procedure TfrmStateView.tvStateAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
  var PaintImages, DefaultDraw: Boolean);
var
    CellRect: TRect;
    Str: string;
begin
//    DefaultDraw := false;
    CellRect := Node.DisplayRect(false);

    if Node.Data = nil then Exit;
    
    Str := TBaseFSM(Node.Data).GetStateStr;

    DrawText(Sender.Canvas.Handle, PChar(Str), Length(Str), CellRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
end;

procedure TfrmStateView.cbxStationChange(Sender: TObject);
begin
    tmrPoll.Enabled := false;    gTsWorks.Items[cbxStation.ItemIndex].Write(tvState);
    tmrPoll.Enabled := true;
end;

procedure TfrmStateView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;


end.
