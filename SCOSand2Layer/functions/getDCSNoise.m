function std =  getDCSNoise(intensity, T, inttime, beta, gamma, tau)
%std = 1./intensity.*sqrt(1./(t.*T)).*sqrt(1+beta.*exp(-tau*gamma));
a = (1./intensity');
b = sqrt(1./(inttime.*T));
c = sqrt(1+beta'.*exp(-tau.*gamma'));
std = a.*b.*c;
end