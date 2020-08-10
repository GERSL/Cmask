function [fit_cft, rmse]= CmaskModelFit(x,y,wv,wvn)
%FITTIMESERIES fits time series models
% INPUTS:
% x - Julian day [1; 2; 3];
% y - predicted reflectances [0.1; 0.2; 0.3];
% df - degree of freedom (num_c)
%;
% OUTPUTS:
% fit_cft - fitted coefficients;
% General model TSModel:
% f(x) = a0 + a1*cos(x*w) + b1*sin(x*w) +c2*(1/exp(wv))
    y_lg0 = y < 0;
    y(y_lg0) = 0;
    
    addwv = 0;
    if exist('wv','var') && length(wv)>1
        addwv = 1;
    else
        wv = 0;
    end
    
    if ~exist('wvn','var')
        wvn = 1;
    else
        wvn = double(wvn);
    end

    n=length(x); % number of clear pixels
    % num_yrs = 365.25; % number of days per year
    w=2*pi/365.25; % num_yrs; % anual cycle
    % fit coefs
    fit_cft = zeros(3+addwv,1);

    % build X
    X = zeros(n,4 + addwv-2);
    
    X(:,1)=cos(w*x);
    X(:,2)=sin(w*x);
    
    if addwv >0
        X(:,end) =  1./exp(wv);
    end
    
    % Robust fitting
    [fit,stats] = robustfit(X, y);
    ids_stats_w = stats.w;
    ids_stats_w = ids_stats_w>0;
    fit_cft(1:4) = fit(1:4); % curr_cft;
    
    yhat = CmaskModelPredict(x,fit_cft,wv,wvn);
    rmse = RMSE(y(ids_stats_w),yhat(ids_stats_w));
    % f(x) = a0 + a1*cos(x*w) + b1*sin(x*w) +c1*wv (df = 4)
end
function r=RMSE(data,estimate)
    % Function to calculate root mean square error from a data vector or matrix 
    % and the corresponding estimates.
    % Usage: r=rmse(data,estimate)
    % Note: data and estimates have to be of same size
    % Example: r=rmse(randn(100,100),randn(100,100));
    % delete records with NaNs in both datasets first
    I = ~isnan(data) & ~isnan(estimate); 
    data = data(I); estimate = estimate(I);
    r=sqrt(sum((data(:)-estimate(:)).^2)/numel(data));
end