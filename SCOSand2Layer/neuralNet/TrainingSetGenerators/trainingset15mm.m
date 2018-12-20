tic
clear
clc
constants
aDb2 = aDb2(1);
ell=.6
Rep=5
T = (1:120)
tau = DelayTime(2:1:121);
Beta = 0.1:.1:.7
numSamples = size(aDb2,2)*size(aDb1,2)*size(ell,2)*size(Rep,2)*size(Beta,2);
amp = zeros(numSamples, size(tau,2));
tar = zeros(numSamples, 2);
j=0;
%db2 = aDb2(:,randperm(size(aDb2,2)));
aDb1 = aDb1(:, randperm(size(aDb1,2)));
for beta = Beta
for rep = 1:Rep
for i = 1:size(aDb2,2)
    i
    adb2 = aDb2(i);
    for adb1 = aDb1;
        for l = ell
            sep15 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,15,w,l,mua2,mus2,adb2);
            sep15zero = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,0,lambda,15,w,l,mua2,mus2,adb2);
            normsep15= sep15/sep15zero;
            [b, index15] = min(abs(normsep15-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(200e3,T,1,beta,gamma,tau);
            g2sep15 = 1+beta*normsep15.*normsep15;
            j = j+1;
            amp(j,:) = [normrnd(g2sep15, nsep15)];
            tar(j,:) = [adb1*1e7, beta];
        end
    end
end
end
end
scatter(log(tau),amp(1,1:120));
toc