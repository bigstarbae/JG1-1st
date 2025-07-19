{
    // 프로젝트 종속, 2열 맞춤
}
unit SeatMotorType;

interface


type

    TMotorORD = (tmSlide, tmRecl, tmCushTilt, tmWalkinUpTilt, tmShoulder, tmRelax, tmHeadrest, tmLongSlide);
    TMotorWayORD = (twForw, twBack);
    TMotorDir = TMotorWayOrd;
    TMemoryORD = (meMEM1, meMEM2, meKEY_ON, meKEY_OFF);
    TSeatMotorTestStatus =
        (msStart, msStop, msLimitReaded, msTestEnd, msError, msBurnishStart, msBurnishEnd, msBurnishCycle, msLimitSetStart, msLimitSetEnd);
        // 전/후진 시작, 전/후진 정지, 리미트상태 읽기 시작/완료,  시험완료, 에러발생, 버니싱 1회 주기 완료, 리미트 설정 완료

    // 진동검사
    TVbStatus = (vbERROR, vbNONE, vbREADY, vbRESET, vbSTART, vbTESTER, vbRUN, vbsndSTOP, vbSTOP, vbReqRST, vbEND);
    TVbObject = (voMAIN, voSLIDE, voLiftF, voLiftR, voCushExt);


    function MtrOrdHi: TMotorOrd;                       // 필수 구현 체크!!!
    function GetMotorName(aMotor: TMotorORD): string;
    function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;


const
    _MOTOR_ID_STR: array[TMotorOrd] of string = ('Slide', 'Recline', 'CushTilt', 'WalkinTilt', 'Shoulder', 'Relax', 'Headrest', 'LongSlide');         // DataUnitHelper용도 etc...
    _MOTOR_DIR_STR: array[TMotorDir] of string = ('Fw', 'Bw');


implementation
uses
    LangTran;

function MtrOrdHi: TMotorOrd;
begin
    Result := tmLongSlide;       // Project 종속! 주의!!
end;

function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;
begin
    case MtrID of

        tmLongSlide, tmSlide:
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

function GetMotorName(aMotor: TMotorORD): string;
begin
    case aMotor of
        tmSlide:
            Result := 'SLIDE';
        tmRecl:
            Result := 'RECL';
        tmCushTilt:
            Result := 'C.Tilt';
        tmWalkinUpTilt:
            Result := 'W.UpTilt';
        tmShoulder:
            Result := 'Shoulder';
        tmRelax:
            Result := 'Relax';
        tmHeadrest:
            Result := 'Headrest';
        tmLongSlide:
            Result := 'LongSlide';
    end;
end;



end.
