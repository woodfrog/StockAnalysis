
%%
clc;
clear all;
close all;
format compact
%%
load('FQDATA.mat');
parameter; % �������
STOCK_NUM = [600409,600470,600486,600048,000031,000038,...
    000402,000950,000420,000949,600889,000816,000809,000949,600573,...
   000596,600307,600015,600000,601288,000928,000065,000056,600658,...
   600570,000682,600056,600079,600216,002423,000819,002182];
% STOCK_NUM = [600519,600999,	600048,	601688,	600837,	600111,	600036,	600547,	600383,	600887,	601006,	600030,	600000,	600015,	601901,	600585,	600089,	601169,	601166,	600104,	600637,	601328,	600016,	601398,	600406,	601818,	601288,	600196,	601088,	600031,	601318,	601336,	600050,	600028,	601857,	600703,	601118,	601117,	601601,	600018,	600332,	601989,	601628,	601668,	600256,	600518,	600010,	600832,	601299,	601766,	];
% STOCK_NUM = StockCodeDouble;

SUM_NET = 0;
SUM_RISK = 0;
SUM_PRICE = 0;
NO_INFORMATION = 0;

beginCount = find(Date>=BEGIN_DATE,1,'first');  %������ʼ���ڵĵ�һ��������
if isempty(beginCount) || BEGIN_DATE<20110104
    fprintf('��ʼ���ڲ������ݷ�Χ��');
    return;
end

endCount = find(Date<=END_DATE,1,'last'); %С�ڽ�ֹ���ڵĵ�һ��������
if isempty(endCount) || END_DATE>20151127
    fprintf('�������ڲ������ݷ�Χ��');
    return;
end


