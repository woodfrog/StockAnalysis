function shift = strategy_volume (dayIndex, volIndex, VOL_AVR, VOL_RECORD, VOL_START_DAY, historyClose)
% 若发出买入信号，则shift = 1，
% 若发出卖出信号，则shift = -1,
% 若未发出买入或卖出信号，则shift = 0
parameter;
VOL_BUY_DAY = 3;     % 当连续3天满足相应条件时发出买入信号
VOL_SELL_DAY = 2;    % 当连续2天满足相应条件时发出卖出信号
VOL_JUDGE_UP_2 = 0.7;
VOL_JUDGE_1 = 0.3;
VOL_JUDGE_2 = 1.4;

if historyClose(dayIndex) >=  historyClose(dayIndex-1) %当天收盘价较前一天上涨
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
                    %只有当连续VOL_BUY_DAY天满足以上条件时，策略根据成交量变化选择买入
                else
                    volBuyFlag = 0;
                end
            end
        end
    end
    
    shift = volBuyFlag;
    
else  %当天收盘价较前一天下跌
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