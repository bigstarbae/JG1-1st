unit MsgData;

interface
uses
    Dialogs;

type
    TMsgData = packed record
        mCaption, mMsg1, mMsg2: string;
        mTime: Integer;
        mDlgType: TMsgDlgType;

        procedure Init(Caption, Msg1: string; Msg2: string = '');
    end;

var
    gMsgData: TMsgData;


implementation

{ TMsgData }

procedure TMsgData.Init(Caption, Msg1, Msg2: string);
begin
    mCaption := Caption;
    mMsg1 := Msg1;
    mMsg2 := Msg2;
end;


end.
