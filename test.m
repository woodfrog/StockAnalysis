load('FQDATA.mat');
STOCK_NUM = 600519;

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

stockCount=find(StockCodeDouble==STOCK_NUM);
historyFlagtrade = Flagtrade(beginCount : endCount, stockCount );
allClose         = Close( beginCount : endCount  , stockCount );
allVol         = Volume( beginCount : endCount  , stockCount );
historyClose = allClose( historyFlagtrade==1 );
historyVol   = allVol(historyFlagtrade==1 );