function shift = strategy_trend(shift,dayIndex, status, historyClose, direction, Compare_short_long, MA_SHORT, MA_LONG)

% �����������źţ���shift = 1��
% �����������źţ���shift = -1,
% ��δ��������������źţ���shift = 0

parameter; %�������

if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME+OBSERVE_TIME
    if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return;
    end
    
    switch status
        case '�ղ�'
            if strcmp(direction, 'up') == 1 %��������
                if historyClose(dayIndex) > historyClose(dayIndex-9) ...
                        || MA_SHORT(dayIndex) > MA_SHORT(dayIndex-1) && MA_LONG(dayIndex) < MA_LONG(dayIndex-1)
                    %��������5����߸��ڳ��ߣ�����һ��ļ۸����10��ǰ, ���߳ɽ������������ź�
                    shift = 1;
                else      
                    shift = 0;
                end
            else  % �½�����
                if MA_SHORT(dayIndex) > MA_SHORT(dayIndex-1) && MA_LONG(dayIndex) < MA_LONG(dayIndex-1) ...
                        || length( find(Compare_short_long(dayIndex - 2: dayIndex) == 1 )) >= 3
                    shift = 1;
                else
                    shift = 0;
                end
            end
            
        case '����'
            if strcmp(direction, 'up') == 1  %��������
                if length( find(Compare_short_long(dayIndex - 2: dayIndex) == 0 )) >= 3 ...
                    || MA_SHORT(dayIndex) < MA_SHORT(dayIndex-1) && MA_LONG(dayIndex) > MA_LONG(dayIndex-1)
                    %�ֲ�����£���������3����ڳ��ߣ����߳ɽ������������ź�ʱ������
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

