function outfity = CmaskModelPredict(outfitx,fit_cft,wv,wvn)
%TIMESERIESPRE4 only 4 parameters-based time series model
% General model TSModel:
% f(x) = a0 + a1*cos(x*w) + b1*sin(x*w) +c2*(1/exp(wv))
    w = 2*pi/365.25;
    
    %default wvn = 1
    if ~exist('wv','var')
        wvn = 1;
    end
    
    if exist('wv','var')&& length(wv)>0
        outfity=[ones(size(outfitx))...% overall ref + trending
                cos(w*outfitx),sin(w*outfitx),...% add seasonality
                1./exp(wv).^wvn]...
                *fit_cft; 
    else
        outfity=[ones(size(outfitx)),outfitx,...% overall ref + trending
                cos(w*outfitx),sin(w*outfitx)]...% add seasonality
                *fit_cft; 
    end
end

