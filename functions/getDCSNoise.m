function std =  getDCSNoise(intensity, T, t, beta, gamma, tau)
%std = 1./intensity.*sqrt(1./(t.*T)).*sqrt(1+beta.*exp(-tau*gamma));
std = (1./intensity).*sqrt(1./(t.*T)).*sqrt(1+beta.*exp(-gamma.*tau));
end