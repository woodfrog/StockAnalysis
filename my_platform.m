
%%
clc;
clear all;
close all;
format compact
%%
load('FQDATA.mat');
parameter; % �������
%%�Բ����е���ֹ�����Լ���Ʊ���Ž��м���
if BEGIN_DATE>=END_DATE
    fprintf('��ʼ���ڱ���С�ڽ������ڣ�');
    return;
end

stockCount=find(StockCodeDouble==STOCK_NUM);
if isempty(stockCount)
    fprintf('��Ʊ�����������');
    return;
end

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
%%
FLAGBUY =  zeros(endCount-beginCount+1,1);%��¼��ƽ�����
%PCYK    =  zeros(endCount-beginCount+1,1);%��¼ƽ��ӯ��
HOLD    =  zeros(endCount-beginCount+1,1);%��¼�ֲ����
RISK    =  zeros(endCount-beginCount+1,1);%��¼�س�
NET_OUT = zeros(endCount-beginCount+1,1);
NET_IN  = zeros(endCount-beginCount+1,1);
status  =  '�ղ�';
shift   = 0; % 0��ʾ�ղ֣�1��ʾ�ֲ�
state   = 'δ֪';
dayIndex = 1;
direction = 'δ֪';
volIndex = 0;


% historyClose = zeros(endCount-beginCount+1,1);
% historyFlagtrade = zeros(endCount-beginCount+1,1);
Compare_short_long = zeros(endCount-beginCount+1,1);
STATE_RECORD = zeros(endCount-beginCount+1,1); %��¼ÿ���Ǵ������������л�����������
VOL_AVR = zeros(endCount-beginCount+1,1); %��¼ÿ�������е�ƽ��������
VOL_START_DAY = zeros(endCount-beginCount+1,1);
%%

