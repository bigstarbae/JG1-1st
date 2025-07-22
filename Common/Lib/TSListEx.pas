unit TSListEx;

interface

uses
    SyncObjs, Generics.Collections;

type
    TTSListEx<T> = class
    private
        mList: TList<T>;
        mCS: TCriticalSection;
        mEvent: TEvent;
        mIsClose: Boolean;
    public
        constructor Create;
        destructor Destroy; override;

        procedure Push(Data: T);
        procedure PushFront(Data: T);           // �켱 ���� �Լ�
        procedure PushWithEvent(Data: T);
        procedure PushFrontWithEvent(Data: T);  // �켱 ���� + �̺�Ʈ
        procedure SetEvent;

        function Pop(var Data: T): Boolean;
        function WaitAndPop(var Data: T): Boolean;
        function Peek(var Data: T): Boolean;
        function Remove: Boolean;
        procedure Clear;

        procedure Close;

        function IsEmpty: Boolean;
        function Count: Integer;
    end;

implementation

uses
    SysUtils;

constructor TTSListEx<T>.Create;
begin
    inherited Create;
    mList := TList<T>.Create;
    mCS := TCriticalSection.Create;
    mEvent := TEvent.Create(nil, False, False, '', False);
    mIsClose := False;  // �ʱ�ȭ �߰�
end;

destructor TTSListEx<T>.Destroy;
begin
    Close;
    FreeAndNil(mList);
    FreeAndNil(mCS);
    FreeAndNil(mEvent);
    inherited Destroy;
end;

function TTSListEx<T>.IsEmpty: Boolean;
begin
    Result := Count = 0;
end;

function TTSListEx<T>.Count: Integer;
begin
    mCS.Acquire;
    try
        Result := mList.Count;
    finally
        mCS.Release;
    end;
end;

procedure TTSListEx<T>.Clear;
begin
    mCS.Acquire;
    try
        mList.Clear;
    finally
        mCS.Release;
    end;
end;

function TTSListEx<T>.Remove: Boolean;
begin
    mCS.Acquire;
    try
        if mList.Count > 0 then
        begin
            mList.Delete(0);
            Result := True;
        end
        else
            Result := False;
    finally
        mCS.Release;
    end;
end;

procedure TTSListEx<T>.SetEvent;
begin
    mEvent.SetEvent;
end;

procedure TTSListEx<T>.Close;
begin
    mIsClose := True;
    Clear;
    mEvent.SetEvent;
end;

procedure TTSListEx<T>.Push(Data: T);
begin
    if mIsClose then
        Exit;

    mCS.Acquire;
    try
        mList.Add(Data);
    finally
        mCS.Release;
    end;
end;

procedure TTSListEx<T>.PushFront(Data: T);
begin
    if mIsClose then
        Exit;

    mCS.Acquire;
    try
        mList.Insert(0, Data);
    finally
        mCS.Release;
    end;
end;

// �⺻ ���� + �̺�Ʈ �ñ׳�
procedure TTSListEx<T>.PushWithEvent(Data: T);
begin
    if mIsClose then
        Exit;

    mCS.Acquire;
    try
        mList.Add(Data);
    finally
        mCS.Release;
    end;

    mEvent.SetEvent;
end;

// �켱 ���� + �̺�Ʈ �ñ׳�
procedure TTSListEx<T>.PushFrontWithEvent(Data: T);
begin
    if mIsClose then
        Exit;

    mCS.Acquire;
    try
        mList.Insert(0, Data);
    finally
        mCS.Release;
    end;

    mEvent.SetEvent;
end;

function TTSListEx<T>.Peek(var Data: T): Boolean;
begin
    mCS.Acquire;
    try
        if mList.Count > 0 then
        begin
            Data := mList[0];
            Result := True;
        end
        else
            Result := False;
    finally
        mCS.Release;
    end;
end;

function TTSListEx<T>.Pop(var Data: T): Boolean;
begin
    mCS.Acquire;
    try
        if mList.Count > 0 then
        begin
            Data := mList[0];
            mList.Delete(0);
            Result := True;
        end
        else
            Result := False;
    finally
        mCS.Release;
    end;
end;


function TTSListEx<T>.WaitAndPop(var Data: T): Boolean;
begin
    Result := False;

    while not mIsClose do
    begin
        mCS.Acquire;
        try
            if mList.Count > 0 then
            begin
                Data := mList[0];
                mList.Delete(0);
                Result := True;
                Exit;
            end;
        finally
            mCS.Release;
        end;

        // ť�� ��������� �̺�Ʈ�� ��ٸ�
        mEvent.WaitFor(INFINITE);
    end;
end;

end.

