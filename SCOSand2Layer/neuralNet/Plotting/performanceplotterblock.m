db1 = 5e-9;
constants
tau = DelayTime(1:50);
T = diff(DelayTime(1:51));
Ratio = 1:.125:2.25
ell = .9:.025:1.1;
[X Y] = meshgrid(Ratio, ell);
i = 0; j=0;
addpath('C:\functions');

for ratio = Ratio
    i = i+1;
    for l = ell
        j = j + 1;
        db2 = db1*10^(ratio);
        
        g2_15 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2);
        normg2_15 = g2_15./g2_15(1);
        [b, index15] = min(abs(normg2_15-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index15);
        sigma15 = getDCSNoise(150e3,T,3,beta,gamma,tau);
        noise15 = sigma15.*randn(length(tau),1)';
        g2_15 = noise15 + 1 + beta.*normg2_15.^2;
        
        g2_10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1,w,l,mua2,mus2,db2);
        normg2_10 = g2_10./g2_10(1);
        [b, index10] = min(abs(normg2_10-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index10);
        sigma10 = getDCSNoise(250e3,T,3,beta,gamma,tau);
        noise10 = sigma10.*randn(length(tau),1)';
        g2_10 = noise10 + 1 + beta.*normg2_10.^2;
        
        
        for bs = 1:7
        g1_25 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2);
        normg2_25 = g1_25./g1_25(1);
        [b, index25] = min(abs(normg2_25-1/e));
        gamma = 1/tau(index25);
        sigma25 = getDCSNoise(25e3,T,3,beta,gamma,tau);
        noise25 = sigma25.*randn(length(tau),1)';
        g2_25(bs,:) = noise25 + 1 + beta.*normg2_25.^2;
        end
        g2_25mean = mean(g2_25);
        
        %prediction = net([g2_25mean g2_15 g2_10]');
        pred1 = blocknet1([g2_25mean g2_15]');
        pred2 = blocknet2([g2_25mean g2_15]');
        pred3 = blocknet3([g2_25mean g2_15]');
        pred4 = blocknet4([g2_25mean g2_15]');
        meanpred = mean([pred1(2) pred2(2) pred3(2) pred4(2)]);
        
        Z(j,i,:) = (meanpred*1e-7-db2)./db2*100;
        %Z(j,i,:) = (prediction(3)-l)./l;
    end
    j = 0;
end
surf(X,Y,Z), colorbar;
xlabel('log(ratio of db1/db2)');
ylabel('thickness');
zlabel('Percent Error');
set(gca,'YDir','reverse');
c = colorbar;
caxis([-20 20]);  