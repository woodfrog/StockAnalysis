function shift = strategy_volume (dayIndex, volIndex, VOL_AVR, historyClose)
% 若发出买入信号，则shift = 1，
% 若发出卖出信号，则shift = -1,
% 若未发出买入或卖出信号，则shift = 0
parameter;

if historyClose(dayIndex) >=  historyClose(dayIndex-1) %当天收盘价较前一天上涨
    
    volBuyFlag = 1;
    
    if volIndex <= 4 + VOL_BUY_DAY -1
        volBuyFlag = 0;
    else
        if VOL_AVR(volIndex) >= VOL_JUDGE_UP_1 * VOL_AVR(volIndex-1) ...
                && VOL_AVR(volIndex) >= VOL_JUDGE_UP_1 * VOL_AVR(volIndex-2)...
                && VOL_AVR(volIndex) >= VOL_JUDGE_UP_1 * VOL_AVR(volIndex-3)...
                && VOL_AVR(volIndex) >= VOL_JUDGE_UP_1 * VOL_AVR(volIndex-4)
            volBuyFlag = 1;
        else

                for i = (volIndex - VOL_BUY_DAY + 1) : volIndex
                    if VOL_AVR(i) > VOL_JUDGE_UP_2 * VOL_AVR(i-1) && VOL_AVR(i) > VOL_JUDGE_UP_2 * VOL_AVR(i-2)...
                            || VOL_AVR(i) > VOL_JUDGE_UP_2 * VOL_AVR(i-3) && VOL_AVR(i) > VOL_JUDGE_UP_2 * VOL_AVR(i-4)
                        %只有当连续VOL_BUY_DAY个x满足以上条件时，策略根据成交量变化选择买入
                    else
                        volBuyFlag = 0;
                    end
                end

        end
    end
    
    shift = volBuyFlag;
    
else  %当天收盘价较前一天下跌
    volSellFlag = 1;
    
    if volIndex <= 4 + VOL_SELL_DAY -1
        volSellFlag = 0;
    else
        if VOL_AVR(volIndex) >= VOL_JUDGE_DOWN_1 * VOL_AVR(volIndex-1)...
                && VOL_AVR(volIndex) >= VOL_JUDGE_DOWN_1 * VOL_AVR(volIndex-2)...
                && VOL_AVR(volIndex) >= VOL_JUDGE_DOWN_1 * VOL_AVR(volIndex-3)...
                && VOL_AVR(volIndex) >= VOL_JUDGE_DOWN_1 * VOL_AVR(volIndex-4)
            volSellFlag = 1;
        else
                for i = (volIndex - VOL_SELL_DAY + 1) : volIndex
                    if VOL_AVR(i) > VOL_JUDGE_DOWN_2 * VOL_AVR(i-1) && VOL_AVR(i) > VOL_JUDGE_DOWN_2 * VOL_AVR(i-2)...
                            || VOL_AVR(i) > VOL_JUDGE_DOWN_2 * VOL_AVR(i-3) && VOL_AVR(i) > VOL_JUDGE_DOWN_2 * VOL_AVR(i-4)
                        %只有当连续VOL_BUY_DAY个x满足以上条件时，策略根据成交量变化选择买入
                    else
                        volSellFlag = 0;
                    end
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