db1 = 8.00e-9;
i = 0; j=0;
addpath('C:\Users\Peter LEe\Documents\SCOSand2Layer\functions');
constants

beta = .50
Ratio = .33:.122:.99;
ell = .96:.011:1.04;
[X Y] = meshgrid(Ratio, ell);
noise = true;
Rep = 0;
net = @TSG_db2_1_500_300;
i = 0; j =0;
tau = 5e-6:5e-6:3e-4;
T = 5e-6.*ones(1,size(tau,2));
Zdb1 = 0; Zl = 0; Zdb2 = 0;
load gauss_lag_5000.mat
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
        
        g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
        normg1_25 = g1_25./g1_25(1);
        [b, index25] = min(abs(normg1_25-1/e));
        gamma = 1/tau(index25);
        sigma25 = getDCSNoise(300e3,T,3,beta,gamma,tau);
        for rep = Rep
            if noise == true
                for ds = 1:1
                    noise25 = sigma25.*randn(length(tau),1)';
                    g2_25a(ds,:) = noise25 + beta.*normg1_25.^2 + 1;
                end
                g2_25mean = mean(g2_25a, 1);
            else
                g2_25mean = 1 + beta.*normg1_25.^2;
            end
            netinput = [g2_25mean g2_10];
            input = ([g2_25mean denoisenet1_10_400_bay(g2_10)]);
        end
        prediction = net(input);
        Zdb2(j,i,:) = ((prediction(1)*1e-9) - db2)./db2*100;
        
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
histogram(Zdb2(:),10);