function [normg1, gamma] = Copy_of_getG1(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2)
g1 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho',w,l,mua2,mus2,db2);
normg1 = g1./g1(:,1,:);
[~, index] = min(abs(normg1-1/exp(1)));
gamma = 1./tau(squeeze(index));
end