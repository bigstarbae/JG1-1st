unit ReferBaseForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, DataUnit, KiiMessages;

type
    TfrmReferBase = class(TForm)
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
        procedure FormCreate(Sender: TObject);
        procedure FormDestroy(Sender: TObject);
        procedure FormShow(Sender: TObject);
    private

        { Private declarations }
    protected
        mEdit: Boolean;
        mIsChanged: Boolean;
        mChangeEvent: TNotifyStatus;

    public
        { Public declarations }
        function Save: Boolean; virtual; abstract;

        procedure SetStation(StIdx: Integer); virtual;

        procedure Docking(AParent: TWinControl);
        procedure Undocking;
        function  IsUndocked: Boolean;

        property OnUserChange: TNotifyStatus read mChangeEvent write mChangeEvent;
    end;

var
    frmReferBase: TfrmReferBase;

implementation

uses
    Log, LangTran;
{$R *.dfm}


procedure TfrmReferBase.Docking(AParent: TWinControl);
begin
    BorderStyle  := bsNone;
    Parent := AParent;
    Align  := alClient;
end;

procedure TfrmReferBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin

    if Assigned(mChangeEvent) then
        mChangeEvent(Self, -1);


    mChangeEvent := nil;
    Action := caFree;
end;

procedure TfrmReferBase.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    gLog.ToFiles('%s CLOSE', [Caption]);
end;

procedure TfrmReferBase.FormCreate(Sender: TObject);
begin
    mChangeEvent := nil;
    mEdit := false;


    DragKind := dkDock;
    DragMode := dmAutomatic;

end;

procedure TfrmReferBase.FormDestroy(Sender: TObject);
begin
    //
end;

procedure TfrmReferBase.FormShow(Sender: TObject);
begin
    gLog.ToFiles('%s SHOW', [Caption]);
    TLangTran.ChangeCaption(self);
end;

procedure TfrmReferBase.SetStation(StIdx: Integer);
begin

end;

procedure TfrmReferBase.Undocking;
begin
    Align  := alNone;

    BorderStyle  := bsSizeable;
    Width := Parent.Width;
    Height := Parent.Height;
    Parent := nil;
    FormStyle := fsStayOnTop;
end;

function TfrmReferBase.IsUndocked: Boolean;
begin
    Result := Parent = nil;
end;

end.
