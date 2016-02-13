function [ maprice ] = MA( time,history_close)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
if time > length(history_close)
    fprintf('历史数据不足！请检查！');
    return;
end

    maprice=sum(history_close(length(history_close)-time+1:length(history_close)))/time;

end

