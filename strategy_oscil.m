function [shift,status] = strategy_oscil(shift, dayIndex, volIndex, status, historyClose, ...
                            VOL_AVR, MA_SHORT, MA_LONG, NET, NET_IN, NET_OUT)
%�������
parameter;

%% ��̬��������
 persistent waitFlag ; %������Ǵ�ʱ�Ƿ���ƽ��ǰ�Ĺ���״̬��,�˴���Ҫ��̬����
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
 %% �жϲ���
 if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME + OBSERVE_TIME && waitFlag == 0
         
     if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return; 
     end
     
     switch status
         case '�ղ�'
             
             if MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1) ...
                 || volFlag == 1   %�����ߴ�������ͻ�Ƴ����ߣ�˵�����ڼ۸��½�
                 shift=1;
                 status='����';   %��Ϊ�����񵴣���ʱ����
             end
         case '����'
             %����ֹ��
%                  netHighPoint =  max(NET);
%                  netToday = NET_IN(dayIndex-1) * historyClose(dayIndex)/ historyClose(dayIndex-1) + NET_OUT(dayIndex);
%                  if netToday < 
%                      shift = 0;
%                      status='�ղ�';
%                      return;
%                  end
             %������ֹ��
             
             if volFlag == 1
                 shift = 0;
                 status = '�ղ�';
                 waitFlag = 0;
                 breakFlag = 0;
             elseif MA_SHORT(dayIndex) > MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) <= MA_LONG(dayIndex-1)  %���ڼ۸�����
                 MINIMUM_IN_RECENT = min(historyClose( dayIndex - RECENT_DAY + 1 : dayIndex));
                 waitProfitRate = (historyClose(dayIndex)-MINIMUM_IN_RECENT)/MINIMUM_IN_RECENT; 
                 incrementValue = 0.5 * waitProfitRate;
                 waitProfitRate = waitProfitRate + incrementValue; 
                 waitFlag = 1; %����������ȴ�����ʱ��
             end
     end 
 end
 %% �������֣�ѡ���ʵ�ʱ��ֹӯ
 if waitFlag == 1 && breakFlag ==0 %��ʱ�ڳֲֹ�����״̬�У��ȴ�������ʱ��
        temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
        if temp >= waitProfitRate
            waitProfitRate = waitProfitRate + incrementValue;
            breakFlag = 1;
        elseif MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)
            shift = 0;
            status = '�ղ�';
            waitFlag = 0;
            breakFlag = 0;
        end
 elseif waitFlag ==1 && breakFlag == 1 %����״̬����֮ǰ������ͻ��
        temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
        if temp >= waitProfitRate
            waitProfitRate = waitProfitRate + incrementValue;
            breakFlag = 1;
        elseif temp <= waitProfitRate - incrementValue
            shift = 0;
            status = '�ղ�';
            waitFlag = 0;
            breakFlag = 0;
        end
 end
 
 end

