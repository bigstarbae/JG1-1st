{
    // ������Ʈ ����, 2�� ����
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
        // ��/���� ����, ��/���� ����, ����Ʈ���� �б� ����/�Ϸ�,  ����Ϸ�, �����߻�, ���Ͻ� 1ȸ �ֱ� �Ϸ�, ����Ʈ ���� �Ϸ�

    // �����˻�
    TVbStatus = (vbERROR, vbNONE, vbREADY, vbRESET, vbSTART, vbTESTER, vbRUN, vbsndSTOP, vbSTOP, vbReqRST, vbEND);
    TVbObject = (voMAIN, voSLIDE, voLiftF, voLiftR, voCushExt);


    function MtrOrdHi: TMotorOrd;                       // �ʼ� ���� üũ!!!
    function GetMotorName(aMotor: TMotorORD): string;
    function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;


const
    _MOTOR_ID_STR: array[TMotorOrd] of string = ('Slide', 'Recline', 'CushTilt', 'WalkinTilt', 'Shoulder', 'Relax', 'Headrest', 'LongSlide');         // DataUnitHelper�뵵 etc...
    _MOTOR_DIR_STR: array[TMotorDir] of string = ('Fw', 'Bw');


implementation
uses
    LangTran;

function MtrOrdHi: TMotorOrd;
begin
    Result := tmLongSlide;       // Project ����! ����!!
end;

function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;
begin
    case MtrID of

        tmLongSlide, tmSlide:
            begin
                case Dir of
                    twForw:
                        Result := _TR('����');
                    twBack:
                        Result := _TR('����');
                end
            end
        else
        begin
            case Dir of
                twForw:
                    Result := _TR('���');
                twBack:
                    Result := _TR('�ϰ�');
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
