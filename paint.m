
%%
clc;
clear all;
close all;
format compact
%%
load('FQDATA.mat');
para_paint; % 导入参数
%%对参数中的起止日期以及股票代号进行检验
if BEGIN_DATE>=END_DATE
    fprintf('开始日期必须小于结束日期！');
    return;
end



stockCount = find(StockCodeDouble==STOCK_NUM);
%%对参数中的起止日期以及股票代号进行检验
if BEGIN_DATE>=END_DATE
    fprintf('开始日期必须小于结束日期！');
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
    stockCount=find(StockCodeDouble==STOCK_NUM);
  
    historyFlagtrade = Flagtrade(beginCount : endCount, stockCount );
    allClose         = Close( beginCount : endCount  , stockCount );
    allVol           = Volume( beginCount : endCount  , stockCount );
    historyClose     = allClose( historyFlagtrade==1 );
    historyVol       = allVol(historyFlagtrade==1 );
  
    %%
    FLAGBUY =  zeros(length(historyClose),1);%记录开平仓情况
    HOLD    =  zeros(length(historyClose),1);%记录持仓情况
    NET_OUT = zeros(length(historyClose),1);
    NET_IN  = zeros(length(historyClose),1);
    SHIFT_PRICE = zeros(length(historyClose),1);
    SHIFT_VOL  = zeros(length(historyClose),1);
    status  =  '空仓'; %初始状态为空仓
    shift   = 0;       % 0表示空仓，1表示持仓
    shiftPrice = 0;    %价格策略发出的信号
    shiftVolume = 0;   %成交量策略发出的信号
    state   = '未知';
    dayIndex = 1;       %天数的序号
    direction = '未知'; %趋势的方向，可以为up 或 down
    volIndex = 0;      %成交量策略中趋势的序号
    state_vol = 0;
    
    %以下是振荡策略的止盈部分的变量
    waitFlag = 0;
    waitProfitRate = 0;
    breakFlag = 0;
    incrementValue = 0;
    MINIMUM_IN_RECENT = 0;
    
    Compare_short_long = zeros(length(historyClose),1);%记录两条MA的高低
    E_value = zeros(length(historyClose),1); %记录每天的E值，用于判断该天处于振荡还是趋势中
    STATE_RECORD = zeros(length(historyClose),1); %记录每天是处在趋势行情中还是振荡行情中
    VOL_AVR = zeros(length(historyClose),1); %记录每个趋势中的平均交易量
    VOL_START_DAY = zeros(length(historyClose),1);
    VOL_RECORD   = zeros(length(historyClose),1);
    MA_SHORT = MA(historyClose,SHORT_TIME);
    MA_LONG = MA(historyClose, LONG_TIME);
    
    for dayIndex = 1 : length(historyClose) %循环每一天
        %% 将到当天位置的数据加入到可以获得的数据中，策略中只能用history部分数据，以防止前视偏差
        %%计算相应的长、短均线
        
        %% 对行情总体情况的判断，趋势or振荡
        % 并为策略的执行准备数据
        if dayIndex >= LONG_TIME
            if MA_SHORT(dayIndex) > MA_LONG(dayIndex) %记录短均线与长均线的高低情况
                Compare_short_long(dayIndex) = 1;
            else
                Compare_short_long(dayIndex) = 0;
            end
        end
        
        if dayIndex >= PREMISE_DAY     %计算每天的E值，用于大前提的判断
            numerator = historyClose(dayIndex) - historyClose(dayIndex - PREMISE_DAY + 1);
            denominator = 0;
            for index = 1 : PREMISE_DAY-1
                denominator = denominator + abs( historyClose(dayIndex - index + 1) - historyClose(dayIndex - index)  );
            end
            E_value(dayIndex) = numerator / denominator;
        end
        
        if dayIndex >= LONG_TIME
            
            if state_vol == 0 %处理第一次
                if historyClose(dayIndex) > historyClose(dayIndex-1)
                    volIndex = volIndex + 1;
                    state_vol = 1;
                    VOL_START_DAY(volIndex) = dayIndex;
                    VOL_RECORD(dayIndex) = volIndex;
                    VOL_AVR(volIndex) = historyVol(dayIndex);
                else
                    volIndex = volIndex + 1;
                    state_vol = -1;
                    VOL_START_DAY(volIndex) = dayIndex;
                    VOL_RECORD(dayIndex) = volIndex;
                    VOL_AVR(volIndex) = historyVol(dayIndex);
                end
            elseif state_vol == 1 %之前处在价格上升阶段
                if historyClose(dayIndex) > historyClose(dayIndex-1) %仍处在价格上升阶段中
                    VOL_AVR(volIndex) = AVR(dayIndex - VOL_START_DAY(volIndex)+1, historyVol);
                    VOL_RECORD(dayIndex) = volIndex;
                else
                    volIndex = volIndex + 1;
                    state_vol = -1;
                    VOL_START_DAY(volIndex) = dayIndex;
                    VOL_RECORD(dayIndex) = volIndex;
                    VOL_AVR(volIndex) = historyVol(dayIndex);
                end
            else %之前处在价格下降的阶段
                if historyClose(dayIndex) > historyClose(dayIndex-1) %仍处在价格上升阶段中
                    volIndex = volIndex + 1;
                    state_vol = 1;
                    VOL_START_DAY(volIndex) = dayIndex;
                    VOL_RECORD(dayIndex) = volIndex;
                    VOL_AVR(volIndex) = historyVol(dayIndex);
                else
                    VOL_AVR(volIndex) = AVR(dayIndex - VOL_START_DAY(volIndex)+1, historyVol);
                    VOL_RECORD(dayIndex) = volIndex;
                end
            end
            
            if E_value(dayIndex) > PREMISE_BOUND % 进入上升趋势
                state = 'trend';
                direction = 'up';
                STATE_RECORD(dayIndex) = 1;
                %重置振荡止盈中的变量
                waitFlag = 0;
                waitProfitRate = 0;
                breakFlag = 0;
                incrementValue = 0;
                MINIMUM_IN_RECENT = 0;
            elseif  E_value(dayIndex) <  -PREMISE_BOUND   %进入下降趋势
                state = 'trend';
                direction = 'down';
                STATE_RECORD(dayIndex) = -1;
                %重置振荡止盈中的变量
                waitFlag = 0;
                waitProfitRate = 0;
                breakFlag = 0;
                incrementValue = 0;
                MINIMUM_IN_RECENT = 0;
            else  %振荡趋势
                state = 'oscillation';
                STATE_RECORD(dayIndex) = 0;
            end
        end
        
        %% 执行核心策略Strategy, shift表示返回的今天的开平仓情况
        if dayIndex >= LONG_TIME + PREMISE_DAY
            SHIFT_VOL(dayIndex) = strategy_volume(dayIndex, volIndex, VOL_AVR, VOL_RECORD, VOL_START_DAY, historyClose(1:dayIndex));
            
            if strcmp(state,'trend') == 1  %之前判断此时为趋势行情
                SHIFT_PRICE(dayIndex) = strategy_trend(dayIndex, status, historyClose(1:dayIndex), direction,...
                    Compare_short_long, MA_SHORT(1:dayIndex), MA_LONG(1:dayIndex));
            elseif  strcmp(state,'oscillation') == 1   %振荡行情
                [SHIFT_PRICE(dayIndex), waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT  ] ...
                    = strategy_oscil(dayIndex, status, historyClose(1:dayIndex), MA_SHORT(1:dayIndex), MA_LONG(1:dayIndex), STATE_RECORD, ...
                    waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT );
            end
            
            if SHIFT_PRICE(dayIndex) + SHIFT_VOL(dayIndex) >= 1
                shift = 1;
            elseif SHIFT_PRICE(dayIndex) + SHIFT_VOL(dayIndex) <= -1
                shift = -1;
            else %如果成交量发出的信号与价格发出的信号相反，则不做动作
                shift = 0;
            end
            
            % 止损
