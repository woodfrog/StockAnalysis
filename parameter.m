%% set parameter
CHOOSE_BEGIN_DATE =20110104;   %最小20110104
CHOOSE_END_DATE   =20111230;   %最大20151127
BEGIN_DATE  =  20110104;  %最小20110104
END_DATE    =  20151127;  %最大20151127
BUY_COST   =0.00025;    %买入成本
SELL_COST  =0.00125;    %卖出成本
CASH       =0.03;       %无风险年利率

SHORT_TIME = 5;   %短MA天数
LONG_TIME  = 20;  %长MA天数
IN_PERCENT = 1; %每次投入交易的钱占净值的百分比

PREMISE_DAY = 9; %每天进行大前提判断时，所用到数据涵盖的天数
PREMISE_BOUND = 0.38; % 通过E值判断振荡还是趋势前提时的界限

%止损参数
STOP_LOSS_DAY = 50; %止损时的参数，取前STOP_LOSS_DAY天内的净值的极大值 
STOP_LOSS_PROP = 0.93; % 当小于极大值的STOP_LOSS_PROP倍时止损

