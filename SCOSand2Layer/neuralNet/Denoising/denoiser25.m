clc
tic
addpath('H:\SCOSand2Layer\functions');
constants

%addpath('/Volumes/PETER1216/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
g= 0;
repnumber = 0;

Db1 = 4.70e-9:.01e-9:5.00e-9;
Ratio = .30:.01:1;
ell = 0.95:.002:1.05;
Beta = .5;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 30;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep;
input = single(zeros(siz,size(tau,2)));
target = single(zeros(siz,size(tau,2)));

g2_25a = [];
inttime = 3;

load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    tic
    for ratio = Ratio1
        for l = ells
            db2 = db1*10^ratio;
            
            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
            normg1_25 = g1_25./g1_25(1);
            [b, index25] = min(abs(normg1_25-1/e));
            gamma = 1/tau(index25);
            sigma25 = getDCSNoise(20e3,T,inttime,beta,gamma,tau);
            g2_25nn = 1 + beta.*normg1_25.^2;
            
            for rep = 1:Rep
                j = j + 1;
                noise25 = sigma25.*randn(length(tau),1)';
                input(j,:) = single(g2_25nn + noise25);
                target(j,:) = single(g2_25);
                
            end
        end
    end
    toc
end
inputbeta = single(zeros(siz*size(Beta,2),100));
targetbeta = single(zeros(siz*size(Beta,2),100));
i = 0;
for bet = Beta
    indices = [1:siz] + siz*i;
    inputbeta(indices, :) = (input - 1).*bet/0.5 + 1;
    targetbeta(indices,:) = target;
    i = i + 1;
end

inputtarget = single([inputbeta targetbeta]);
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = inputtarget(:, 1:100);
targetshuffle = inputtarget(:, 101:200);
clearvars -except inputshuffle targetshuffle
nnstart