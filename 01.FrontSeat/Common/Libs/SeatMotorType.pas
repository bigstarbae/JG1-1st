{
    // 프로젝트 종속, 1열 백프레임 맞춤
}
unit SeatMotorType;

interface


type

    TMotorORD = (tmSlide, tmTilt, tmHeight, tmLegSupt, tmSwivel);  // tmLegSupt => tmCushExt/tmLegRest), tmSP1은 키워드 유지 필수
    TMotorWayORD = (twForw, twBack);    // 점진적 삭제
    TMotorDir = TMotorWayOrd;
    TMemoryORD = (meMEM1, meMEM2, meKEY_ON, meKEY_OFF);
    TSeatMotorTestStatus =
        (msStart, msStop, msLimitReaded, msTestEnd, msError, msBurnishCycle, msLimitSetStart,msSlideLimitStart,
        msTiltLimitStart, msHeightLimitStart, msCushExtStart, mReclLimitStart, msBurnishStart, msBurnishStop);
        // 전/후진 시작, 전/후진 정지, 리미트상태 읽기 시작/완료,  시험완료, 에러발생, 버니싱 1회 주기 완료, 리미트 설정 완료

    // 진동검사
    TVbStatus = (vbERROR, vbNONE, vbREADY, vbRESET, vbSTART, vbTESTER, vbRUN, vbsndSTOP, vbSTOP, vbReqRST, vbEND);
    TVbObject = (voMAIN, voSLIDE, voLiftF, voLiftR, voCushExt);


    function MtrOrdHi: TMotorOrd;                       // 필수 구현 체크!!!
    function GetMotorName(aMotor: TMotorORD; HasLegrest: Boolean = False): string;
    function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;

const
    _MOTOR_ID_STR: array[TMotorOrd] of string = ('Slide', 'Height', 'Tilt', 'CushExt', 'Swivel');         // DataUnitHelper용도 etc...
    _MOTOR_DIR_STR: array[TMotorDir] of string = ('Fw', 'Bw');


implementation
uses
    LangTran, SeatMotor;

function MtrOrdHi: TMotorOrd;
begin
    Result := tmSWIVEL;       // Project 종속! 주의!!
end;

function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;
begin
    case MtrID of

        tmSlide, tmLegSupt:
            begin
                case Dir of
                    twForw:
                        Result := _TR('전진');
                    twBack:
                        Result := _TR('후진');
                end
            end
        else
        begin
            case Dir of
                twForw:
                    Result := _TR('상승');
                twBack:
                    Result := _TR('하강');
            end;
        end;
    end;
end;

function GetMotorName(aMotor: TMotorORD; HasLegrest: Boolean): string; // class TSeatMotor.GetMotorName으로 ..
begin
    case aMotor of
        tmSlide:
            Result := 'Slide';
        tmHeight:
            Result := 'Height';
        tmTilt:
            Result := 'Tilt';
        tmLegSupt:
            if HasLegrest then
                Result := 'Leg Rest'
            else
                Result := 'Cush.Ext';
        tmSwivel:
            Result := 'Swivel';
    end;
end;



end.
