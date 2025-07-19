{
    Ver. 241007.00 : ÅÇ ÀÌµ¿½Ã ¸¶¿ì½ºÈÙ Áö¿ø
}
unit CANMatrixFrame;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics,
    Controls, Forms, Dialogs, StdCtrls, LedArray, ExtCtrls, Buttons, ComCtrls;

const
    MAX_CAN_DATA_LEN = 64;

type
    TCanFrameMatrix = class(TFrame)
        lblBitOrdH: TLabel;
        Panel1: TPanel;
        edtData1: TEdit;
        ledBits1: TLedArray;
        Panel2: TPanel;
        ledBits6: TLedArray;
        edtData6: TEdit;
        Panel3: TPanel;
        ledBits5: TLedArray;
        edtData5: TEdit;
        Panel4: TPanel;
        ledBits4: TLedArray;
        edtData4: TEdit;
        Panel5: TPanel;
        ledBits3: TLedArray;
        edtData3: TEdit;
        Panel6: TPanel;
        ledBits2: TLedArray;
        edtData2: TEdit;
        Panel7: TPanel;
        ledBits8: TLedArray;
        edtData8: TEdit;
        Panel8: TPanel;
        ledBits7: TLedArray;
        edtData7: TEdit;
        lblBitOrdV1: TLabel;
        lblBitOrdV2: TLabel;
        lblBitOrdV3: TLabel;
        lblBitOrdV4: TLabel;
        lblBitOrdV5: TLabel;
        lblBitOrdV6: TLabel;
        lblBitOrdV7: TLabel;
        lblBitOrdV8: TLabel;
        tcOffset: TTabControl;
        procedure ledBits1LedClick(Sender: TObject; Idx: Integer);
        procedure edtData1KeyPress(Sender: TObject; var Key: Char);
        procedure edtData1Change(Sender: TObject);
        procedure tcOffsetChange(Sender: TObject);
        procedure tcOffsetChanging(Sender: TObject; var AllowChange: Boolean);
        procedure tcOffsetDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);

    private
    { Private declarations }
        mLeds: array[0..7] of TLedArray;
        mEdtVals: array[0..7] of TEdit;
        mLblVBitOrds: array[0..7] of TLabel;

        mDatas: array[0..MAX_CAN_DATA_LEN - 1] of Byte;

        mOldWindowProc: TWndMethod;

        procedure NewWindowProc(var Message: TMessage);

        function GetStartByte: Integer;
        function GetStartBit: Integer;
        procedure DisplayVBitOrds(StartBit: Integer);

        procedure UpdateView(StartByte: Integer);
        procedure UpdateData(StartByte: Integer);
    public
    { Public declarations }
        constructor Create(AOwner: TComponent); override;

        procedure GetDatas(var Datas: array of byte);
        procedure SetDatas(Datas: array of byte);

        procedure SetOnColor(Color: TColor);
    end;

implementation

uses
    Math;

{$R *.dfm}

{ TCanFrameMatrix }

constructor TCanFrameMatrix.Create(AOwner: TComponent);
var
    i: Integer;
begin
    inherited;

    mLeds[0] := ledBits1;
    mLeds[1] := ledBits2;
    mLeds[2] := ledBits3;
    mLeds[3] := ledBits4;
    mLeds[4] := ledBits5;
    mLeds[5] := ledBits6;
    mLeds[6] := ledBits7;
    mLeds[7] := ledBits8;

    mEdtVals[0] := edtData1;
    mEdtVals[1] := edtData2;
    mEdtVals[2] := edtData3;
    mEdtVals[3] := edtData4;
    mEdtVals[4] := edtData5;
    mEdtVals[5] := edtData6;
    mEdtVals[6] := edtData7;
    mEdtVals[7] := edtData8;

    mLblVBitOrds[0] := lblBitOrdV1;
    mLblVBitOrds[1] := lblBitOrdV2;
    mLblVBitOrds[2] := lblBitOrdV3;
    mLblVBitOrds[3] := lblBitOrdV4;
    mLblVBitOrds[4] := lblBitOrdV5;
    mLblVBitOrds[5] := lblBitOrdV6;
    mLblVBitOrds[6] := lblBitOrdV7;
    mLblVBitOrds[7] := lblBitOrdV8;

    for i := 0 to 7 do
    begin
        mLeds[i].Tag := i;
        mLeds[i].Inverse := true;
        mLeds[i].Toggle := true;
        mEdtVals[i].Tag := i;
    end;

    tcOffset.TabIndex := 0;

    mOldWindowProc := tcOffset.WindowProc;
    tcOffset.WindowProc := NewWindowProc;

    DisplayVBitOrds(GetStartBit);
