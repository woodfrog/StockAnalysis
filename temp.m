%% 静态变量定义
 persistent waitFlag ; %用来标记此时是否处在平仓前的观望状态中,此处需要静态变量
 persistent waitProfitRate;
 persistent incrementValue;
 persistent MINIMUM_IN_RECENT;
 persistent breakFlag;
 if isempty(waitFlag)
    waitFlag = 0;
 end
 if isempty(waitProfitRate)
    waitProfitRate = 0;
 end
 if isempty(MINIMUM_IN_RECENT)
    MINIMUM_IN_RECENT = 0;
 end
  if isempty(incrementValue)
    incrementValue = 0;
  end
  if isempty(breakFlag)
    breakFlag = 0;
  end
  
  %%
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
  
%%
             %绝对止损
%                  netHighPoint =  max(NET);
%                  netToday = NET_IN(dayIndex-1) * historyClose(dayIndex)/ historyClose(dayIndex-1) + NET_OUT(dayIndex);
%                  if netToday < 
%                      shift = 0;
%                      status='空仓';
%                      return;
%                  end
             %以上是止损
%%
 %% 观望部分，选择适当时机止盈
 if waitFlag == 1 && breakFlag ==0 %此时在持仓观望的状态中，等待卖出的时机
        temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
        if temp >= waitProfitRate
            waitProfitRate = waitProfitRate + incrementValue;
            breakFlag = 1;
        elseif MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)
            shift = 0;
            status = '空仓';
            waitFlag = 0;
            breakFlag = 0;
        end
 elseif waitFlag ==1 && breakFlag == 1 %观望状态，且之前发生过突破
        temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
        if temp >= waitProfitRate
            waitProfitRate = waitProfitRate + incrementValue;
            breakFlag = 1;
        elseif temp <= waitProfitRate - incrementValue
            shift = 0;
            status = '空仓';
            waitFlag = 0;
            breakFlag = 0;
        end
 end