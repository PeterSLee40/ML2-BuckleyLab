clc
tic
addpath('H:\SCOSand2Layer\functions');
constants

%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = DelayTime(1:1:80);
T = diff(DelayTime(1:1:81));
g= 0
repnumber = 0;

Db1 = 4.5e-9:.01e-9:5e-9;
Ratio = .30:.01:1;
ell = 0.95:.002:1.05;
Beta = 0.45:.005:0.50;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 5;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*size(Rep,2);
input = zeros(siz,3*size(tau,2));
target = zeros(siz,1);

int_time = 3;

load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    for ratio = Ratio1
        for l = ells
            db2 = db1*10^ratio;
            
            g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(1),w,l,mua2,mus2,db2,gl);
            normg1_10 = g1_10./g1_10(1);
            [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            sigma10 = getDCSNoise(300e3,T,int_time,beta,gamma,tau);
            
            sep15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
            normsep15 = sep15/sep15(1);
            [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(200e3,T,int_time,beta,gamma,tau); %50 hz.

            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
            normg1_25 = g1_25./g1_25(1);
            [b, index25] = min(abs(normg1_25-1/e));
            gamma = 1/tau(index25);
            sigma25 = getDCSNoise(20e3,T,int_time,beta,gamma,tau);
            for rep = Rep;
                noise10 = sigma10.*randn(length(tau),1)';
                g2_10 = 1 + beta.*normg1_10.^2 + noise10;
                noise15 = nsep15.*randn(length(tau),1)';
                g2_15 = beta.*normsep15.*normsep15 + noise15  + 1;
                j = j+1;
                for ds = 1:6
                    noise25 = sigma25.*randn(length(tau),1)';
                    g2_25a(ds,:) = noise25 + 1 + beta.*normg1_25.^2;
                end
                g2_25mean = mean(g2_25a, 1);
            end
            input(j,:) = [g2_25mean g2_15 g2_10];
            target(j,:) = [db2*1e8];
        end
    end
end
inputbeta = zeros(siz*size(Beta,2),size(input,2) + 1);
i = 0;
for bet = Beta
    indices = [1:siz] + siz*i;
    inputbet = (input - 1).*bet/0.5 + 1;
    inputbeta(indices, :) = [inputbet target];
    i = i + 1;
end

inputtargetshuffle = inputbeta(randperm(size(inputbeta,1)),:);
inputshuffle = inputtargetshuffle(:, 1:size(input,2));
inputshuffle2 = inputtargetshuffle(:, [1:size(tau,2) 161:size(input,2)]);
targetshuffle = inputtargetshuffle(:, size(input,2) + 1);
nnstart