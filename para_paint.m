%%set parameter
STOCK_NUM = 002423;     %股票代号
BEGIN_DATE =20110110;   %最小20110104
END_DATE   =20151127;   %最大20151127
BUY_COST   =0.00025;    %买入成本
SELL_COST  =0.00125;    %卖出成本
CASH       =0.03;              %无风险年利率

SHORT_TIME = 5; 
LONG_TIME  = 20;
OBSERVE_TIME = 5;% 观察并判断趋势或振荡所需天数
TREND_JUDGE = 5; % 此处两个都是5，说明判断标准是：5天内，每天的短线都高于/低于
                 %长线
IN_PERCENT = 0.5; %投入交易的百分比
RECENT_DAY = 30; %振荡策略止盈中取极小值的范围

VOL_JUDGE = 1.3; %成交量判断中的倍数
VOL_BUY_DAY = 3; % 成交量判断中，当连续3天满足相应条件时发出买入信号
VOL_SELL_DAY = 2;

