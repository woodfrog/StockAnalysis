function  STOCK_NUM = choose_stock (beginDate, endDate, Date, Close, StockCodeDouble)

stockIndex = 1;
beginCount = find( Date>=beginDate,1,'first');  %������ʼ���ڵĵ�һ��������
endCount   = find( Date<=endDate,1,'last'); %С�ڽ�ֹ���ڵĵ�һ��������
STOCK_NUM = [];
for i = 1 : length(StockCodeDouble)
    stock_code = StockCodeDouble(i);
    historyClose = Close(beginCount : endCount , i);
    price_first = historyClose( find(historyClose > 0, 1, 'first') );
    price_last = historyClose( find(historyClose > 0, 1, 'last') );
    if ~isempty(price_last) && ~isempty(price_first) && (price_last >= 1.2 * price_first)
        STOCK_NUM(stockIndex) = stock_code();
        stockIndex = stockIndex + 1;
    end
end

end