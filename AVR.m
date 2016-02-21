function [ maprice ] = AVR( range, elements)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
if range > length(elements)
    fprintf('历史数据不足！请检查！');
    return;
end

    maprice=sum(elements(length(elements)-range+1:length(elements)))/range;

end

