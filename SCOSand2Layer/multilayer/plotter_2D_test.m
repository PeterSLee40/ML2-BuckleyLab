tic
clear
clc
DelayMaker
constants
tau = DelayTime(1:120);
amp = zeros(size(aDb2,2)*size(aDb1,2)*size(ell,2), size(tau,2));
j=0;
for i = 1:size(aDb2,2)
    i
    adb2 = aDb2(i);
    for adb1 = aDb1
        for l = ell
            ans1 = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,1,w,l,mua2,mus2,adb2);
            ans1zero = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,0,lambda,1,w,l,mua2,mus2,adb2);
            ans1norm = ans1/ans1(1);
            j = j + 1;
            amp(j,:) = 1+beta*ans1norm.^2;
        end
    end
end

for k = 1:j
    scatter(log(tau), amp(k, :));
    hold on
end

toc