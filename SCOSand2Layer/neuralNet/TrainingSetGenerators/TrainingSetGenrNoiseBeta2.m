clc
tic
addpath('H:\SCOSand2Layer\functions');
constants

%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = DelayTime(1:2:80);
T = diff(DelayTime(1:2:81));
g= 0
repnumber = 0;

Db1 = 4.5e-9:.01e-9:5e-9;
Ratio = .30:.01:1;
ell = 0.9:.01:1.1;
Beta = 0.45:.001:0.50;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 10;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*size(Rep,2);
input = zeros(siz,80);
target = zeros(siz,3);

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
            sigma10 = getDCSNoise(300e3,T,3,beta,gamma,tau);
            noise10 = sigma10.*randn(length(tau),1)';
            g2_10 = noise10 + 1 + beta.*normg1_10.^2;
            
            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
            normg1_25 = g1_25./g1_25(1);
            if noise == true
                [b, index25] = min(abs(normg1_25-1/e));
                gamma = 1/tau(index25);
                sigma25 = getDCSNoise(200e3,T,3,beta,gamma,tau); 
            end
            for rep = Rep
                j = j+1;
                if noise == true
                    for ds = 1:1
                        noise25 = sigma25.*randn(length(tau),1)';
                        g2_25(ds,:) = noise25 + 1 + beta.*normg1_25.^2;
                    end
                    g2_25mean = mean(g2_25, 1);
                else
                    g2_25mean = 1 + beta.*normg1_25.^2;
                end
                input(j,:) = [g2_25mean g2_10];
                target(j,:) = [db1*1e8 db2*1e9 l];
            end
        end
    end
end
inputbeta = zeros(siz*size(Beta,2),80);
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
inputshuffle = inputtargetshuffle(:, 1:80);
targetshuffledb1 = inputtargetshuffle(:, 81);
targetshuffledb2 = inputtargetshuffle(:, 82);
targetshuffleell = inputtargetshuffle(:, 83);
targetshuffleall = inputtargetshuffle(:, 81:83);
nnstart