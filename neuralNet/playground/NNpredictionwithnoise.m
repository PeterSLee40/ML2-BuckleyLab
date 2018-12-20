db1 = 1e-8;
[X Y] = meshgrid(Ratio, ell);
i = 0; j=0;
for ratio = Ratio
    i = i+1;
    for l = ell
        j = j + 1;
        db2 = db1*10^(-ratio);
        
        g2_15 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2);
        normg2_15 = g2_15./g2_15(1);
        [b, index15] = min(abs(normg2_15-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index15);
        sigma15 = getDCSNoise(150e3,T,1,beta,gamma,tau);
        noise15 = sigma15.*randn(length(tau),1)';
        g2_15 = noise15 + 1 + beta.*normg2_15.^2;
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
        
        prediction = netfirst([g2_25mean g2_15]');
        Z(j,i,:) = (prediction(2)-db2)./db2;
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