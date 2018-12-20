db1 = 8.0e-9;

i = 0; j=0;
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\functions');
constants
betarand = randn(1)/1e2;
ellrand = randn(1)/1e3;
ratiorand = randn(1)/1e3;

beta = .5
Ratio = .33:.122:.99;
ell = .96:.011:1.04;
[X Y] = meshgrid(Ratio, ell);
noise = true;
i = 0; j =0;

Zdb1 = 0; Zl = 0; Zdb2 = 0;
for ratio = Ratio
    i = i+1
    for l = ell
        j = j + 1;
        db2 = db1*10^ratio;
        
        g1_10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1.0,w,l,mua2,mus2,db2);
        normg1_10 = g1_10./g1_10(1);
        [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index10);
        sigma10 = getDCSNoise(500e3,T,3,beta,gamma,tau);
        noise10 = sigma10.*randn(length(tau),1)';
        %noise10 = 0;
        g2_10 = noise10 + 1 + beta.*normg1_10.^2;
        
        sep15 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2);
        normsep15 = sep15/sep15(1);
        [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
        gamma = 1/tau(index15);
        nsep15 = getDCSNoise(300e3,T,3,beta,gamma,tau); %50 hz.
        noise15 = nsep15.*randn(length(tau),1)';
        g2_15 = beta.*normsep15.*normsep15 + noise15  + 1;
        
        sep20 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2);
            normsep20 = sep20/sep20(1);
            [b, index20] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma20 = 1/tau(index15);
            nsep20 = getDCSNoise(250e3,T,5,beta,gamma20,tau); %50 hz.
            noise20 = nsep20.*randn(length(tau),1)';
            g2_20 = beta.*normsep20.*normsep20 + noise20  + 1;
        
        g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
        normg1_25 = g1_25./g1_25(1);
        [b, index25] = min(abs(normg1_25-1/e));
        gamma = 1/tau(index25);
        sigma25 = getDCSNoise(20e3,T,3,beta,gamma,tau);
        for rep = Rep
            if noise == true
                for ds = 1:6
                    noise25 = sigma25.*randn(length(tau),1)';
                    g2_25a(ds,:) = noise25 + beta.*normg1_25.^2 + 1;
                end
                g2_25mean = mean(g2_25a, 1);
            else
                g2_25mean = 1 + beta.*normg1_25.^2;
            end
            netinput = [strokefilter(g2_25mean,5) strokefilter(g2_10,5)];
        end
        prediction = net(netinput');
        Zdb2(j,i,:) = ((prediction(1)*1e-8) - db2)./db2*100;
        
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