for codeIndex = 1 : length(STOCK_NUM)
    
    stockCount=find(StockCodeDouble==STOCK_NUM(codeIndex));
  
    historyFlagtrade = Flagtrade(beginCount : endCount, stockCount );
    allClose         = Close( beginCount : endCount  , stockCount );
    allVol           = Volume( beginCount : endCount  , stockCount );
    historyClose     = allClose( historyFlagtrade==1 );
    historyVol       = allVol(historyFlagtrade==1 );
    
    if length(stockCount) == 0
        fprintf('No Data for stock: %06.0f\n', STOCK_NUM(codeIndex));
        NO_INFORMATION = NO_INFORMATION + 1;
        continue; %ֱ���������²���
    end
    
    if length(historyClose) == 0
        fprintf('Stock%06.0f has quit\n ', STOCK_NUM(codeIndex));
        NO_INFORMATION = NO_INFORMATION + 1;
        continue;
    end
    
    if length(historyClose) < 300
        fprintf('Stock%06.0f do not provide enough data for the strategy\n ', STOCK_NUM(codeIndex));
        NO_INFORMATION = NO_INFORMATION + 1;
        continue;
    end
    
    
    %%
    FLAGBUY =  zeros(length(historyClose),1);%��¼��ƽ�����
    HOLD    =  zeros(length(historyClose),1);%��¼�ֲ����
    NET_OUT = zeros(length(historyClose),1);
    NET_IN  = zeros(length(historyClose),1);
    SHIFT_PRICE = zeros(length(historyClose),1);
    SHIFT_VOL  = zeros(length(historyClose),1);
    status  =  '�ղ�'; %��ʼ״̬Ϊ�ղ�
    shift   = 0;       % 0��ʾ�ղ֣�1��ʾ�ֲ�
    shiftPrice = 0;    %�۸���Է������ź�
    shiftVolume = 0;   %�ɽ������Է������ź�
    state   = 'δ֪';
    dayIndex = 1;       %���������
    direction = 'δ֪'; %���Ƶķ��򣬿���Ϊup �� down
    volIndex = 0;      %�ɽ������������Ƶ����
    state_vol = 0;
    
    %�������񵴲��Ե�ֹӯ���ֵı���
    waitFlag = 0;
    waitProfitRate = 0;
    breakFlag = 0;
    incrementValue = 0;
    MINIMUM_IN_RECENT = 0;
    
    Compare_short_long = zeros(length(historyClose),1);%��¼����MA�ĸߵ�
    E_value = zeros(length(historyClose),1); %��¼ÿ���Eֵ�������жϸ��촦���񵴻���������
    STATE_RECORD = zeros(length(historyClose),1); %��¼ÿ���Ǵ������������л�����������
    VOL_AVR = zeros(length(historyClose),1); %��¼ÿ�������е�ƽ��������
    VOL_START_DAY = zeros(length(historyClose),1);
    VOL_RECORD   = zeros(length(historyClose),1);
    MA_SHORT = MA(historyClose,SHORT_TIME);
    MA_LONG = MA(historyClose, LONG_TIME);
    
    for dayIndex = 1 : length(historyClose) %ѭ��ÿһ��
        %% ��������λ�õ����ݼ��뵽���Ի�õ������У�������ֻ����history�������ݣ��Է�ֹǰ��ƫ��
        %%������Ӧ�ĳ����̾���
        
        %% ����������������жϣ�����or��
        % ��Ϊ���Ե�ִ��׼������
        if dayIndex >= LONG_TIME
            if MA_SHORT(dayIndex) > MA_LONG(dayIndex) %��¼�̾����볤���ߵĸߵ����
                Compare_short_long(dayIndex) = 1;
            else
                Compare_short_long(dayIndex) = 0;
            end
        end
        
        if dayIndex >= PREMISE_DAY     %����ÿ���Eֵ�����ڴ�ǰ����ж�
            numerator = historyClose(dayIndex) - historyClose(dayIndex - PREMISE_DAY + 1);
            denominator = 0;
            for index = 1 : PREMISE_DAY-1
                denominator = denominator + abs( historyClose(dayIndex - index + 1) - historyClose(dayIndex - index)  );
            end
            E_value(dayIndex) = numerator / denominator;
        end
        
        if dayIndex >= LONG_TIME
            
            if state_vol == 0 %�����һ��
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
            elseif state_vol == 1 %֮ǰ���ڼ۸������׶�
                if historyClose(dayIndex) > historyClose(dayIndex-1) %�Դ��ڼ۸������׶���
                    VOL_AVR(volIndex) = AVR(dayIndex - VOL_START_DAY(volIndex)+1, historyVol);
                    VOL_RECORD(dayIndex) = volIndex;
                else
                    volIndex = volIndex + 1;
                    state_vol = -1;
                    VOL_START_DAY(volIndex) = dayIndex;
                    VOL_RECORD(dayIndex) = volIndex;
                    VOL_AVR(volIndex) = historyVol(dayIndex);
                end
            else %֮ǰ���ڼ۸��½��Ľ׶�
                if historyClose(dayIndex) > historyClose(dayIndex-1) %�Դ��ڼ۸������׶���
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
            
            if E_value(dayIndex) > PREMISE_BOUND % ������������
                state = 'trend';
                direction = 'up';
                STATE_RECORD(dayIndex) = 1;
                %������ֹӯ�еı���
                waitFlag = 0;
                waitProfitRate = 0;
                breakFlag = 0;
                incrementValue = 0;
                MINIMUM_IN_RECENT = 0;
            elseif  E_value(dayIndex) <  -PREMISE_BOUND   %�����½�����
                state = 'trend';
                direction = 'down';
                STATE_RECORD(dayIndex) = -1;
                %������ֹӯ�еı���
                waitFlag = 0;
                waitProfitRate = 0;
                breakFlag = 0;
                incrementValue = 0;
                MINIMUM_IN_RECENT = 0;
            else  %������
                state = 'oscillation';
                STATE_RECORD(dayIndex) = 0;
            end
        end
        
        %% ִ�к��Ĳ���Strategy, shift��ʾ���صĽ���Ŀ�ƽ�����
        if dayIndex >= LONG_TIME + PREMISE_DAY
            SHIFT_VOL(dayIndex) = strategy_volume(dayIndex, volIndex, VOL_AVR, VOL_RECORD, VOL_START_DAY, historyClose(1:dayIndex));
            
            if strcmp(state,'trend') == 1  %֮ǰ�жϴ�ʱΪ��������
                SHIFT_PRICE(dayIndex) = strategy_trend(dayIndex, status, historyClose(1:dayIndex), direction,...
                    Compare_short_long, MA_SHORT(1:dayIndex), MA_LONG(1:dayIndex));
            elseif  strcmp(state,'oscillation') == 1   %������
                [SHIFT_PRICE(dayIndex), waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT  ] ...
                    = strategy_oscil(dayIndex, status, historyClose(1:dayIndex), MA_SHORT(1:dayIndex), MA_LONG(1:dayIndex), STATE_RECORD, ...
                    waitFlag, waitProfitRate, breakFlag, incrementValue, MINIMUM_IN_RECENT );
            end
            
            if SHIFT_PRICE(dayIndex) + SHIFT_VOL(dayIndex) >= 1
                shift = 1;
            elseif SHIFT_PRICE(dayIndex) + SHIFT_VOL(dayIndex) <= -1
                shift = -1;
            else %����ɽ����������ź���۸񷢳����ź��෴����������
                shift = 0;
            end
            
            % ֹ��
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
            %����Ϊֹ��
            
        end
        
        %% ÿ��ĺ�������
        %�����տ�ƽ������洢��Flagbuy���Ա����ļ���
        % Flagbuy���մ�Ľ���ÿ��Ŀ��������1������
        if dayIndex == 1  %��һ�첻����
            FLAGBUY(dayIndex) = 0;
        else
            if shift == 0  %�ֲ������ǰһ����ͬ��status�����ı䣬
                FLAGBUY(dayIndex) = FLAGBUY(dayIndex-1);
            elseif shift == 1  %����
                FLAGBUY(dayIndex) = 1;
                status = '����';
            else  % shift == -1, ƽ��
                FLAGBUY(dayIndex) = 0;
                status = '�ղ�';
            end
        end
        
        %����һ���ʱ�򣬶Ը�ָ���ʼ��
        if dayIndex==1
            NET(1)=1;
            NET_OUT(1) = 1;
            NET_IN(1) = 0;
            HOLD(1)=0;
            %��һ�쿪��ʱ�Ĵ���
            if FLAGBUY(dayIndex) == 1
                NET_IN(1)  = IN_PERCENT * NET(1) *(1-BUY_COST); %һ��ľ�ֵ���뽻��(����������������ۣ���ʱ���ٿ���Ҫ��Ҫ��)
                NET_OUT(1) = (1-IN_PERCENT) * NET(1);
                NET(1)  = NET_OUT(1) + NET_IN(1);
                HOLD(1) = NET_IN(1) / historyClose(1); %ÿ��ֻ�þ�ֵ��50%ȥ���н���
            end
            continue;
        end
        
        %% �����ǵ�һ��
        %���ǰһ��û�ֲ֣���ô���䣬���ǰһ��ֲ��ˣ���ô��ֵ�����ݽ�������̼۷�����Ӧ�ı仯���˴�������һ��ľ�ֵ
        NET_IN(dayIndex) =  HOLD(dayIndex-1) * historyClose(dayIndex);
        NET_OUT(dayIndex) = NET_OUT(dayIndex-1);
        NET(dayIndex) = NET_OUT(dayIndex) + NET_IN(dayIndex);
        %����Ҫȷ����һ�����м۸��, ��ֵ����û���뽻�׵�NET_OUT����һ�����������ʱ�̶��ģ�����뽻�׵�NET_IN���ֲ�ʱ�᲻�ϱ仯��֮��
        
        HOLD(dayIndex) = HOLD(dayIndex-1);
        
        
        %�����췢�������ź�
        if FLAGBUY(dayIndex) == 1 && FLAGBUY(dayIndex-1) == 0
            NET_IN(dayIndex) = IN_PERCENT * NET(dayIndex) * (1-BUY_COST);
            NET_OUT(dayIndex) = (1-IN_PERCENT) * NET(dayIndex);
            NET(dayIndex) = NET_IN(dayIndex) + NET_OUT(dayIndex);
            HOLD(dayIndex) = NET_IN(dayIndex) / historyClose(dayIndex);
            continue;
        end
        
        %�����췢��ƽ���ź�
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
    FINAL_NET = NET(dayIndex);
    SUM_NET = SUM_NET + FINAL_NET;
    MAX_RISK = max_risk(NET);
    SUM_RISK = SUM_RISK + MAX_RISK;
    PRICE_RATIO = historyClose(dayIndex)/historyClose(1);
    SUM_PRICE = SUM_PRICE + PRICE_RATIO;
     fprintf( 'No.%d: %06.0f  NET: %f RISK: %f  PRICE: %f  DAYS: %.0f\n',codeIndex, STOCK_NUM(codeIndex), FINAL_NET, MAX_RISK, ...
         PRICE_RATIO, dayIndex );
    clear NET historyClose historyVol;
