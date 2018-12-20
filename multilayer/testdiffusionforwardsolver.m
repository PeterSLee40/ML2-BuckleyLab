g21 = diffusionforwardsolver(n,Reff,mua1,mus1,2*db1,tau,lambda*1e-9,rho,w,l,mua2,mus2,db2);
g22 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda*1e-9,rho,w,l,mua2,mus2,db2);
tau = tau(1:130);
plot(log(tau),g21);
hold on
plot(log(tau),g22);
