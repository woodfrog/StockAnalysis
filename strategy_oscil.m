function [shift, waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT  ] ...
        = strategy_oscil(shift, dayIndex, status, historyClose, MA_SHORT, MA_LONG, STATE_RECORD, ...
        waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT )

% �����������źţ���shift = 1��
% �����������źţ���shift = -1,
% ��δ��������������źţ���shift = 0

%�������
parameter;

%% �жϲ���
if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME + OBSERVE_TIME 
    
    if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return;
    end
    
    if waitFlag == 0  % û�д���ֹӯ�Ĺ���״̬��   
        switch status
            case '�ղ�'
                if MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)...
                        && length( find ( STATE_RECORD(dayIndex - 7 + 1 : dayIndex) == 0 ) ) >= 2 
                    %�����ߴ�������ͻ�Ƴ����ߣ�˵�����ڼ۸��½�
                    shift = 1;  %��Ϊ�����񵴣���ʱ����
                else
                    shift = 0;
                end
            case '����'
                if MA_SHORT(dayIndex) > MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) <= MA_LONG(dayIndex-1)  %���ڼ۸�����
                    MINIMUM_IN_RECENT = min(historyClose( dayIndex - RECENT_DAY + 1 : dayIndex));
                    waitProfitRate = (historyClose(dayIndex)-MINIMUM_IN_RECENT)/MINIMUM_IN_RECENT;
                    incrementValue = 0.1 * waitProfitRate; %ÿһ��ֹӯ�ߵ�����
                    waitProfitRate = waitProfitRate + incrementValue;
                    waitFlag = 1; %�����������ʱ�Ȳ����������źţ����ǵȴ�����ʱ��
                    shift = 0;
                else
                    shift = 0;
                end
        end
    else  %����ֹӯ�Ĺ���״̬��, ��waitFlag == 1
        if breakFlag == 0 %��û��ͻ�Ƶ�һ��ֹӯ��
            temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
            if temp >= waitProfitRate
                waitProfitRate = waitProfitRate + incrementValue;
                breakFlag = 1;
                shift = 0; 
            elseif MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)
                shift = -1; %���������ź�
                waitFlag = 0;
                waitProfitRate = 0;
                breakFlag = 0;
                incrementValue = 0;
                MINIMUM_IN_RECENT = 0;
            else
                shift = 0;
            end
        else %�Ѿ�ͻ�ƹ�����һ��ֹӯ��,��breakFlag == 1
            temp = (historyClose(dayIndex) - MINIMUM_IN_RECENT) / MINIMUM_IN_RECENT;
            if temp >= waitProfitRate
                waitProfitRate = waitProfitRate + incrementValue;
                breakFlag = 1;
                shift = 0;
            elseif temp <= waitProfitRate - incrementValue   %���䵽֮ǰһ��ֹӯ�ߵ�λ��
                shift = -1; %���������ź�
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

