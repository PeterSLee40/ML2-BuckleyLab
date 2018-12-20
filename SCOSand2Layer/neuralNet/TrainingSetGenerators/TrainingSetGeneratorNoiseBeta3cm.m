clc
tic
addpath('H:\SCOSand2Layer\functions');
constants

%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
%change this to add noise
noise = false;

ell = 0.75:.1:1.25;
tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
g= 0
repnumber = 0;
Db1 = 1e-9:.5e-9:1e-8;
Ratio = .25:.01:1.0;
Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
db1 = 1e-8;
j = 0;
Rep = 1;
Beta = 0.35:.05:.55;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*size(Rep,2);
input = zeros(siz,300);
target = zeros(siz,3);
beta = .5;

load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    for ratio = Ratio1
        for l = ells
            db2 = db1*10^ratio;
            g2_15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
            normg1_15 = g2_15./g2_15(1);
            if noise == true
                [b, index15] = min(abs(normg1_15-1/e)); %find where g1 = 1/e
                gamma = 1/tau(index15);
                sigma15 = getDCSNoise(200e3,T,3,beta,gamma,tau);
                noise15 = sigma15.*randn(length(tau),1)';
            end
            noise15 = 0;
            g2_15 = noise15 + 1 + beta.*normg1_15.^2;
            
            g1_10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,1,w,l,mua2,mus2,db2);
            normg1_10 = g1_10./g1_10(1);
            %             [b, index10] = min(abs(normg2_10-1/e)); %find where g1 = 1/e
            %             gamma = 1/tau(index10);
            %             sigma10 = getDCSNoise(250e3,T,3,beta,gamma,tau);
            %             noise10 = sigma10.*randn(length(tau),1)';
            noise10 = 0;
            g2_10 = noise10 + 1 + beta.*normg1_10.^2;
            
            g1_30 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,3.0,w,l,mua2,mus2,db2,gl);
            normg1_30 = g1_30./g1_30(1);
            if noise == true
                [b, index25] = min(abs(normg1_30-1/e));
                gamma = 1/tau(index25);
                sigma30 = getDCSNoise(25e3,T,3,beta,gamma,tau);
            end
            
            for rep = Rep
                j = j+1;
                if noise == true
                    for i = 1:7
                        noise30 = sigma30.*randn(length(tau),1)';
                        noise30 = 0;
                        g2_30(i,:) = noise30 + 1 + beta.*normg1_30.^2;
                    end
                    g2_30mean = mean(g2_30);
                else
                    g2_30mean = 1 + beta.*normg1_30.^2;
                end
                input(j,:) = [g2_30mean g2_15 g2_10];
                target(j,:) = [db1*1e8 db2*1e8 l];
            end
        end
    end
end
inputbeta = zeros(siz*size(Beta,2),300);
targetbeta = zeros(siz*size(Beta,2),3);
i = 0;
for bet = Beta
    indices = [1:siz] + siz*i;
    inputbeta(indices, :) = (input - 1).*bet/0.5 + 1;
    targetbeta(indices,:) = target;
    i = i + 1;
end
inputb = inputbeta;
targetb = targetbeta;
inputtarget = [inputb targetb];
inputtargetshuffle = inputtarget(randperm(size(inputtarget,1)),:);
inputshuffle = inputtargetshuffle(:, 1:300);
targetshuffle = inputtargetshuffle(:, 301:303);
inputshufflemovmean = movmean(inputshuffle,5);
inputshuffle2=inputtargetshuffle(:, 1:200);
inputshuffle1cm=inputtargetshuffle(:, [1:100 201:300]);
nnstart