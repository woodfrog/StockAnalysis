function shift = strategy_volume ( dayIndex, volIndex, VOL_AVR, historyClose)
% �����������źţ���shift = 1��
% �����������źţ���shift = -1,
% ��δ��������������źţ���shift = 0
parameter;

if historyClose(dayIndex) >=  historyClose(dayIndex-1)
    
    volBuyFlag = 1;
    
    if volIndex <= 4 + VOL_BUY_DAY -1
        volBuyFlag = 0;
    else
        for i = (volIndex - VOL_BUY_DAY + 1) : volIndex
            if VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-1) && VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-2)...
                    || VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-3) && VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-4)
                %ֻ�е�����VOL_BUY_DAY��x������������ʱ�����Ը��ݳɽ����仯ѡ������
            else
                volBuyFlag = 0;
            end
        end
    end
    
    shift = volBuyFlag;
    
else
    volSellFlag = 1;
    
    if volIndex <= 4 + VOL_SELL_DAY -1
        volSellFlag = 0;
    else
        for i = (volIndex - VOL_SELL_DAY + 1) : volIndex
            if VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-1) && VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-2)...
                    || VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-3) && VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-4)
                %ֻ�е�����VOL_BUY_DAY��x������������ʱ�����Ը��ݳɽ����仯ѡ������
            else
                volSellFlag = 0;
            end
        end
    end    
    
    if volSellFlag == 1
        shift = -1;
    else
        shift = 0;
    end 
end

end