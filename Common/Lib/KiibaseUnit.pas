unit KiibaseUnit;

{$ifdef DEBUG}
{$C+,D+,L+,Q+,R+,W+,Y+}
{$else}
{$A8,B-,C-,D-,E-,F-,G+,H+,I+,J-,K-,L-,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$endif}

{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}

interface
uses
	Windows, Sysutils, Classes, Messages, Forms ;

type
TKiiBase = class(TComponent)
private
    { Private declarations }
    FHandle : THandle;
    function GetHandle : THandle;
protected
    { Protected declarations }
    procedure WndProc ( var Message : TMessage ); virtual;

public
    { Public declarations }
    constructor Create ( AOwner : TComponent ); override;
    destructor  Destroy; override;
    function    HandleAllocated : Boolean;
    procedure   HandleNeeded;

    property Handle : THandle read GetHandle;
published
    { Published declarations }
end;

implementation
{$WARN SYMBOL_DEPRECATED OFF}

{ TKiiBase }

constructor TKiiBase.Create(AOwner: TComponent);
begin
    inherited;
    FHandle := 0;
end;

destructor TKiiBase.Destroy;
begin
    if HandleAllocated
        then DeAllocateHWND( FHandle );
    inherited;
end;

function TKiiBase.GetHandle: THandle;
begin
    HandleNeeded ;
    Result := FHandle ;
end;

function TKiiBase.HandleAllocated: Boolean;
begin
    Result := ( FHandle <> 0 );
end;

procedure TKiiBase.HandleNeeded;
begin
    if not HandleAllocated
        then FHandle := AllocateHWND( WndProc );
end;

procedure TKiiBase.WndProc(var Message: TMessage);
begin
    Dispatch ( Message );
end;

end.
 