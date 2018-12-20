clc
tic
addpath('E:\SCOSand2Layer\functions');
constants
T = T(1:1:130);
ell = 0.7:.1:1.4;
tau = DelayTime(2:1:131);
Reps = 5;
g= 0
j=0;
adb1 = 1e-8;
Ratio = -2.5:.25:-.25;
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
db1 = 1e-8;
j = 0;
Rep = 1:10;
for rep = Rep
    rep
for ratio = Ratio1
    for l = ells
        j = j+1;
        db2 = db1*10^(-ratio);
        
        g2_15 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2);
        normg2_15 = g2_15./g2_15(1);
        [b, index15] = min(abs(normg2_15-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index15);
        sigma15 = getDCSNoise(150e3,T,1,beta,gamma,tau);
        noise15 = sigma15.*randn(length(tau),1)';
        g2_15 = noise15 + 1 + beta.*normg2_15.^2;
        
        g2_10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1,w,l,mua2,mus2,db2);
        normg2_10 = g2_10./g2_10(1);
        [b, index10] = min(abs(normg2_10-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index10);
        sigma10 = getDCSNoise(200e3,T,1,beta,gamma,tau);
        noise10 = sigma10.*randn(length(tau),1)';
        g2_10 = noise10 + 1 + beta.*normg2_10.^2;
        
        for i = 1:7
        g1_25 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2);
        normg2_25 = g1_25./g1_25(1);
        [b, index25] = min(abs(normg2_25-1/e));
        gamma = 1/tau(index25);
        sigma25 = getDCSNoise(30e3,T,1,beta,gamma,tau);
        noise25 = sigma25.*randn(length(tau),1)';
        g2_25(i,:) = noise25 + 1 + beta.*normg2_25.^2;
        end
        g2_25mean = mean(g2_25);
        
        input(j,:) = [g2_25mean g2_15];
        target(j,:) = [db2*1e7 l];
    end
end
end
nnstart