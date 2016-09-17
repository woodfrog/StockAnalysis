function MAValue=MA(Price,Length)
%---------------------此函数用来计算简单移动平均--------------------------
%----------------------------------编写者--------------------------------
%Lian Xiangbin(连长,785674410@qq.com),DUFE,2014
%----------------------------------参考----------------------------------
%[1]招商证券.基于纯技术指标的多因子选股模型,2014-04-11
%[2]百度百科.移动平均线词条
%----------------------------------简介----------------------------------
%移动平均线是由著名的美国投资专家葛兰碧于20世纪中期提出来的。均线理论是当今应用
%最普遍的技术指标之一，它帮助交易者确认现有趋势、判断将出现的趋势等。简单移动平
%均线是最简单的一种移动平均线，它是某个时间段价格序列的简单平均值。也就是说，
%这个时间段上的每个价格权重相同
%----------------------------------基本用法------------------------------
%1)均线与价格形成金叉买入，形成死叉卖出
%2)短期均线与长期均线形成金叉买入，形成死叉卖出
%----------------------------------调用函数------------------------------
%MAValue=MA(Price,Length)
%----------------------------------参数----------------------------------
%Price-目标价格序列
%Length-计算简单移动平均的周期
%----------------------------------输出----------------------------------
%MAValue：简单移动平均值

MAValue=zeros(length(Price),1);
for i=Length:length(Price)
    MAValue(i)=sum(Price(i-Length+1:i))/Length;
end
MAValue(1:Length-1)=Price(1:Length-1);
end

