clc
tic
addpath('C:\Users\PeterLee\Documents\SCOSand2Layer\functions');
constants

%addpath('/Volumes/PETER1216/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = DelayTime(1:1:80);
T = diff(DelayTime(1:1:81));
tau = 5e-6:5e-6:3e-4;
T = 5e-6.*ones(1,size(tau,2));
g= 0;
repnumber = 0;

Db1 = 8.00e-9:.01e-9:8.00e-9;
Ratio = 30:1:100;
ell = 1.0;
Beta = .5;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 100;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep;
input = single(zeros(siz,size(tau,2)*2));
inputnn =  single(zeros(siz,size(tau,2)*2));
target = single(zeros(siz,3));

g2_25a = [];
inttime = 3;

load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    tic
    for ratio = Ratio1
        for l = ells
            db2 = db1*ratio;
            
            g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(1),w,l,mua2,mus2,db2,gl);
            normg1_10 = g1_10./g1_10(1);
            [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            sigma10 = getDCSNoise(500e3,T,inttime,beta,gamma,tau);

            g1_25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(2),w,l,mua2,mus2,db2,gl);
            normg1_25 = g1_25./g1_25(1);
            [b, index25] = min(abs(normg1_25-1/e));
            gamma = 1/tau(index25);
            sigma25 = getDCSNoise(300e3,T,inttime,beta,gamma,tau);
            for rep = 1:Rep
                j = j+1;
                noise10_1 = sigma10.*randn(length(tau),1)';
                noise10_2 = sigma10.*randn(length(tau),1)';
                g2_10nn=  1 + beta.*normg1_10.^2;
                g2_10 = noise10_1 + g2_10nn;
                %                 g2_10fit = strokefilter(g2_10,10);
                
                for ds = 1:1
                    noise25 = sigma25.*randn(length(tau),1)';
                    g2_25nn = beta.*normg1_25.^2 + 1;
                    g2_25a(ds,:) = noise25 + 1 + beta.*normg1_25.^2;
                end
                g2_25mean = mean(g2_25a, 1);
                
                input(j,:) = single([g2_25a(:)' g2_10]);
                inputnn(j,:) = single([g2_25nn g2_10nn]);
                target(j,:) = single([db1*1e8 db2*1e9 l]);
            end
        end
    end
    toc
end
inputtarget = single([input target]);
inputinputnn = single([input inputnn]);
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
inputinputnn = single(inputinputnn(randperm(size(inputinputnn,1)),:));
% g2 = zeros(1,size(tau,2));
% for detector = 1:ds
%     indices = detector:ds:size(tau,2)*ds;
%     g2 = g2 + denoisenet25_20khz_rep30(inputtarget(:,indices));
% end
% g2_25avg = g2./ds;
%inputmean = single([g2_25avg inputtarget(:, ds*size(tau,2)+1:size(input,2))]);
inputshuffle = inputtarget(:, 1:size(inputtarget,2)-3);

inputnnshuffle = inputinputnn(:, 1:size(tau,2)*2);
targetnnshuffle = inputinputnn(:, 2*size(tau,2)+1:4*size(tau,2));
targetshuffledb1 = inputtarget(:, size(input,2) + 1);
targetshuffledb2 = inputtarget(:, size(input,2) + 2);
%dinputshuffle = denoisenet1_25_500_300(inputshuffle);

inputshuffle1 = inputinputnn(:, 1:size(tau,2)*1);
inputshuffle2 = inputinputnn(:, size(tau,2)*1+1:size(tau,2)*2);


%targetshuffleell = inputtargetshuffle(:, 123);
%targetshuffleall = inputtargetshuffle(:, 121:123);
%nnstart
%clearvars -except inputtarget inputmean targetshuffledb2 inputshuffle