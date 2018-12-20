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


mua1 = 0.1414;
mus1 = 8.9006;

mua2 = .2188;
mus2 = 7.6799;

Db1 = 4.80e-9:.01e-9:5.00e-9;
Ratio = .30:.01:1;
ell = 0.95:.002:1.05;
Beta = .5;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 10;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep;
input = single(zeros(siz,size(tau,2)*2*4));
target = single(zeros(siz,3));

g2_30a = [];
inttime = 130;

load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    tic
    for ratio = Ratio1
        for l = ells
            db2 = db1*10^ratio;
            
            g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.00,w,l,mua2,mus2,db2,gl);
            normg1_10 = g1_10./g1_10(1);
            [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            sigma10 = getDCSNoise(400e3,T,inttime,beta,gamma,tau);
            
            sep15 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2,gl);
            normsep15 = sep15/sep15(1);
            [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(300e3,T,inttime,beta,gamma,tau); %50 hz.
            
            sep20 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,2.0,w,l,mua2,mus2,db2,gl);
            normsep20 = sep20/sep20(1);
            [b, index20] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma20 = 1/tau(index15);
            nsep20 = getDCSNoise(20e3,T,inttime,beta,gamma20,tau); %50 hz.
            
            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,2.5,w,l,mua2,mus2,db2,gl);
            normg1_25 = g1_25./g1_25(1);
            [b, index25] = min(abs(normg1_25-1/e));
            gamma = 1/tau(index25);
            sigma25 = getDCSNoise(20e3,T,inttime,beta,gamma,tau);
            
            g1_30 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,3.0,w,l,mua2,mus2,db2,gl);
            normg1_30 = g1_30./g1_30(1);
            [b, index30] = min(abs(normg1_30-1/e));
            gamma = 1/tau(index30);
            sigma30 = getDCSNoise(5e3,T,inttime,beta,gamma,tau);
            
            for rep = 1:Rep
                j = j+1;
                noise10_1 = sigma10.*randn(length(tau),1)';
                noise10_2 = sigma10.*randn(length(tau),1)';
                g2_10nn=  1 + beta.*normg1_10.^2;
                g2_10 = noise10_1 + g2_10nn;
                %                 g2_10fit = strokefilter(g2_10,10);
                
                noise15 = nsep15.*randn(length(tau),1)';
                g2_15 = beta.*normsep15.*normsep15 + noise15  + 1;
                
                noise25 = nsep20.*randn(length(tau),1)';
                g2_25 = beta.*normg1_25.^2 + noise25  + 1;
                for ds = 1:5
                    noise30 = sigma30.*randn(length(tau),1)';
                    g2_30 = beta.*normg1_30.^2;
                    g2_30a(ds,:) = noise30 + 1 + beta.*normg1_30.^2;
                end
                g2_30mean = mean(g2_30a, 1);
                
                
                %                 for ds = 1:1
                %                     noise25 = sigma25.*randn(length(tau),1)';
                %                     g2_25nn = beta.*normg1_25.^2;
                %                     g2_25a(ds,:) = noise25 + g2_25nn + 1;
                %                 end
                
                input(j,:) = single([g2_30a(:)' g2_25 g2_15 g2_10]);
                target(j,:) = single([db1*1e8 db2*1e9 l]);
            end
        end
    end
    toc
end

% for bet = Beta
%     indices = [1:siz] + siz*i;
%     inputbeta(indices, :) = (input - 1).*bet/0.5 + 1;
%     targetbeta(indices,:) = target;
%     i = i + 1;
% end
inputtarget = [input target];
g2 = zeros(1,size(tau,2));
for detector = 1:ds
    indices = detector:ds:size(tau,2)*ds;
    g2 = g2 + denoisenet25_20khz_rep30(inputtarget(:,indices));
end
g2_25avg = g2./ds;
inputmean = single([g2_25avg inputtarget(:, ds*size(tau,2)+1:size(input,2))]);
inputshuffle = fliplr(inputtarget(:, 1:size(inputtarget,2)-3));
targetshuffledb1 = inputtarget(:, size(inputshuffle,2) +1);
targetshuffledb2 = inputtarget(:, size(inputshuffle,2) +2);
%targetshuffleell = inputtarget(:, size(inputshuffle,2) +3);
%targetshuffleall = inputtargetshuffle(:, 121:123);
%nnstart
clearvars -except inputtarget inputmean targetshuffledb2 inputshuffle