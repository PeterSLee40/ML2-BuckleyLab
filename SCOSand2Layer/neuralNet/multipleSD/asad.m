addpath("C:\Users\PeterLee\Documents\GitHub\BuckleyLab\SCOSand2Layer\functions")
tic
g = [1:100];
for a = 1:1e3
   g2 = diffusionforwardsolverEB(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2);
end
toc
tic
for a = 1:1e3
    g1 = diffusionforwardsolverPL(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2,gl);
end
toc