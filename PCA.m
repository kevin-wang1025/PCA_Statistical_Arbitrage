%% 資料清洗
%先取五檔加密貨幣做測試
columnsRemain = {'Time', 'Close'};
btc = readtable("C:\Users\10830\Desktop\學校\TMBA專案\PCA配對交易\數據\BTC.csv");
btc = btc(: ,columnsRemain);
eth = readtable("C:\Users\10830\Desktop\學校\TMBA專案\PCA配對交易\數據\ETH.csv");
bnb = readtable("C:\Users\10830\Desktop\學校\TMBA專案\PCA配對交易\數據\BNB.csv");
xrp = readtable("C:\Users\10830\Desktop\學校\TMBA專案\PCA配對交易\數據\XRP.csv");
sol = readtable("C:\Users\10830\Desktop\學校\TMBA專案\PCA配對交易\數據\SOL.csv");

data = table();
data.btc = price2ret(btc.Close);
data.eth = price2ret(eth.Close);
data.bnb = price2ret(bnb.Close);
data.xrp =  price2ret(xrp.Close);
data.sol = price2ret(sol.Close);

data_copy = data;
for col = 1:width(data_copy)
    colName = data_copy.Properties.VariableNames{col};
    data_copy.(colName) = zscore(data_copy.(colName));
end

variableNames = {'btc', 'eth', 'bnb', 'xrp', 'sol'};
correlationMatrix = corr(data_copy{:, variableNames});
disp(correlationMatrix);

%% PCA
[vectors, values] = eig(correlationMatrix);
disp(values);
disp(vectors);

%計算特徵貢獻度
eigenvalues_diag = diag(values);
cumulative_variance = cumsum(eigenvalues_diag);
total_variance = sum(eigenvalues_diag);
cumulative_contributions = cumulative_variance / total_variance *100;
disp(cumulative_contributions); %取第一個eigenvectors

%% 計算投資組合權重&報酬率
weight = vectors(:, 1);
tokens = {'btc', 'eth', 'bnb', 'xrp', 'sol'};
for i=1:5
    weight(i) = weight(i) / std(data.(tokens{i}));
end

weight = weight / sum(weight);
data.portfolio = weight(1) * data.btc + weight(2) * data.eth + weight(3) * data.bnb + ...
    weight(4) * data.xrp + weight(5) * data.sol;

%% Asset Pricing 
%以btc為例
lm = fitlm(data.btc, data.portfolio);
intercept = lm.Coefficients.Estimate(1);
slope = lm.Coefficients.Estimate(2);

theoretical_ret = intercept + slope * data.portfolio;
resid = data.btc - theoretical_ret;

%平滑處理
signal = (movmean(resid, 50) - movmean(resid, 100)) / std(movmean(resid, 100));
%signal = (resid - mean(resid)) / std(resid);

figure;
set(gcf, 'Position', [500, 500, 1500, 500]);
plot(signal);
xlabel('Time');
ylabel('Signals');
title('Trading Signals');
grid on;






