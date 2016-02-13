function shift = strategy_oscil(shift, dayIndex, status, historyClose, MA_SHORT, MA_LONG)
%�������
parameter;

%% �жϲ���
if dayIndex >= SHORT_TIME + OBSERVE_TIME && dayIndex >= LONG_TIME + OBSERVE_TIME
    
    if MA_SHORT(dayIndex) == 0 || MA_SHORT(dayIndex-1) == 0 || MA_LONG(dayIndex) == 0 ||MA_LONG(dayIndex-1) == 0
        return;
    end
    
    switch status
        case '�ղ�'
            if MA_SHORT(dayIndex) < MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) >= MA_LONG(dayIndex-1)
                %�����ߴ�������ͻ�Ƴ����ߣ�˵�����ڼ۸��½�
                shift = 1;  %��Ϊ�����񵴣���ʱ����
            else
                shift = 0;
            end
        case '����'
            if MA_SHORT(dayIndex) > MA_LONG(dayIndex) && MA_SHORT(dayIndex-1) <= MA_LONG(dayIndex-1)  %���ڼ۸�����
                shift = -1; %���������ź�
            else
                shift = 0;
            end
    end
end
end

