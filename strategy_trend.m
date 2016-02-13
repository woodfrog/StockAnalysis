function [shift,status] = strategy_trend(shift,dayIndex, volIndex, status,historyClose,...
                          VOL_AVR, direction, Compare_short_long, MA_SHORT, MA_LONG)
                            
%以下为核心策略
%输入参数
parameter;
 
 if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME+OBSERVE_TIME
     if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return; 
     end
     
     volFlag = 1;
     if volIndex <= 4 + VOL_DAY -1
         volFlag = 0;
     else
         for i = (volIndex - VOL_DAY + 1) : volIndex
             if VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-1) && VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-2)...
                     || VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-3) && VOL_AVR(i) > VOL_JUDGE * VOL_AVR(i-4)
                 %只有当连续VOL_SELL_DAY天满足以上条件时，策略根据成交量变化选择卖出
             else
                 volFlag = 0;
             end
         end
     end
     
     switch status
         case '空仓'
%%
             if strcmp(direction, 'up') == 1 && historyClose(dayIndex) > historyClose(dayIndex-9)... 
               || volFlag == 1  % 处于连续5天短线高于长线，且这一天的价格高于10天前, 或者成交量发出买入信号
                 shift=1;
                 status='开仓';    
             end 
             
         case '开仓'
             if length( find(Compare_short_long(dayIndex - 2: dayIndex) == 0 )) >= 3 ...
                  || volFlag == 1  %持仓情况下，短线连续3天低于长线，或者成交量发出卖出信号时，卖出
                 shift=0;
                 status='空仓';
             end
     end 
 end
end

