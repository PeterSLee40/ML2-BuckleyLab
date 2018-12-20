tic
DelayMaker
constants
tau = DelayTime(1:120);
for i = 1:size(aDb2,2)
    i
    adb2 = aDb2(i);
    for adb1 = aDb1
        for l = ell
            amp = diffusionforwardsolver(n,Reff,mua1,mus1,adb1,tau,lambda,rho(1),w,l,mua2,mus2,adb2);
            g2 = amp;
            scatter(log(tau), g2);
            hold on
        end
    end
end
toc