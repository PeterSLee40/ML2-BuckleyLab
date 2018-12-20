db1 = 4.8e-9;
constants
tau = DelayTime(1:100);
T = diff(DelayTime(1:101));

i = 0; j=0;
addpath('C:\functions');

betarand = randn(1)/1e2;
ellrand = randn(1)/1e2;
ratiorand = randn(1)/1e3;

beta = .495;
Ratio = .31: .1 + ratiorand:.99;
ell = .91:.01+ellrand :.99;
[X Y] = meshgrid(Ratio, ell);
inttime = 5;

Zdb1 = 0; Zl = 0; Zdb2 = 0;
for ratio = Ratio
    i = i+1;
    for l = ell
        j = j + 1;
            db2 = db1*10^ratio;
        
        g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.0,w,l,mua2,mus2,db2,gl);
        normg1_10 = g1_10./g1_10(1);
        [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
        gamma = 1/tau(index10);
        sigma10 = getDCSNoise(500e3,T,inttime,beta,gamma,tau);
        noise10 = sigma10.*randn(length(tau),1)';
        g2_10 = beta.*normg1_10.*normg1_10 + noise10  + 1;
        
        sep15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
        normsep15 = sep15/sep15(1);
        [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
        gamma = 1/tau(index15);
        nsep15 = getDCSNoise(350e3,T,inttime,beta,gamma,tau); %50 hz.
        noise15 = nsep15.*randn(length(tau),1)';
        g2_15 = beta.*normsep15.*normsep15 + noise15  + 1;
        
        sep20 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,2.0,w,l,mua2,mus2,db2,gl);
        normsep20 = sep20/sep20(1);
        [b, index20] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
        gamma20 = 1/tau(index15);
        nsep20 = getDCSNoise(100e3,T,inttime,beta,gamma20,tau); %50 hz.
        noise20 = nsep20.*randn(length(tau),1)';
        g2_20 = beta.*normsep20.*normsep20 + noise20  + 1;
        
        g1_30 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,3.0,w,l,mua2,mus2,db2,gl);
        normg2_30 = g1_30./g1_30(1);
        [b, index30] = min(abs(normg2_30-1/e));
        gamma = 1/tau(index30);
        sigma30 = getDCSNoise(12e3,T,inttime,beta,gamma,tau);
        
        for bs = 1:5
            noise30 = sigma30.*randn(length(tau),1)';
            g2_30(bs,:) = noise30 + 1 + beta.*normg2_30.^2;
        end
        
        %prediction = net([g2_25mean g2_15 g2_10]');
        input = [g2_30(:)' g2_20 g2_15 g2_10]';
        inputa = [g2_10 g2_15 g2_20 g2_30(:)']';
        prediction = net2(input);
        
        %Zdb1(j,i,:) = (preddb1 - db1)./db1*100;
        Zdb2(j,i,:) = ((prediction*1e-9) - db2)./db2*100;
        %Zl(j,i,:) = (prediction(3)- l)./l*100;
        
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