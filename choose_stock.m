function  STOCK_NUM = choose_stock (beginDate, endDate, Date, Close, StockCodeDouble)

stockIndex = 1;
beginCount = find( Date>=beginDate,1,'first');  %������ʼ���ڵĵ�һ��������
endCount   = find( Date<=endDate,1,'last'); %С�ڽ�ֹ���ڵĵ�һ��������
STOCK_NUM = [];
for i = 1 : length(StockCodeDouble)
    stock_code = StockCodeDouble(i);
    historyClose = Close(beginCount : endCount , i);
    priceWithoutZero = historyClose(historyClose>0); 
    len = length(priceWithoutZero);
    if len <= 50
        continue;
    end
    price_first = priceWithoutZero(1);
    price_last = priceWithoutZero(len);
    price_median = priceWithoutZero( ceil(len/2) );
    if price_last >=  2 * price_first 
        STOCK_NUM(stockIndex) = stock_code;
        stockIndex = stockIndex + 1;
    end
end

end