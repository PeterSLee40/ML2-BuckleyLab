clc
tic
addpath('C:\Users\PeterLee\Documents\SCOSand2Layer\functions');
constants

%addpath('/Volumes/PETER1216/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
%tau = DelayTime(1:1:80);
%T = diff(DelayTime(1:1:81));
tau = 5e-6:5e-6:3e-4;
%tau = 5e-6:1e-6:1e-4;
T = 1e-6.*ones(1,size(tau,2));
% g= 0;
repnumber = 5;

Db1 = 8.0e-9:.01e-9:8.00e-9;
Ratio = .3:.01:1;
ell = .85:.01:1.15;
Beta = [.45:.01:.52];

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 3;


g2_25a = [];
inttime = 3;

r = [1, 1.3, 1.6, 1.9, 2.2, 2.5, 2.7, 3.0];
int = [500,500,250,90,40,18,12,5].*1e3;
Sep = size(r,2);

g1a = zeros(size(r,2), size(tau,2));
sigma = zeros(size(r,2), size(tau,2));
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Beta,2);
input = single(zeros(siz,size(tau,2)*size(r,2)));
target = single(zeros(siz,3));
load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    tic
    for ratio = Ratio1
        for l = ells
            db2 = db1*10^ratio;
            for sep = 1:Sep
                [g1 gam] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,r(sep),w,l,mua2,mus2,db2,gl);
                g1a(sep,:) = g1;
                sigma(sep,:) = getDCSNoise(int(sep),T,inttime,beta,gam,tau);
            end
            for rep = 1:Rep
                for beta = Beta
                j = j+1;
                noise = sigma.*randn(size(sigma,1),size(sigma,2));
                noisyg2 = 1 + beta.*g1a.^2 + noise;
                noisyg2 = noisyg2.';
                input(j,:) = single(noisyg2(:));
                target(j,:) = single([db1*1e8 db2*1e9 l]);
                end
            end
        end
    end
    toc
end
inputtarget = single([input target]);
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
% g2 = zeros(1,size(tau,2));
% for detector = 1:ds
%     indices = detector:ds:size(tau,2)*ds;
%     g2 = g2 + denoisenet25_20khz_rep30(inputtarget(:,indices));
% end
% g2_25avg = g2./ds;
%inputmean = single([g2_25avg inputtarget(:, ds*size(tau,2)+1:size(input,2))]);
inputshuffle = inputtarget(:, 1:size(inputtarget,2)-3);
targetshuffledb1 = inputtarget(:, size(input,2) + 1);
targetshuffledb2 = inputtarget(:, size(input,2) + 2);
targetshufflel = inputtarget(:, size(input,2) + 3);
nnstart


clearvars -except targetshufflel inputtarget inputmean targetshuffledb1 targetshuffledb2 inputshuffle
csvwrite('targetdb2tsg8',targetshuffledb2)
csvwrite('inputdb2tsg8',inputshuffle)