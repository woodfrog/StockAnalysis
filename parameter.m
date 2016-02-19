%%set parameter
STOCK_NUM = [600409,000024,000402,000949,600307,600000,000056,002423,002182];     %股票代号
BEGIN_DATE =20110110;   %最小20110104
END_DATE   =20151127;   %最大20151127
BUY_COST   =0.00025;    %买入成本
SELL_COST  =0.00125;    %卖出成本
CASH       =0.03;       %无风险年利率

SHORT_TIME = 5;   %短MA天数
LONG_TIME  = 20;  %长MA天数
OBSERVE_TIME = 5; % 观察并判断趋势或振荡所需天数
TREND_JUDGE = 5;  % 此处两个都是5，说明判断标准是：5天内，每天的短线都高于/低于长线时为趋势，否则为振荡
IN_PERCENT = 0.80; %每次投入交易的钱占净值的百分比

RECENT_DAY = 30; %振荡策略止盈中取极小值的范围

%成交量策略参数
VOL_JUDGE_UP_1 = 1.5;
VOL_JUDGE_UP_2 = 0.8;     %成交量判断中的倍数
VOL_JUDGE_DOWN_1 = 1.5;
VOL_JUDGE_DOWN_2 = 0.8;
VOL_BUY_DAY = 3;     % 成交量判断中，当连续3天满足相应条件时发出买入信号
VOL_SELL_DAY = 2;    %成交量判断中，当连续2天满足相应条件时发出卖出信号

%止损参数
STOP_LOSS_DAY = 50; %止损时的参数，取前STOP_LOSS_DAY天内的净值的极大值 
STOP_LOSS_PROP = 0.90; % 当小于极大值的STOP_LOSS_PROP倍时止损

