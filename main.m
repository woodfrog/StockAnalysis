
%%
clc;
clear all;
close all;
format compact
%%
load('FQDATA.mat');
parameter; % 导入参数
%%对参数中的起止日期以及股票代号进行检验
if BEGIN_DATE>=END_DATE
    fprintf('开始日期必须小于结束日期！');
    return;
end

stockCount=find(StockCodeDouble==STOCK_NUM);
if isempty(stockCount)
    fprintf('股票代码输入错误！');
    return;
end

beginCount = find(Date>=BEGIN_DATE,1,'first');  %大于起始日期的第一个交易日
if isempty(beginCount) || BEGIN_DATE<20110104
    fprintf('开始日期不在数据范围！');
    return;
end

endCount = find(Date<=END_DATE,1,'last'); %小于截止日期的第一个交易日
if isempty(endCount) || END_DATE>20151127
    fprintf('结束日期不在数据范围！');
    return;
end
%%
FLAGBUY =  zeros(endCount-beginCount+1,1);%记录开平仓情况
%PCYK    =  zeros(endCount-beginCount+1,1);%记录平仓盈亏
HOLD    =  zeros(endCount-beginCount+1,1);%记录持仓情况
RISK    =  zeros(endCount-beginCount+1,1);%记录回撤
NET_OUT = zeros(endCount-beginCount+1,1);
NET_IN  = zeros(endCount-beginCount+1,1);
status  =  '空仓';
shift   = 0; % 0表示空仓，1表示持仓
state   = '未知';
dayIndex = 1;
direction = '未知';
volIndex = 0;


% historyClose = zeros(endCount-beginCount+1,1);
% historyFlagtrade = zeros(endCount-beginCount+1,1);
Compare_short_long = zeros(endCount-beginCount+1,1);
STATE_RECORD = zeros(endCount-beginCount+1,1); %记录每天是处在趋势行情中还是振荡行情中
VOL_AVR = zeros(endCount-beginCount+1,1); %记录每个趋势中的平均交易量
VOL_START_DAY = zeros(endCount-beginCount+1,1);
%%

