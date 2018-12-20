clc
tic
%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
addpath('C:\functions');
constants
ell = 0.75:.05:1.25;
T = T(1:100)

tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
g= 0
repnumber = 0;
Db1 = 1e-9:.5e-9:1e-8;
Ratio = 5:2:245;
Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
db1 = 1e-8;
j = 0;
Rep = 1:5;
load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    for rep = Rep
        for ratio = Ratio1
            for l = ells
                j = j+1;
                db2 = db1*ratio;
                
                g2_15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
                normg1_15 = g2_15./g2_15(1);
                [b, index15] = min(abs(normg1_15-1/e)); %find where g1 = 1/e
                gamma = 1/tau(index15);
                sigma15 = getDCSNoise(150e3,T,3,beta,gamma,tau);
                noise15 = sigma15.*randn(length(tau),1)';
                g2_15 = noise15 + 1 + beta.*normg1_15.^2;
                
%                 g2_10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1,w,l,mua2,mus2,db2);
%                 normg2_10 = g2_10./g2_10(1);
%                 [b, index10] = min(abs(normg2_10-1/e)); %find where g1 = 1/e
%                 gamma = 1/tau(index10);
%                 sigma10 = getDCSNoise(200e3,T,1,beta,gamma,tau);
%                 noise10 = sigma10.*randn(length(tau),1)';
%                 g2_10 = noise10 + 1 + beta.*normg2_10.^2;
                
                for i = 1:7
                    g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
                    normg1_25 = g1_25./g1_25(1);
                    [b, index25] = min(abs(normg1_25-1/e));
                    gamma = 1/tau(index25);
                    sigma25 = getDCSNoise(25e3,T,3,beta,gamma,tau);
                    noise25 = sigma25.*randn(length(tau),1)';
                    g2_25(i,:) = noise25 + 1 + beta.*normg1_25.^2;
                end
                g2_25mean = mean(g2_25);
                
                input(j,:) = [g2_25mean g2_15];
                target(j,:) = [db1*1e8 ratio*db1*1e6 l];
            end
        end
    end
    
end
nnstart
inputtarget = [input target];
inputtargetshuffle = inputtarget(randperm(size(inputtarget,1)),:);
inputshuffle = inputtargetshuffle(:,1:200);
targetshuffle = inputtargetshuffle(:,201:203);
nnstart