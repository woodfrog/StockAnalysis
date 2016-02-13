function shift = strategy_oscil(shift, dayIndex, status, historyClose, MA_SHORT, MA_LONG)
%输入参数
parameter;

%% 判断部分
if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME + OBSERVE_TIME
    
    if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return;
    end
    
    switch status
        case '空仓'
            if MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)
                %短期线从上往下突破长期线，说明近期价格下降
                shift = 1;  %认为大盘振荡，此时买入
            else
                shift = 0;
            end
        case '开仓'
            if MA_SHORT(dayIndex) > MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) <= MA_LONG(dayIndex-1)  %近期价格上涨
                shift = -1; %发出卖出信号
            else
                shift = 0;
            end
    end
end
end

