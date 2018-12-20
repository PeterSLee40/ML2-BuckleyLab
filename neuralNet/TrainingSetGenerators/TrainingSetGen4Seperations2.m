clc
tic
addpath('E:\SCOSand2Layer\functions');
constants
T = T(1:50);
ell = 0.7:.1:1.4;
tau = DelayTime(1:50);
Reps = 5;
g= 0
j=0;
adb1 = 1e-8;
Ratio = -2.5:.25:-.25;
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
for i = 1:Reps
    i
    for ratio = Ratio
        adb2 = adb1*10^(-ratio);
        for l = ells
            %calculate g2 for the 25 seperation.
            sep25 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,rho(2),w,l,mua2,mus2,adb2);
            normsep25 = sep25/sep25(1);
            %[b, index25] = min(abs(normsep25-1/e));
            %gamma = 1/tau(index25);
            %nsep25 = getDCSNoise(50e3,T,1,beta,gamma,tau);
            g2sep25 = 1+beta*normsep25.*normsep25;
            %adding it all to the dataset
            j = j+1;
            sep15 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,1.5,w,l,mua2,mus2,adb2);
            normsep15= sep15/sep15(1);
            %[b, index15] = min(abs(normsep15-1/e)); %find where g1 = 1/e
            %gamma = 1/tau(index15);
            %nsep15 = getDCSNoise(200e3,T,1,beta,gamma,tau);
            g2sep15 = 1+beta*normsep15.*normsep15;
            amp(j,:) = [g2sep25 g2sep15];
            tar(j,:) = [adb1*1e7 adb2*1e7, l];
        end
    end
end

%amp = amp./max(max(amp));
%tar = tar./max(tar,[],1);
toc