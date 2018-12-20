clc
tic
%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
addpath('C:\functions');
constants
ell = 0.8:.05:1.2;
T = T(2:2:252)

tau = DelayTime(1:1:50);
T = diff(DelayTime(1:1:51));
g= 0
repnumber = 0;
Db1 = 1e-9:1e-9:1e-8;
Ratio = .5:.01:2.0;
Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 1:5;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*size(Rep,2)
input = zeros(siz,100);
target = zeros(siz,3);


load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    for ratio = Ratio1
        for l = ells
            db2 = db1*10^ratio;
            
            g2_15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
            normg1_15 = g2_15./g2_15(1);
            [b, index15] = min(abs(normg1_15-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index15);
            sigma15 = getDCSNoise(150e3,T,3,beta,gamma,tau);
            noise15 = sigma15.*randn(length(tau),1)';
            g2_15 = noise15 + 1 + beta.*normg1_15.^2;
            
            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);

            normg1_25 = g1_25./g1_25(1);
            [b, index25] = min(abs(normg1_25-1/e));
            gamma = 1/tau(index25);
            sigma25 = getDCSNoise(25e3,T,3,beta,gamma,tau);
            
            for rep = Rep
                j = j+1;
                for i = 1:7
                    noise25 = sigma25.*randn(length(tau),1)';
                    g2_25(i,:) = noise25 + 1 + beta.*normg1_25.^2;
                end
                
                g2_25mean = mean(g2_25);
                
                input(j,:) = [g2_25mean g2_15];
                target(j,:) = [db1*1e8 db2*1e7 l];
            end
        end
    end
    
end

inputtarget = [input target];
inputtargetshuffle = inputtarget(randperm(size(inputtarget,1)),:);
inputshuffle = inputtargetshuffle(:, 1:100);
targetshuffle = inputtargetshuffle(:, 101:103);
inputshufflemovmean = [movmean(inputshuffle(:,1:50),5) movmean(inputshuffle(:,51:100),5)];
nnstart