end

NET_AVR = SUM_NET / (length(STOCK_NUM) - NO_INFORMATION);
RISK_AVR = SUM_RISK / (length(STOCK_NUM) - NO_INFORMATION);
PRICE_AVR = SUM_PRICE / (length(STOCK_NUM) - NO_INFORMATION);
fprintf('ƽ��NET�� %f\n', NET_AVR);
fprintf('ƽ��RISK�� %f\n', RISK_AVR);
fprintf('ƽ��PRICE�� %f\n', PRICE_AVR);

%% ��ͼ
%
% scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
% subplot(3,1,1);
% plot(historyClose,'b','LineStyle','-','LineWidth',1.5);
% hold on; %����֮ǰ������
% plot(MA_SHORT,'r','LineStyle','--','LineWidth',1.5);
% plot(MA_LONG,'k','LineStyle','-.','LineWidth',1.5);
% grid on;
% legend('CLOSE-PRICE','MA-SHORT','MA-LONG','Location','Best');
% title('���ײ��Իز����--��MAΪ����','FontWeight', 'Bold');
% hold on;
%
% scrsz = get(0,'ScreenSize');
% % figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
% subplot(3,1,2);
% plot(RISK);
% grid on;
% title('�س���','FontWeight', 'Bold');
%
% scrsz = get(0,'ScreenSize');
% % figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
% subplot(3,1,3);
% plot(NET);
% grid on;
% title('��ֵ�仯���','FontWeight', 'Bold');









