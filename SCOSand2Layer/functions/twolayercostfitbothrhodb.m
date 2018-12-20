function [result] = twolayercostfitbothrhodb(all, beta, g2short, g2long,n,Reff,mua1,mus1,taushort, taulong,lambda,rho1,rho2,w,mua2,mus2)
%this function is meant to be a cost function to find db2 and depth given the
%following parameters within a two-layer model
db1 = all(1); %1/cm
db2 = all(2); %1/cm
ell = all(3); % cm

%plugs the values into a two layer model
curfitshort = diffusionforwardsolver(n,Reff,mua1,mus1,db1,taushort,lambda,rho1,w,ell,mua2,mus2,db2);
%normalizes g1
normfitshort = curfitshort/curfitshort(1);
%uses seigert relation to go from g1 to g2
fit_g2short = beta.*normfitshort.*normfitshort + 1;
%compares g2 to fitted g2.
curfitlong = diffusionforwardsolver(n,Reff,mua1,mus1,db1,taulong,lambda,rho2,w,ell,mua2,mus2,db2);
%normalizes g1
normfitlong = curfitlong/curfitlong(1);
%uses seigert relation to go from g1 to g2
fit_g2long = beta.*normfitlong.*normfitlong + 1;
%weights the long one a bit more since short may dominate long
result = norm((g2short + g2long*10e1 - fit_g2short - fit_g2long*10e1));
