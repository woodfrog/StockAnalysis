function [ maprice ] = AVR( range, elements)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
if range > length(elements)
    fprintf('��ʷ���ݲ��㣡���飡');
    return;
end

    maprice=sum(elements(length(elements)-range+1:length(elements)))/range;

end

