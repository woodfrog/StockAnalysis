function shift = strategy_volume (dayIndex, volIndex, VOL_AVR, VOL_RECORD, VOL_START_DAY, historyClose)
% �����������źţ���shift = 1��
% �����������źţ���shift = -1,
% ��δ��������������źţ���shift = 0
parameter;
VOL_BUY_DAY = 3;     % ������3��������Ӧ����ʱ���������ź�
VOL_SELL_DAY = 2;    % ������2��������Ӧ����ʱ���������ź�
VOL_JUDGE_UP_2 = 0.7;
VOL_JUDGE_1 = 0.3;
VOL_JUDGE_2 = 1.4;

if historyClose(dayIndex) >=  historyClose(dayIndex-1) %�������̼۽�ǰһ������
    volBuyFlag = 1;
    if volIndex <= 4 + VOL_BUY_DAY -1
        volBuyFlag = 0;
    else
        if VOL_AVR(volIndex-1) <= VOL_JUDGE_1 * VOL_AVR(volIndex-3) ...
                && VOL_AVR(volIndex-1) <= VOL_JUDGE_1 * VOL_AVR(volIndex-2)...
                && VOL_AVR(volIndex) >= VOL_JUDGE_2 * VOL_AVR(volIndex-1)...
                && historyClose(dayIndex) >= historyClose(VOL_START_DAY(volIndex-1))
            volBuyFlag = 1;
        else
            for i = (dayIndex - VOL_BUY_DAY + 1) : dayIndex
                if (VOL_AVR(VOL_RECORD(i)) > VOL_JUDGE_UP_2 * VOL_AVR(VOL_RECORD(i) -1)...
                        && VOL_AVR(VOL_RECORD(i)) > VOL_JUDGE_UP_2 * VOL_AVR(VOL_RECORD(i)-2) )...
                    %ֻ�е�����VOL_BUY_DAY��������������ʱ�����Ը��ݳɽ����仯ѡ������
                else
                    volBuyFlag = 0;
                end
            end
        end
    end
    
    shift = volBuyFlag;
    
else  %�������̼۽�ǰһ���µ�
    if volIndex <= 4 + VOL_SELL_DAY -1
        volSellFlag = 0;
    else
        if VOL_AVR(volIndex-1) <= VOL_JUDGE_1 * VOL_AVR(volIndex-3)...
                && VOL_AVR(volIndex-1) <= VOL_JUDGE_1 * VOL_AVR(volIndex-2)...
                && VOL_AVR(volIndex) >= VOL_JUDGE_2 * VOL_AVR(volIndex-1)...
                && historyClose(dayIndex) <= historyClose(VOL_START_DAY(volIndex-1))
            volSellFlag = 1;
        else
            volSellFlag = 0;
        end
    end
    
    if volSellFlag == 1
        shift = -1;
    else
        shift = 0;
    end
end

end