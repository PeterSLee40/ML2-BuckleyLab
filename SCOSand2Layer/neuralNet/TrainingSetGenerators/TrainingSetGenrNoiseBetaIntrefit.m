clc
tic
addpath('H:\SCOSand2Layer\functions');
constants

%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = 1e-7:.5e-6:1e-3
T = diff([tau 1e-3]);

g= 0
repnumber = 0;

Db1 = 4.5e-9:.02e-9:5.0e-9;
Ratio = .30:.01:1;  
ell = 0.95:.0025:1.05;
Beta = 0.45:.005:0.50;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 5;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*size(Rep,2);
input = zeros(siz,3*size(tau,2));
noise = input;
target = zeros(siz,1);

int_time = 3;
filtersize = 5;

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
            sigma10 = getDCSNoise(500e3,T,int_time,beta,gamma,tau);
            
            sep15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
            normsep15 = sep15/sep15(1);
            [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(300e3,T,int_time,beta,gamma,tau); %50 hz.
            
            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
            normg1_25 = g1_25./g1_25(1);
            [b, index25] = min(abs(normg1_25-1/e));
            gamma = 1/tau(index25);
            sigma25 = getDCSNoise(20e3,T,int_time,beta,gamma,tau);
            for rep = Rep;
                noise10 = sigma10.*randn(length(tau),1)';
                g2_10nn = 1 + beta.*normg1_10.^2;
                g2_10 = g2_10nn + noise10;
                g2_10fit = strokefilter(g2_10,5);
                noise15 = nsep15.*randn(length(tau),1)';
                g2_15 = beta.*normsep15.*normsep15 + noise15  + 1;

                j = j+1;
                for ds = 1:6
                    noise25 = sigma25.*randn(length(tau),1)';
                    noise25a(ds,:) = noise25;
                end
                
                g2_25noise = mean(noise25a, 1);
                g2_25mean = 1+beta.*g1_25.^2+g2_25noise;
                g2_25fit = strokefilter(g2_25mean,5);
                noise(j,:) = [g2_25noise noise15 noise10];
                input(j,:) = [g2_25fit g2_15 g2_10fit];
                target(j,:) = [db2*1e8];
                ell(j,:) = l;
            end
        end
    end
end
inputbeta = zeros(size(input,1)*size(Beta,2),size(input,2) + 1);
i = 0;
for bet = Beta
    indices = [1:siz] + siz*i;
    inputbet = (input - 1).*bet/0.5 + 1;
    inputbeta(indices, :) = [inputbet target];
    i = i + 1;
end
inputbeta =  inputbeta(randperm(size(input,1)*size(Beta,2)),:);
inputshuffle = inputbeta(:, 1:size(input,2));
inputshuffle2 = inputbeta(:, [1:size(tau,2) size(tau,2)*2+1:size(input,2)]);
targetshuffle = inputbeta(:, size(input,2) + 1);
nnstart
toc