function [w1, w2] = genDurSeq(nTrl, plotSign)

% first generate the random walk sequence
w1 = cumsum(randn(1, nTrl));
w1 = (w1 - mean(w1))/std(w1); % normalize
% appr. scale to 0.5 to 2
w1 = w1/(max(w1)-min(w1))*1.6 + 1;

% discretize to 100 ms
w1 = round(w1*10)/10;

% another sequence with randomization
w2 = w1(randperm( length(w1) ) );

if plotSign == 1
    figure(); hold on;  subplot(2,2,1);plot(w1)
    subplot(2,2,2);hist(w1);
    subplot(2,2,3);plot(w2)
    subplot(2,2,4);hist(w2);
end
% 
%estHighHurst = estimate_hurst_exponent(w1)
%estLowHurst = estimate_hurst_exponent(w2)