end;

procedure TCanFrameMatrix.UpdateData(StartByte: Integer);
var
    i: Integer;
begin
    for i := 0 to 7 do
    begin
        mDatas[StartByte + i] := mLeds[i].OnOff;
    end;
end;

procedure TCanFrameMatrix.UpdateView(StartByte: Integer);
var
    i: Integer;
begin
    for i := 0 to 7 do
    begin
        mEdtVals[i].Text := IntToHex(mDatas[StartByte + i], 2);
    end;

end;

procedure TCanFrameMatrix.DisplayVBitOrds(StartBit: Integer);
var
    i: Integer;
begin
    for i := 0 to 7 do
    begin
        mLblVBitOrds[i].Caption := IntToStr(StartBit + (i * 8));
    end;

end;

procedure TCanFrameMatrix.edtData1Change(Sender: TObject);
begin
    with TEdit(Sender) do
    begin
        if Text = '' then
        begin
            mLeds[Tag].OnOff := 0;
            Exit;
        end;

        if Length(Text) <= 2 then
            mLeds[Tag].OnOff := StrToInt('$' + Text);
    end;
end;

procedure TCanFrameMatrix.edtData1KeyPress(Sender: TObject; var Key: Char);
begin
    if not (Key in ['0'..'9', 'a'..'f', 'A'..'F', #8, #13]) then
        Key := #0
end;

procedure TCanFrameMatrix.ledBits1LedClick(Sender: TObject; Idx: Integer);
begin
    with TLedArray(Sender) do
        mEdtVals[Tag].Text := IntToHex(OnOff, 2);

end;

procedure TCanFrameMatrix.SetDatas(Datas: array of byte);
var
    Len: Integer;
begin
    Len := Min(Length(Datas), MAX_CAN_DATA_LEN);

    Move(Datas[0], mDatas[0], Len);

    UpdateView(GetStartByte);
end;

procedure TCanFrameMatrix.GetDatas(var Datas: array of byte);
var
    Len: Integer;
begin
    UpdateData(GetStartByte);

    Len := Min(Length(Datas), MAX_CAN_DATA_LEN);

    Move(mDatas[0], Datas[0], Len);
end;

function TCanFrameMatrix.GetStartBit: Integer;
begin
    Result := GetStartByte * 8;
end;

function TCanFrameMatrix.GetStartByte: Integer;
begin
    Result := tcOffset.TabIndex * 8;
end;

procedure TCanFrameMatrix.SetOnColor(Color: TColor);
var
    i: integer;
begin
    for i := 0 to 7 do
    begin
        mLeds[i].OnColor := Color;
    end;
end;

procedure TCanFrameMatrix.tcOffsetChange(Sender: TObject);
begin
    DisplayVBitOrds(GetStartBit);
    UpdateView(GetStartByte);
end;

procedure TCanFrameMatrix.tcOffsetChanging(Sender: TObject; var AllowChange: Boolean);
begin
    UpdateData(GetStartByte);
end;

procedure TCanFrameMatrix.tcOffsetDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
    TabText: string;
    BndRect: TRect;
begin
    with tcOffset.Canvas do
    begin
        if Active then
        begin
            Brush.Color := clBlue;
            Font.Color := clWhite;
        end
        else
        begin
            Brush.Color := clBtnFace;
            Font.Color := clBlack;
        end;

        FillRect(Rect);
        TabText := tcOffset.Tabs[TabIndex];
        BndRect := Rect;
        DrawText(tcOffset.Canvas.Handle, PWideChar(TabText), Length(TabText), BndRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;

end;

procedure TCanFrameMatrix.NewWindowProc(var Message: TMessage);
const
    WM_MOUSEWHEEL = $020A;
var
    WheelDelta: Integer;
begin
    if Message.Msg = WM_MOUSEWHEEL then
    begin
        WheelDelta := SmallInt(Message.WParam shr 16);

        UpdateData(GetStartByte);

        if WheelDelta > 0 then
        begin
            if tcOffset.TabIndex > 0 then
            begin
                tcOffset.TabIndex := tcOffset.TabIndex - 1;
            end;
        end
        else if WheelDelta < 0 then
        begin
            if tcOffset.TabIndex < tcOffset.Tabs.Count - 1 then
            begin
                tcOffset.TabIndex := tcOffset.TabIndex + 1;
            end;
        end;

        DisplayVBitOrds(GetStartBit);
        UpdateView(GetStartByte);

    end;

    mOldWindowProc(Message);
end;

end.

