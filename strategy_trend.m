function shift = strategy_trend(shift,dayIndex, status, historyClose, direction, Compare_short_long, MA_SHORT, MA_LONG)

% 若发出买入信号，则shift = 1，
% 若发出卖出信号，则shift = -1,
% 若未发出买入或卖出信号，则shift = 0

parameter; %输入参数

if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME+OBSERVE_TIME
    if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return;
    end
    
    switch status
        case '空仓'
            if strcmp(direction, 'up') == 1 %上升趋势
                if historyClose(dayIndex) > historyClose(dayIndex-9) ...
                        || MA_SHORT(dayIndex) > MA_SHORT(dayIndex-1) && MA_LONG(dayIndex) < MA_LONG(dayIndex-1)
                    %处于连续5天短线高于长线，且这一天的价格高于10天前, 或者成交量发出买入信号
                    shift = 1;
                else      
                    shift = 0;
                end
            else  % 下降趋势
                if MA_SHORT(dayIndex) > MA_SHORT(dayIndex-1) && MA_LONG(dayIndex) < MA_LONG(dayIndex-1) ...
                        || length( find(Compare_short_long(dayIndex - 2: dayIndex) == 1 )) >= 3
                    shift = 1;
                else
                    shift = 0;
                end
            end
            
        case '开仓'
            if strcmp(direction, 'up') == 1  %上升趋势
                if length( find(Compare_short_long(dayIndex - 2: dayIndex) == 0 )) >= 3 ...
                    || MA_SHORT(dayIndex) < MA_SHORT(dayIndex-1) && MA_LONG(dayIndex) > MA_LONG(dayIndex-1)
                    %持仓情况下，短线连续3天低于长线，或者成交量发出卖出信号时，卖出
                    shift = -1;
                else
                    shift = 0;
                end
            else
                shift = -1; 
            end
    end
end
end

