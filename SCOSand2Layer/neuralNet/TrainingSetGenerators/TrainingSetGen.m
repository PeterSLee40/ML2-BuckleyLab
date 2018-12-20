tic
clear
clc
DelayMaker
constants
T = (1:120)
tau = DelayTime(2:1:121);
numSamples = size(aDb2,2)*size(aDb1,2)*size(ell,2)
%setting up input and target
input = zeros(numSamples, size(tau,2)*2);
target= zeros(numSamples, 3);
j=0;
%shuffles the db2s and db1s
aDb2 = aDb2(:,randperm(size(aDb2,2)));
aDb1 = aDb1(:, randperm(size(aDb1,2)));
for i = 1:size(aDb2,2)
    i
    adb2 = aDb2(i);
    for adb1 = aDb1;
        for l = ell
            sep10 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,rho(1),w,l,mua2,mus2,adb2);
            %normalizes g1
            normsep10 = sep10/sep10(1);
            %needed parameters for realistic noise model, Chao thesis eq
            %2.45
            [b, index10] = min(abs(normsep10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            nsep10 = getDCSNoise(250e3,T,1,beta,gamma,tau);
            g2sep10 = 1+beta*normsep10.*normsep10;
            sep25 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,rho(2),w,l,mua2,mus2,adb2);
            normsep25 = sep25/sep25(1);
            [b, index25] = min(abs(normsep25-1/e));
            gamma = 1/tau(index25);
            nsep25 = getDCSNoise(50e3,T,1,beta,gamma,tau);
            g2sep25 = 1+beta*normsep25.*normsep25;
            j = j+1;
            input(j,:) = [normrnd(g2sep10,1e2*nsep10), normrnd(g2sep25,nsep25)];
            target(j,:) = [adb1*1e7, adb2*1e7, l];
        end
    end
end
scatter(log(tau),input(1,1:120));
toc