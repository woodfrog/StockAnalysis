function [ maprice ] = MA( time,history_close)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
if time > length(history_close)
    fprintf('��ʷ���ݲ��㣡���飡');
    return;
end

    maprice=sum(history_close(length(history_close)-time+1:length(history_close)))/time;

end