for i = beginCount:endCount %循环每一天
    if Flagtrade(i, stockCount) == 0
        continue;   %如果这一天是没有交易的，那么直接跳过
    end
    %% 将到当天位置的数据加入到可以获得的数据中，策略中只能用history部分数据，以防止前视偏差
    historyClose(dayIndex)     = Close(i, stockCount ); 
    historyVol(dayIndex)       = Volume(i, stockCount); %成交量
    %%计算相应的长、短均线
    if  dayIndex >= SHORT_TIME %计算短均线
        MA_SHORT(dayIndex) = MA( SHORT_TIME,historyClose);
    end
    if dayIndex >= LONG_TIME %计算长均线
        MA_LONG(dayIndex) = MA( LONG_TIME, historyClose);
    end
    
    %% 对行情总体情况的判断，趋势or振荡
    if dayIndex >= LONG_TIME
        if MA_SHORT(dayIndex) > MA_LONG(dayIndex) %记录短均线与长均线的高低情况
            Compare_short_long(dayIndex) = 1;
        else
            Compare_short_long(dayIndex) = 0;
        end
    end
    
    if dayIndex >= LONG_TIME + OBSERVE_TIME
        if length( find ( Compare_short_long(dayIndex - OBSERVE_TIME + 1 : dayIndex) == 1 ) ) >= TREND_JUDGE % 进入上升趋势
            if  ~strcmp(state, 'trend') || ~strcmp(direction, 'up') %这一天恰好进入上升趋势 
                volIndex = volIndex + 1;
                VOL_START_DAY(volIndex) = dayIndex - TREND_JUDGE + 1; 
                VOL_AVR(volIndex) = MA( TREND_JUDGE, historyVol);
            else %之前一天也是上升趋势
                VOL_AVR(volIndex) = MA( dayIndex-VOL_START_DAY(volIndex)+1, historyVol);
            end
            state = 'trend';
            direction = 'up';
            STATE_RECORD(dayIndex) = 1;
        elseif  length( find ( Compare_short_long(dayIndex - OBSERVE_TIME + 1 : dayIndex) ==0 ) ) >= TREND_JUDGE  %进入下降趋势
            if ~strcmp(state, 'trend') || ~strcmp(direction, 'down') %这一天恰好进入下降趋势
                volIndex = volIndex + 1;
                VOL_START_DAY(volIndex) = dayIndex - TREND_JUDGE + 1; 
                VOL_AVR(volIndex) = MA( TREND_JUDGE, historyVol);
            else %前一天本就是下降趋势
                VOL_AVR(volIndex) = MA( dayIndex-VOL_START_DAY(volIndex)+1, historyVol);
            end
            state = 'trend';
            direction = 'down';
            STATE_RECORD(dayIndex) = 1;
        else  %振荡趋势，在振荡趋势中暂时不处理成交量
            state = 'oscillation';
            STATE_RECORD(dayIndex) = 0;
        end     
    end
    
    
    %% 执行核心策略Strategy,shift表示返回的今天的开平仓情况
    if strcmp(state,'trend') == 1  %之前判断此时为趋势行情
        [shift,status] = strategy_trend(shift, dayIndex, volIndex, status, historyClose, VOL_AVR, direction,...
                            Compare_short_long, MA_SHORT, MA_LONG); 
    elseif  strcmp(state,'oscillation') == 1   %振荡行情 
        [shift,status] = strategy_oscil(shift, dayIndex, volIndex, status, historyClose, ...
                            VOL_AVR, MA_SHORT, MA_LONG, NET, NET_IN, NET_OUT); 
    end
    
    %% 每天的后续计算
     %将今日开平仓情况存储于Flagbuy，以便结果的计算
    FLAGBUY(dayIndex) = shift;
    % Flagbuy最终存的将是每天的开仓情况，1代表开仓
    
    %%以下计算平仓盈亏、净值、持仓情况、回撤等指标
    %当第一天的时候，对各指标初始化
    if dayIndex==1
        %PCYK(1)=1;
        NET(1)=1;
        NET_OUT(1) = 1;
        NET_IN(1) = 0;
        HOLD(1)=0;
        RISK(1)=0;
        %第一天开仓时的处理
        if FLAGBUY(dayIndex) == 1              
            NET_IN(1)  = IN_PERCENT * NET(1) *(1-BUY_COST); %一半的净值参与交易(这里手续费在哪里扣，到时候再看看要不要改)
            NET_OUT(1) = (1-IN_PERCENT) * NET(1);                                  
            %PCYK(1) = 1 - BUY_COST;
            NET(1)  = NET_OUT(1) + NET_IN(1);
            HOLD(1) = NET_IN(1) / historyClose(1); %每次只用净值的50%去进行交易
            RISK(1) =BUY_COST;
        end
        dayIndex = dayIndex + 1;   
        continue;
    end
    
    %% 若不是第一天
     %如果前一天没持仓，那么不变，如果前一天持仓了，那么净值将根据今天的收盘价发生相应的变化，此处更新这一天的净值
    NET_IN(dayIndex) =  HOLD(dayIndex-1) * historyClose(dayIndex);
    NET_OUT(dayIndex) = NET_OUT(dayIndex-1);
    NET(dayIndex) = NET_OUT(dayIndex) + NET_IN(dayIndex);  
      %这里要确保第一天是有价格的, 净值等于没参与交易的NET_OUT（再一次买入后是暂时固定的）与参与交易的NET_IN（持仓时会不断变化）之和
    
    %PCYK(dayIndex) = PCYK(dayIndex-1);
    HOLD(dayIndex) = HOLD(dayIndex-1);
    
    
    %若当天发出开仓信号
    if FLAGBUY(dayIndex) == 1 && FLAGBUY(dayIndex-1) == 0
        %PCYK(dayIndex) = PCYK(dayIndex) * (1-BUY_COST);
        NET_IN(dayIndex) = IN_PERCENT * NET(dayIndex) * (1-BUY_COST);
        NET_OUT(dayIndex) = (1-IN_PERCENT) * NET(dayIndex);
        NET(dayIndex) = NET_IN(dayIndex) + NET_OUT(dayIndex);
        HOLD(dayIndex) = NET_IN(dayIndex) / historyClose(dayIndex);
        RISK(dayIndex) = max(NET)-NET(dayIndex); %这里用max函数欠妥，可以记录到当前为止的最高净值
        dayIndex = dayIndex + 1;   
        continue;
    end
    
    %若当天发出平仓信号
    if FLAGBUY(dayIndex) == 0 && FLAGBUY(dayIndex-1) == 1
        if isempty(find(FLAGBUY(1:dayIndex)==1,1,'last')) 
            
        else  
            NET(dayIndex) = NET_OUT(dayIndex) + NET_IN(dayIndex) * (1-SELL_COST);
            NET_OUT(dayIndex) = NET(dayIndex);
            NET_IN(dayIndex) = 0;
            %PCYK(dayIndex)=NET(dayIndex);
            HOLD(dayIndex)=0;
        end        
    end
    RISK(dayIndex) = max(NET)-NET(dayIndex); %这里用max函数欠妥，可以记录到当前为止的最高净值
    dayIndex = dayIndex + 1;   
end
%% 画图

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,1);
plot(historyClose,'b','LineStyle','-','LineWidth',1.5);
hold on; %保留之前的曲线
plot(MA_SHORT,'r','LineStyle','--','LineWidth',1.5);
plot(MA_LONG,'k','LineStyle','-.','LineWidth',1.5);
grid on;
legend('CLOSE-PRICE','MA-SHORT','MA-LONG','Location','Best');
title('交易策略回测过程--以MA为核心','FontWeight', 'Bold');
hold on;

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,2);
plot(historyVol);
grid on;
title('成交量变化','FontWeight', 'Bold');

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,2);
plot(historyVol);
grid on;
title('成交量变化','FontWeight', 'Bold');

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,3);
plot(NET);
grid on;
title('净值变化情况','FontWeight', 'Bold');









