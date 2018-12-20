clc
tic
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\functions');
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\multilayer');
constants

%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
%change this to add noise
noise = true;

ell = 0.95:.002:1.05;
% tau = DelayTime(1:1:100);
% T = diff(DelayTime(1:1:101));
tau = 5e-6:5e-6:3e-4;
T = 5e-6.*ones(1,size(tau,2));
g= 0
repnumber = 0;
Db1 = 8e-9;
Ratio = 3:.1:10;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));

j = 0;
Rep = 30;
Beta = 0.5;
Intensity = 100e3;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Intensity,2)
input = single(zeros(siz,size(tau,2)));
target = single(zeros(siz,size(tau,2)));
beta = .5;

load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    for ratio = Ratio1
        for l = ells
            db2 = db1*ratio;
            g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.0,w,l,mua2,mus2,db2, gl);
            normg1_10 = g1_10./g1_10(1);
            [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            for rep = 1:Rep
            j = j + 1;
            sigma10 = getDCSNoise(Intensity,T,3,beta,gamma,tau);
            noise10 = sigma10.*randn(length(tau),1)';
            %noise10 = 0;
            g2_10nn =  1 + beta.*normg1_10.^2;
            g2_10 = noise10 + g2_10nn;
            
            input(j,:) = single([g2_10]);
            inputnn(j, :) = single([g2_10nn]);
            target(j,:) = single([g2_10nn]);
            end
        end
    end
end

%inputbeta = single(zeros(siz*size(Beta,2),100));
%targetbeta = single(zeros(siz*size(Beta,2),100));
% i = 0;
% for bet = Beta
%     indices = [1:siz] + siz*i;
%     inputbeta(indices, :) = (input - 1).*bet/0.5 + 1;
%     targetbeta(indices,:) = target;
%     i = i + 1;
% end
% 
inputtarget = single([input target]);
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = inputtarget(:, 1:size(tau,2));
targetshuffle = inputtarget(:, size(tau,2) + 1:size(tau,2)*2);
%inputflip = fliplr(inputshuffle);
nnstart
csvwrite('targetdenoiser1cm',targetshuffle)
csvwrite('inputdenoiser1cm',inputshuffle)