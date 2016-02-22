function shift = strategy_trend(dayIndex, status, historyClose, direction, Compare_short_long, MA_SHORT, MA_LONG)

% 若发出买入信号，则shift = 1，
% 若发出卖出信号，则shift = -1,
% 若未发出买入或卖出信号，则shift = 0

parameter; %输入参数

if dayIndex >= SHORT_TIME + PREMISE_DAY && dayIndex >= LONG_TIME+PREMISE_DAY
    if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        shift = 0;
        return;
    end
    
    switch status
        case '空仓'
            if length( find ( Compare_short_long(dayIndex - 3 + 1 : dayIndex) == 1 ) ) == 3 ...
                    || (MA_SHORT(dayIndex) > MA_SHORT(dayIndex-1) ...
                    && MA_SHORT(dayIndex-1) > MA_SHORT(dayIndex-2) ...
                    && MA_SHORT(dayIndex-2) < MA_SHORT(dayIndex-3) )
                shift = 1;
            else
                shift = 0;
            end
        case '开仓'
            if length( find ( Compare_short_long(dayIndex - 3 + 1 : dayIndex) == 0 ) ) == 3 ...
                    || (MA_SHORT(dayIndex) < MA_SHORT(dayIndex-1) ...
                    && MA_SHORT(dayIndex-1) < MA_SHORT(dayIndex-2)...
                    && MA_SHORT(dayIndex-2) > MA_SHORT(dayIndex-3) )
                shift = -1;
            else
                shift = 0;
            end
    end
end
end

