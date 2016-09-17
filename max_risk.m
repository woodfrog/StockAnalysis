 % 根据提供的净值计算最大回撤率
 % 返回值： 最大回撤率
 % 参数  ： 1维向量，回测中每天的净值
function MAX_RISK = max_risk(NET)  

maxNet = NET(1);
MAX_RISK = 0;

for i = 2 : length(NET)
    if NET(i) > maxNet
        maxNet = NET(i);
        continue;
    end
    tempRisk = (maxNet-NET(i)) / maxNet;
    if tempRisk > MAX_RISK
        MAX_RISK = tempRisk;
    end
end

end