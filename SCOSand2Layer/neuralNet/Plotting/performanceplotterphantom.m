db1 = 5e-9;

i = 0; j=0;
addpath('C:\functions');
constants;

betarand = randn(1)/1e2;
ellrand = randn(1)/1e3;
ratiorand = randn(1)/1e3;

beta = .5
Ratio = .33:.122:.99;
ell = .96:.011:1.04;
[X Y] = meshgrid(Ratio, ell);
noise = true;
i = 0; j =0;
load gauss_lag_5000.mat
inttime = 10;
Zdb1 = 0; Zl = 0; Zdb2 = 0;
tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
Rep = 1;
for ratio = Ratio
    i = i+1
    for l = ell
                j = j + 1;

        db2 = db1*10^ratio;

            g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.00,w,l,mua2,mus2,db2,gl);
            normg1_10 = g1_10./g1_10(1);
            [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            sigma10 = getDCSNoise(500e3,T,inttime,beta,gamma,tau);
            
            sep15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
            normsep15 = sep15/sep15(1);
            [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(400e3,T,inttime,beta,gamma,tau); %50 hz.
            
            sep20 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,2.0,w,l,mua2,mus2,db2,gl);
            normsep20 = sep20/sep20(1);
            [b, index20] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma20 = 1/tau(index15);
            nsep20 = getDCSNoise(200e3,T,inttime,beta,gamma20,tau); %50 hz.
            
            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,2.5,w,l,mua2,mus2,db2,gl);
            normg1_25 = g1_25./g1_25(1);
            [b, index25] = min(abs(normg1_25-1/e));
            gamma = 1/tau(index25);
            sigma25 = getDCSNoise(80e3,T,inttime,beta,gamma,tau);
            
            g1_30 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,3.0,w,l,mua2,mus2,db2,gl);
            normg1_30 = g1_30./g1_30(1);
            [b, index30] = min(abs(normg1_30-1/e));
            gamma = 1/tau(index30);
            sigma30 = getDCSNoise(40e3,T,inttime,beta,gamma,tau);
            
            for rep = 1:Rep
                noise10_1 = sigma10.*randn(length(tau),1)';
                noise10_2 = sigma10.*randn(length(tau),1)';
                g2_10nn=  1 + beta.*normg1_10.^2;
                g2_10 = noise10_1 + g2_10nn;
                %                 g2_10fit = strokefilter(g2_10,10);
                
                noise15 = nsep15.*randn(length(tau),1)';
                g2_15 = beta.*normsep15.*normsep15 + noise15  + 1;
                
                noise20 = nsep20.*randn(length(tau),1)';
                g2_20 = beta.*normsep20.*normsep20 + noise20  + 1;
                for ds = 1:4
                    noise30 = sigma30.*randn(length(tau),1)';
                    g2_30 = beta.*normg1_30.^2;
                    g2_30a(ds,:) = noise30 + 1 + beta.*normg1_30.^2;
                end
                g2_30mean = mean(g2_30a, 1);

                for ds = 1:1
                    noise25 = sigma25.*randn(length(tau),1)';
                    g2_25nn = beta.*normg1_25.^2;
                    g2_25a(ds,:) = noise25 + g2_25nn + 1;
                end
                
                input = fliplr(single([g2_30a(:)' g2_25a(:)' g2_20 g2_15 g2_10]));
                prediction = PhantomNet1(input);
                Zdb2(j,i,:) = ((prediction(1)*1e-9) - db2)./db2*100;
            end
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