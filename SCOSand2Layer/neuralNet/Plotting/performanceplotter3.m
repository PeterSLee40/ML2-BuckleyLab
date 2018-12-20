db1 = (5 + randn(1)/100)*1e-9;
constants
tau = DelayTime(1:100);
T = diff(DelayTime(1:101));

i = 0; j=0;
addpath('C:\functions');

betarand = randn(1)/1e2;
ellrand = randn(1)/1e3;
ratiorand = randn(1)/1e3;

beta = .525 + betarand; 
Ratio = .3: .1 + ratiorand:1.0;
ell = .81:.05+ellrand :1.1;
[X Y] = meshgrid(Ratio, ell);

Zdb1 = 0; Zl = 0; Zdb2 = 0;
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
        noise15 = 0;
        g2_15 = noise15 + 1 + beta.*normg2_15.^2;
        
        g2_10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1,w,l,mua2,mus2,db2);
        normg2_10 = g2_10./g2_10(1);
        [b, index10] = min(abs(normg2_10-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index10);
        sigma10 = getDCSNoise(250e3,T,3,beta,gamma,tau);
        noise10 = sigma10.*randn(length(tau),1)';
        noise10 = 0;
        g2_10 = noise10 + 1 + beta.*normg2_10.^2;
        
        
        for bs = 1:7
        g1_30 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,3.0,w,l,mua2,mus2,db2);
        normg2_30 = g1_30./g1_30(1);
        [b, index30] = min(abs(normg2_30-1/e));
        gamma = 1/tau(index30);
        sigma30 = getDCSNoise(25e3,T,3,beta,gamma,tau);
        noise30 = sigma30.*randn(length(tau),1)';
        noise30 = 0;
        g2_30(bs,:) = noise30 + 1 + beta.*normg2_30.^2;
        end
        g2_25mean = mean(g2_30);
        
        %prediction = net([g2_25mean g2_15 g2_10]');
        prediction = net([g2_30(1,:) g2_15]');
        
        preddb1 = prediction(1)/1e8;
        Zdb1(j,i,:) = (preddb1 - db1)./db1*100;
        Zdb2(j,i,:) = ((prediction(2)*1e-8) - db2)./db2*100;
        Zl(j,i,:) = (prediction(3)- l)./l*100;
        
        %Z(j,i,:) = (prediction(3)-l)./l;
    end
    j = 0;
end
surf(X,Y,Zdb2), colorbar;
xlabel('log(ratio of db1/db2)');
ylabel('thickness');
zlabel('Percent Error in db2');
set(gca,'YDir','reverse');
c = colorbar;
caxis([-20 20]);  