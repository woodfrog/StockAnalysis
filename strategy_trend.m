function [shift,status] = strategy_trend(shift,dayIndex, volIndex, status,historyClose,...
                          VOL_AVR, direction, Compare_short_long, MA_SHORT, MA_LONG)
                            
%����Ϊ���Ĳ���
%�������
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
                 %ֻ�е�����VOL_SELL_DAY��������������ʱ�����Ը��ݳɽ����仯ѡ������
             else
                 volFlag = 0;
             end
         end
     end
     
     switch status
         case '�ղ�'
%%
             if strcmp(direction, 'up') == 1 && historyClose(dayIndex) > historyClose(dayIndex-9)... 
               || volFlag == 1  % ��������5����߸��ڳ��ߣ�����һ��ļ۸����10��ǰ, ���߳ɽ������������ź�
                 shift=1;
                 status='����';    
             end 
             
         case '����'
             if length( find(Compare_short_long(dayIndex - 2: dayIndex) == 0 )) >= 3 ...
                  || volFlag == 1  %�ֲ�����£���������3����ڳ��ߣ����߳ɽ������������ź�ʱ������
                 shift=0;
                 status='�ղ�';
             end
     end 
 end
end

