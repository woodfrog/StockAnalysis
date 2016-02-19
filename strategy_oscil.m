function [shift, waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT  ] ...
        = strategy_oscil(shift, dayIndex, status, historyClose, MA_SHORT, MA_LONG, STATE_RECORD, ...
        waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT )

% 若发出买入信号，则shift = 1，
% 若发出卖出信号，则shift = -1,
% 若未发出买入或卖出信号，则shift = 0

%输入参数
parameter;

%% 判断部分
if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME + OBSERVE_TIME 
    
    if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return;
    end
    
    if waitFlag == 0  % 没有处在止盈的观望状态中   
        switch status
            case '空仓'
                if MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)...
                        && length( find ( STATE_RECORD(dayIndex - 7 + 1 : dayIndex) == 0 ) ) >= 2 
                    %短期线从上往下突破长期线，说明近期价格下降
                    shift = 1;  %认为大盘振荡，此时买入
                else
                    shift = 0;
                end
            case '开仓'
                if MA_SHORT(dayIndex) > MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) <= MA_LONG(dayIndex-1)  %近期价格上涨
                    MINIMUM_IN_RECENT = min(historyClose( dayIndex - RECENT_DAY + 1 : dayIndex));
                    waitProfitRate = (historyClose(dayIndex)-MINIMUM_IN_RECENT)/MINIMUM_IN_RECENT;
                    incrementValue = 0.1 * waitProfitRate; %每一格止盈线的增量
                    waitProfitRate = waitProfitRate + incrementValue;
                    waitFlag = 1; %进入观望，此时先不发出卖出信号，而是等待卖出时机
                    shift = 0;
                else
                    shift = 0;
                end
        end
    else  %处在止盈的观望状态中, 即waitFlag == 1
        if breakFlag == 0 %还没有突破第一根止盈线
            temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
            if temp >= waitProfitRate
                waitProfitRate = waitProfitRate + incrementValue;
                breakFlag = 1;
                shift = 0; 
            elseif MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)
                shift = -1; %发出卖出信号
                waitFlag = 0;
                waitProfitRate = 0;
                breakFlag = 0;
                incrementValue = 0;
                MINIMUM_IN_RECENT = 0;
            else
                shift = 0;
            end
        else %已经突破过至少一根止盈线,即breakFlag == 1
            temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
            if temp >= waitProfitRate
                waitProfitRate = waitProfitRate + incrementValue;
                breakFlag = 1;
                shift = 0;
            elseif temp <= waitProfitRate - incrementValue   %回落到之前一根止盈线的位置
                shift = -1; %发出卖出信号
                waitFlag = 0;
                waitProfitRate = 0;
                breakFlag = 0;
                incrementValue = 0;
                MINIMUM_IN_RECENT = 0;
            else
                shift = 0;
            end
        end
        
    end
    
end
end

