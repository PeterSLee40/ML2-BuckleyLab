function [result] = twolayercostfitbothdb(all, beta, g2,n,Reff,mua1,mus1,tau,lambda,rho,w,mua2,mus2)
%this function is meant to be a cost function to find db2 and depth given the
%following parameters within a two-layer model
db1 = all(1); %1/cm
db2 = all(2); %1/cm
ell = all(3); % cm
%plugs the values into a two layer model
curfit = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,ell,mua2,mus2,db2);
%normalizes g1
normfit = curfit/curfit(1);
%uses seigert relation to go from g1 to g2
fit_g2 = beta.*normfit.*normfit + 1;
%compares g2 to fitted g2.
result = norm((g2 - fit_g2));
