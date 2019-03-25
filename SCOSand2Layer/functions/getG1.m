function [normg1, gamma, p] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2, gl)
[g1, p] = diffusionforwardsolverPL(n,Reff,mua1,mus1,db1,tau,lambda,rho',w,l,mua2,mus2,db2, gl);
normg1 = g1./diffusionforwardsolverPL(n,Reff,mua1,mus1,db1,0,lambda,rho',w,l,mua2,mus2,db2, gl);
[~, index] = min(abs(normg1-1/exp(1)));
gamma = 1./tau(squeeze(index));
end 