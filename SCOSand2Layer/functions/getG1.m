function [normg1, gamma] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2,gl)
g1 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2,gl);
normg1 = g1./g1(1);
[~, index] = min(abs(normg1-1/exp(1)));
gamma = 1/tau(index);
end