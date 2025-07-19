unit MagneticForm;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Magnetic;

type
    TfrmMagnetic = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    private
        { Private declarations }
        mHandled: boolean;
    public
        { Public declarations }

        procedure WMEnterSizeMove(var Msg: TMessage); message WM_ENTERSIZEMOVE;
        procedure WMSizing(var Msg: TMessage); message WM_SIZING;
        procedure WMMoving(var Msg: TMessage); message WM_MOVING;
        procedure WMExitSizeMove(var Msg: TMessage); message WM_EXITSIZEMOVE;
        procedure WMSysCommand(var Msg: TMessage); message WM_SYSCOMMAND;
        procedure WMCommand(var Msg: TMessage); message WM_COMMAND;

        procedure SetMagParentWnd;
        procedure AddChild(AHandle: THandle);
        procedure CloseChilds;

        procedure CheckGlueing;

    end;

var
    frmMagnetic: TfrmMagnetic;

implementation

{$R *.dfm}

var
    MagneticWndProc: TSubClass_Proc;



procedure TfrmMagnetic.FormShow(Sender: TObject);
begin
//
end;

procedure TfrmMagnetic.AddChild(AHandle: THandle);
begin
    if Assigned(MagneticWnd) then
        MagneticWnd.AddWindow(AHandle, Handle,  MagneticWndProc);
end;

procedure TfrmMagnetic.SetMagParentWnd;
begin
    MagneticWnd := TMagnetic.Create;

    MagneticWnd.AddWindow(Handle, 0, MagneticWndProc);

end;

procedure TfrmMagnetic.CheckGlueing;
begin
    if Assigned(MagneticWnd) then
        MagneticWnd.CheckGlueing;
end;

procedure TfrmMagnetic.CloseChilds;
begin
    if Assigned(MagneticWnd) then
    begin

        MagneticWnd.CloseWindows;
    end;
end;

procedure TfrmMagnetic.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if Assigned(MagneticWnd) then
        FreeAndNil(MagneticWnd);
end;


procedure TfrmMagnetic.WMCommand(var Msg: TMessage);
begin
    inherited;

    if Assigned(MagneticWndProc) then
        MagneticWndProc(Handle, WM_COMMAND, Msg, mHandled);
end;

procedure TfrmMagnetic.WMEnterSizeMove(var Msg: TMessage);
begin
    inherited;

    if Assigned(MagneticWndProc) then
        MagneticWndProc(Handle, WM_ENTERSIZEMOVE, Msg, mHandled);
end;

procedure TfrmMagnetic.WMExitSizeMove(var Msg: TMessage);
begin
    inherited;

    if Assigned(MagneticWndProc) then
        MagneticWndProc(Handle, WM_EXITSIZEMOVE, Msg, mHandled);

end;

procedure TfrmMagnetic.WMMoving(var Msg: TMessage);
begin
    inherited;

    if Assigned(MagneticWndProc) then
        MagneticWndProc(Handle, WM_MOVING, Msg, mHandled);

end;

procedure TfrmMagnetic.WMSizing(var Msg: TMessage);
begin
    if not Assigned(MagneticWndProc) then
        inherited
    else if MagneticWndProc(Handle, WM_SIZING, Msg, mHandled) then
    begin
        if not mHandled then
            inherited
    end
    else
        inherited;
end;

procedure TfrmMagnetic.WMSysCommand(var Msg: TMessage);
begin
    inherited;

    if Assigned(MagneticWndProc) then
        MagneticWndProc(Handle, WM_SYSCOMMAND, Msg, mHandled);

end;

end.
