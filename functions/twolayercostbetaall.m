function [result] = twolayercostbetaall(db1db2lbeta, g2,n,Reff,mua1,mus1,tau,lambda,rho,w,mua2,mus2)
%this function is meant to be a cost function to find db2 and depth given the
%following parameters within a two-layer model
Db1 = db1db2lbeta(1);
Db2 = db1db2lbeta(2);
ell = db1db2lbeta(3);
beta = db1db2lbeta(4);


curfit = diffusionforwardsolver(n,Reff,mua1,mus1,Db1,tau,lambda,rho,w,ell,mua2,mus2,Db2);
normfit = curfit/curfit(1);
%[b, index] = min(abs(normfit-1/exp(1))); %find where g1 = 1/e
%gamma = 1/tau(index);
%nsep15 = getDCSNoise(10e3,T,50,Beta,gamma,tau); %50 hz.
%noise = nsep15.*randn(length(tau),1)';
%g2 = Beta.*normsep15.*normsep15 + noise + 1;
fit_g2 = beta.*normfit.^2 + 1;

result = norm((g2 - fit_g2));
