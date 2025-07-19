{
    // ������Ʈ ����, 1�� �������� ����
}
unit SeatMotorType;

interface


type

    TMotorORD = (tmSlide, tmTilt, tmHeight, tmLegSupt, tmSwivel);  // tmLegSupt => tmCushExt/tmLegRest), tmSP1�� Ű���� ���� �ʼ�
    TMotorWayORD = (twForw, twBack);    // ������ ����
    TMotorDir = TMotorWayOrd;
    TMemoryORD = (meMEM1, meMEM2, meKEY_ON, meKEY_OFF);
    TSeatMotorTestStatus =
        (msStart, msStop, msLimitReaded, msTestEnd, msError, msBurnishCycle, msLimitSetStart,msSlideLimitStart,
        msTiltLimitStart, msHeightLimitStart, msCushExtStart, mReclLimitStart, msBurnishStart, msBurnishStop);
        // ��/���� ����, ��/���� ����, ����Ʈ���� �б� ����/�Ϸ�,  ����Ϸ�, �����߻�, ���Ͻ� 1ȸ �ֱ� �Ϸ�, ����Ʈ ���� �Ϸ�

    // �����˻�
    TVbStatus = (vbERROR, vbNONE, vbREADY, vbRESET, vbSTART, vbTESTER, vbRUN, vbsndSTOP, vbSTOP, vbReqRST, vbEND);
    TVbObject = (voMAIN, voSLIDE, voLiftF, voLiftR, voCushExt);


    function MtrOrdHi: TMotorOrd;                       // �ʼ� ���� üũ!!!
    function GetMotorName(aMotor: TMotorORD; HasLegrest: Boolean = False): string;
    function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;

const
    _MOTOR_ID_STR: array[TMotorOrd] of string = ('Slide', 'Height', 'Tilt', 'CushExt', 'Swivel');         // DataUnitHelper�뵵 etc...
    _MOTOR_DIR_STR: array[TMotorDir] of string = ('Fw', 'Bw');


implementation
uses
    LangTran, SeatMotor;

function MtrOrdHi: TMotorOrd;
begin
    Result := tmSWIVEL;       // Project ����! ����!!
end;

function GetMotorDirStr(MtrID: TMotorORD; Dir: TMotorDir): string;
begin
    case MtrID of

        tmSlide, tmLegSupt:
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

function GetMotorName(aMotor: TMotorORD; HasLegrest: Boolean): string; // class TSeatMotor.GetMotorName���� ..
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
