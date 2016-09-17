 % �����ṩ�ľ�ֵ�������س���
 % ����ֵ�� ���س���
 % ����  �� 1ά�������ز���ÿ��ľ�ֵ
function MAX_RISK = max_risk(NET)  

maxNet = NET(1);
MAX_RISK = 0;

for i = 2 : length(NET)
    if NET(i) > maxNet
        maxNet = NET(i);
        continue;
    end
    tempRisk = (maxNet-NET(i)) / maxNet;
    if tempRisk > MAX_RISK
        MAX_RISK = tempRisk;
    end
end

end