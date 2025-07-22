unit StateDefineUnit;

interface
uses
  TypInfo;

type
    TWorkState = (  _WS_IDLE,
                    _WS_START,
                    _WS_DELETE_LIMIT,
                    _WS_ALIGN_LODING_POS,
                    _WS_WAIT_WEIGHT_LOADING,
                    _WS_MOVE_SLIDE,
                    _WS_SET_LIMIT_1,
                    _WS_SET_LIMIT_2,
                    _WS_BURNISHING,
                    _WS_READ_LIMIT,

                    _WS_MOVE_TO_UNLOADING_POS,      // 부하 언로딩위치로
                    _WS_WAIT_UNLOADING_DONE,
                    _WS_MOVE_TO_D_POS, // 납품위치로
                    _WS_WAIT_ECU_SAVE_TIME,
                    _WS_WAIT_ALL_TEST_END,
                    _WS_SAVE_DATA,
                    _WS_WAIT_POP_SEND,
                    _WS_END_OF_TEST, // 완료 대기

                    _WS_ERROR, // 에러 전송
                    _WS_OUTPOS_ER,
                    _WS_ERROR_IDLE // 에러 대기
                );

function EnumToString(TypeInfo: PTypeInfo; EnumValue: Integer): string;

function WorkStateToString(State: TWorkState): string;

implementation
uses
    SysUtils;

function EnumToString(TypeInfo: PTypeInfo; EnumValue: Integer): string;
begin
    try
        Result := GetEnumName(TypeInfo, EnumValue);
        if Result = '' then
            Result := 'Unknown(' + IntToStr(EnumValue) + ')';
    except
        Result := 'Error(' + IntToStr(EnumValue) + ')';
    end;
end;

function WorkStateToString(State: TWorkState): string;
begin
    Result := EnumToString(TypeInfo(TWorkState), Ord(State));
end;

end.