for i = beginCount:endCount %ѭ��ÿһ��
    if Flagtrade(i, stockCount) == 0
        continue;   %�����һ����û�н��׵ģ���ôֱ������
    end
    %% ��������λ�õ����ݼ��뵽���Ի�õ������У�������ֻ����history�������ݣ��Է�ֹǰ��ƫ��
    historyClose(dayIndex)     = Close(i, stockCount ); 
    historyVol(dayIndex)       = Volume(i, stockCount); %�ɽ���
    %%������Ӧ�ĳ����̾���
    if  dayIndex >= SHORT_TIME %����̾���
        MA_SHORT(dayIndex) = MA( SHORT_TIME,historyClose);
    end
    if dayIndex >= LONG_TIME %���㳤����
        MA_LONG(dayIndex) = MA( LONG_TIME, historyClose);
    end
    
    %% ����������������жϣ�����or��
    if dayIndex >= LONG_TIME
        if MA_SHORT(dayIndex) > MA_LONG(dayIndex) %��¼�̾����볤���ߵĸߵ����
            Compare_short_long(dayIndex) = 1;
        else
            Compare_short_long(dayIndex) = 0;
        end
    end
    
    if dayIndex >= LONG_TIME + OBSERVE_TIME
        if length( find ( Compare_short_long(dayIndex - OBSERVE_TIME + 1 : dayIndex) == 1 ) ) >= TREND_JUDGE % ������������
            if  ~strcmp(state, 'trend') || ~strcmp(direction, 'up') %��һ��ǡ�ý����������� 
                volIndex = volIndex + 1;
                VOL_START_DAY(volIndex) = dayIndex - TREND_JUDGE + 1; 
                VOL_AVR(volIndex) = MA( TREND_JUDGE, historyVol);
            else %֮ǰһ��Ҳ����������
                VOL_AVR(volIndex) = MA( dayIndex-VOL_START_DAY(volIndex)+1, historyVol);
            end
            state = 'trend';
            direction = 'up';
            STATE_RECORD(dayIndex) = 1;
        elseif  length( find ( Compare_short_long(dayIndex - OBSERVE_TIME + 1 : dayIndex) ==0 ) ) >= TREND_JUDGE  %�����½�����
            if ~strcmp(state, 'trend') || ~strcmp(direction, 'down') %��һ��ǡ�ý����½�����
                volIndex = volIndex + 1;
                VOL_START_DAY(volIndex) = dayIndex - TREND_JUDGE + 1; 
                VOL_AVR(volIndex) = MA( TREND_JUDGE, historyVol);
            else %ǰһ�챾�����½�����
                VOL_AVR(volIndex) = MA( dayIndex-VOL_START_DAY(volIndex)+1, historyVol);
            end
            state = 'trend';
            direction = 'down';
            STATE_RECORD(dayIndex) = 1;
        else  %�����ƣ�������������ʱ������ɽ���
            state = 'oscillation';
            STATE_RECORD(dayIndex) = 0;
        end     
    end
    
    
    %% ִ�к��Ĳ���Strategy,shift��ʾ���صĽ���Ŀ�ƽ�����
    if strcmp(state,'trend') == 1  %֮ǰ�жϴ�ʱΪ��������
        [shift,status] = strategy_trend(shift, dayIndex, volIndex, status, historyClose, VOL_AVR, direction,...
                            Compare_short_long, MA_SHORT, MA_LONG); 
    elseif  strcmp(state,'oscillation') == 1   %������ 
        [shift,status] = strategy_oscil(shift, dayIndex, volIndex, status, historyClose, ...
                            VOL_AVR, MA_SHORT, MA_LONG, NET, NET_IN, NET_OUT); 
    end
    
    %% ÿ��ĺ�������
     %�����տ�ƽ������洢��Flagbuy���Ա����ļ���
    FLAGBUY(dayIndex) = shift;
    % Flagbuy���մ�Ľ���ÿ��Ŀ��������1������
    
    %%���¼���ƽ��ӯ������ֵ���ֲ�������س���ָ��
    %����һ���ʱ�򣬶Ը�ָ���ʼ��
    if dayIndex==1
        %PCYK(1)=1;
        NET(1)=1;
        NET_OUT(1) = 1;
        NET_IN(1) = 0;
        HOLD(1)=0;
        RISK(1)=0;
        %��һ�쿪��ʱ�Ĵ���
        if FLAGBUY(dayIndex) == 1              
            NET_IN(1)  = IN_PERCENT * NET(1) *(1-BUY_COST); %һ��ľ�ֵ���뽻��(����������������ۣ���ʱ���ٿ���Ҫ��Ҫ��)
            NET_OUT(1) = (1-IN_PERCENT) * NET(1);                                  
            %PCYK(1) = 1 - BUY_COST;
            NET(1)  = NET_OUT(1) + NET_IN(1);
            HOLD(1) = NET_IN(1) / historyClose(1); %ÿ��ֻ�þ�ֵ��50%ȥ���н���
            RISK(1) =BUY_COST;
        end
        dayIndex = dayIndex + 1;   
        continue;
    end
    
    %% �����ǵ�һ��
     %���ǰһ��û�ֲ֣���ô���䣬���ǰһ��ֲ��ˣ���ô��ֵ�����ݽ�������̼۷�����Ӧ�ı仯���˴�������һ��ľ�ֵ
    NET_IN(dayIndex) =  HOLD(dayIndex-1) * historyClose(dayIndex);
    NET_OUT(dayIndex) = NET_OUT(dayIndex-1);
    NET(dayIndex) = NET_OUT(dayIndex) + NET_IN(dayIndex);  
      %����Ҫȷ����һ�����м۸��, ��ֵ����û���뽻�׵�NET_OUT����һ�����������ʱ�̶��ģ�����뽻�׵�NET_IN���ֲ�ʱ�᲻�ϱ仯��֮��
    
    %PCYK(dayIndex) = PCYK(dayIndex-1);
    HOLD(dayIndex) = HOLD(dayIndex-1);
    
    
    %�����췢�������ź�
    if FLAGBUY(dayIndex) == 1 && FLAGBUY(dayIndex-1) == 0
        %PCYK(dayIndex) = PCYK(dayIndex) * (1-BUY_COST);
        NET_IN(dayIndex) = IN_PERCENT * NET(dayIndex) * (1-BUY_COST);
        NET_OUT(dayIndex) = (1-IN_PERCENT) * NET(dayIndex);
        NET(dayIndex) = NET_IN(dayIndex) + NET_OUT(dayIndex);
        HOLD(dayIndex) = NET_IN(dayIndex) / historyClose(dayIndex);
        RISK(dayIndex) = max(NET)-NET(dayIndex); %������max����Ƿ�ף����Լ�¼����ǰΪֹ����߾�ֵ
        dayIndex = dayIndex + 1;   
        continue;
    end
    
    %�����췢��ƽ���ź�
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
    RISK(dayIndex) = max(NET)-NET(dayIndex); %������max����Ƿ�ף����Լ�¼����ǰΪֹ����߾�ֵ
    dayIndex = dayIndex + 1;   
end
%% ��ͼ

scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,1);
plot(historyClose,'b','LineStyle','-','LineWidth',1.5);
hold on; %����֮ǰ������
plot(MA_SHORT,'r','LineStyle','--','LineWidth',1.5);
plot(MA_LONG,'k','LineStyle','-.','LineWidth',1.5);
grid on;
legend('CLOSE-PRICE','MA-SHORT','MA-LONG','Location','Best');
title('���ײ��Իز����--��MAΪ����','FontWeight', 'Bold');
hold on;

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,2);
plot(historyVol);
grid on;
title('�ɽ����仯','FontWeight', 'Bold');

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,2);
plot(historyVol);
grid on;
title('�ɽ����仯','FontWeight', 'Bold');

scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
subplot(3,1,3);
plot(NET);
grid on;
title('��ֵ�仯���','FontWeight', 'Bold');