%             if mod(dayIndex,365) == 0
%                 priceRatio =  historyClose(dayIndex-1) / historyClose(1);
%                 netRatio   =  NET(dayIndex-1) / NET(1);
%                 if   priceRatio >  1.4 * netRatio
%                     STOP_LOSS_PROP = 0.8;
%                 else
%                     STOP_LOSS_PROP = 0.9;
%                 end
%             end
            if dayIndex <= STOP_LOSS_DAY
                maxNet = max(NET);
            else
                maxNet = max(NET(dayIndex - STOP_LOSS_DAY + 1 :dayIndex-1) );
            end
            if NET(dayIndex-1) <= STOP_LOSS_PROP * maxNet
                shift = -1;
            end
            %以上为止损
            
        end
        
        %% 每天的后续计算
        %将今日开平仓情况存储于Flagbuy，以便结果的计算
        % Flagbuy最终存的将是每天的开仓情况，1代表开仓
        if dayIndex == 1  %第一天不交易
            FLAGBUY(dayIndex) = 0;
        else
            if shift == 0  %持仓情况与前一天相同，status不做改变，
                FLAGBUY(dayIndex) = FLAGBUY(dayIndex-1);
            elseif shift == 1  %开仓
                FLAGBUY(dayIndex) = 1;
                status = '开仓';
            else  % shift == -1, 平仓
                FLAGBUY(dayIndex) = 0;
                status = '空仓';
            end
        end
        
        %当第一天的时候，对各指标初始化
        if dayIndex==1
            NET(1)=1;
            NET_OUT(1) = 1;
            NET_IN(1) = 0;
            HOLD(1)=0;
            %第一天开仓时的处理
            if FLAGBUY(dayIndex) == 1
                NET_IN(1)  = IN_PERCENT * NET(1) *(1-BUY_COST); %一半的净值参与交易(这里手续费在哪里扣，到时候再看看要不要改)
                NET_OUT(1) = (1-IN_PERCENT) * NET(1);
                NET(1)  = NET_OUT(1) + NET_IN(1);
                HOLD(1) = NET_IN(1) / historyClose(1); %每次只用净值的50%去进行交易
            end
            continue;
        end
        
        %% 若不是第一天
        %如果前一天没持仓，那么不变，如果前一天持仓了，那么净值将根据今天的收盘价发生相应的变化，此处更新这一天的净值
        NET_IN(dayIndex) =  HOLD(dayIndex-1) * historyClose(dayIndex);
        NET_OUT(dayIndex) = NET_OUT(dayIndex-1);
        NET(dayIndex) = NET_OUT(dayIndex) + NET_IN(dayIndex);
        %这里要确保第一天是有价格的, 净值等于没参与交易的NET_OUT（再一次买入后是暂时固定的）与参与交易的NET_IN（持仓时会不断变化）之和
        
        HOLD(dayIndex) = HOLD(dayIndex-1);
        
        
        %若当天发出开仓信号
        if FLAGBUY(dayIndex) == 1 && FLAGBUY(dayIndex-1) == 0
            NET_IN(dayIndex) = IN_PERCENT * NET(dayIndex) * (1-BUY_COST);
            NET_OUT(dayIndex) = (1-IN_PERCENT) * NET(dayIndex);
            NET(dayIndex) = NET_IN(dayIndex) + NET_OUT(dayIndex);
            HOLD(dayIndex) = NET_IN(dayIndex) / historyClose(dayIndex);
            continue;
        end
        
        %若当天发出平仓信号
        if FLAGBUY(dayIndex) == 0 && FLAGBUY(dayIndex-1) == 1
            if isempty(find(FLAGBUY(1:dayIndex)==1,1,'last'))
                
            else
                NET(dayIndex) = NET_OUT(dayIndex) + NET_IN(dayIndex) * (1-SELL_COST);
                NET_OUT(dayIndex) = NET(dayIndex);
                NET_IN(dayIndex) = 0;
                HOLD(dayIndex)=0;
            end
        end
    end
    
MAX_RISK = max_risk(NET);
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
title('长线交易策略回测过程','FontWeight', 'Bold');
hold on;

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,2);
plot(historyVol);
grid on;
title('成交量','FontWeight', 'Bold');

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,3);
plot(NET);
grid on;
title('净值','FontWeight', 'Bold');

fprintf('最大回撤率：%f',MAX_RISK);







