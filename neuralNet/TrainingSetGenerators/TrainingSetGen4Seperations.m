clc
tic
DelayMaker
constants
T = T(1:1:130);
tau = DelayTime(2:1:131);
Reps = 5;
numSamples = size(aDb2,2)*size(aDb1,2)*size(ell,2)*Reps;
amp = zeros(numSamples, size(tau,2)*4);
tar = zeros(numSamples, 2);
j=0;
aDb2 = aDb2(:,randperm(size(aDb2,2)));
aDb1 = aDb1(:, randperm(size(aDb1,2)));
ell = ell(:, randperm(size(ell,2)));
for i = 1:Reps
for adb2 = aDb2
    for adb1 = aDb1
        for l = ell
            %calculate g2 for the 10cm seperation.
            sep10 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,10,w,l,mua2,mus2,adb2);
            sep10zero = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,0,lambda,10,w,l,mua2,mus2,adb2);
            normsep10 = sep10/sep10zero;
            [b, index10] = min(abs(normsep10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            nsep10 = getDCSNoise(250e3,T,1,beta,gamma,tau);
            g2sep10 = 1+beta*normsep10.*normsep10;
            %calculate g2 for the 15 seperation.
            sep15 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,15,w,l,mua2,mus2,adb2);
            sep15zero = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,0,lambda,15,w,l,mua2,mus2,adb2);
            normsep15 = sep15/sep15zero;
            [b, index15] = min(abs(normsep15-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(150e3,T,1,beta,gamma,tau);
            g2sep15 = 1+beta*normsep15.*normsep15;
            %calculate g2 for the 20 seperation.
            sep20 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,rho(2),w,l,mua2,mus2,adb2);
            sep20zero = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,0,lambda,rho(2),w,l,mua2,mus2,adb2);
            normsep20 = sep20/sep20zero;
            [b, index20] = min(abs(normsep20-1/e));
            gamma = 1/tau(index20);
            nsep20 = getDCSNoise(100e3,T,1,beta,gamma,tau);
            g2sep20 = 1+beta*normsep20.*normsep20;
            %calculate g2 for the 25 seperation.
            sep25 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,rho(2),w,l,mua2,mus2,adb2);
            sep25zero = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,0,lambda,rho(2),w,l,mua2,mus2,adb2);
            normsep25 = sep25/sep25zero;
            [b, index25] = min(abs(normsep25-1/e));
            gamma = 1/tau(index25);
            nsep25 = getDCSNoise(50e3,T,1,beta,gamma,tau);
            g2sep25 = 1+beta*normsep25.*normsep25;
            %adding it all to the dataset
            j = j+1;
            amp(j,:) = [normrnd(g2sep10,nsep10), normrnd(g2sep15,nsep15),normrnd(g2sep20,nsep20),normrnd(g2sep25,nsep25)];
            tar(j,:) = [adb2*5e7, l];
        end
    end
end
end
scatter(log(tau),amp(1,1:size(tau,2)));
%amp = amp./max(max(amp));
%tar = tar./max(tar,[],1);
toc