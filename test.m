load('FQDATA.mat');
STOCK_NUM = 600519;

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
allVol         = Volume( beginCount : endCount  , stockCount );
historyClose = allClose( historyFlagtrade==1 );
historyVol   = allVol(historyFlagtrade==1 );