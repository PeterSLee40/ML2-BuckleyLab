
tau1=DelayTime;
a=diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau1,lambda,rho,w,1,mua2,mus2,db2);
b=diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau1,lambda,rho,w,20,mua2,mus2,db2);
a=a/a(1);
b=b/b(1);
scatter(log(tau1),a);
hold on
scatter(log(tau1),b);