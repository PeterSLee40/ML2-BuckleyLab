
tic
addpath('C:\Users\PeterLee\Documents\GitHub\SCOSand2Layer\functions');
addpath('C:\Users\PeterLee\Documents\GitHub\SCOSand2Layer\multilayer');
constants

%MSE = 13.4;

%addpath('/Volumes/PETER1216/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
%tau = 2e-7:2e-7:2e-4;
%T = 2e-7.*ones(1,size(tau,2));
repnumber = 0;
%the optimal rho after running buildnnBFRrhoselecteff.m with inttime of 10.

rho = [.5, 1.0, 1.0, 1.50, 1.50, 1.50, 1.50, 2.0];
%rho = [1.0, 1.5, 2.5, 2.5, 2.5, 2.5, 2.5 , 2.5];
%[.5, 1.25, 1.25, 1.25, 1.25, 1.5, 1.5, 1.75];
%if db1 = 8e-9:10e-9


%when we add larger range of db1:
%rho [0.50;1;1.5;1.5;2;2;2;2.5] 
Db1 = 8.0e-9:1e-9:10.00e-9;
%Ratio = 3:.1:10;
Ratio = 2:.1:10;
ell = 0.85:.01:1.05;
Beta = .46:.01:.52;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 1;
g2_25a = [];
inttime = 3;
numDetectors = 8;

%g1s = zeros(numDetectors, size(tau,2));
g2s = g1s;
g2s_noise = g1s;
%sigmas = zeros(numDetectors, size(tau,2));

siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Beta,2);
input = (zeros(siz,size(tau,2)*numDetectors));
inputnn =  (zeros(siz,size(tau,2)*numDetectors));
target = (zeros(siz,3));
inputshuffle = input;
targetshuffle = target;
load gauss_lag_5000.mat
input3d = zeros(size(Db1s,2),size(ratio,2)*size(ells,2)*size(Beta,2),size(tau,2));
target3d = zeros(size(Db1s,2),size(ratio,2)*size(ells,2)*size(Beta,2),1);
parfor db1 = Db1s
    db1index = find(Db1s == db1)
    repnumber = repnumber+1
    tic
    j = 0;
    for ratio = Ratio1
        ratioindex = find(Ratio1 == ratio)
        for l = ells
            ellindex = find(ells == l)
            db2 = db1*ratio;
            %db2 = db1*10^ratio;
            for i = 1:numDetectors
                g1s = zeros(8,size(tau,2));
                sigmas = g1s; 
                currRho = rho(i);
                currInt = getIntensity(currRho,20);
                [g1s(i,:), gamma(i)] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,currRho,w,l,mua2,mus2,db2,gl);
            end
            for rep = 1:Rep
                for beta = Beta
                    for u = 1:numDetectors
                        sigmas(u,:) = getDCSNoise(currInt,T,inttime,beta,gamma(u),tau);
                    end
                    betaindex = find(Beta==beta);
                    j = j + 1;
                    noises = sigmas.*randn(numDetectors, size(tau,2));
                    g2s = beta.*g1s.^2 + 1;
                    g2s_noise = noises + 1 + beta.*g1s.^2;
                    inputa(j,:) = (g2s_noise(:)');
                    %inputnn(j,:) = (g2s(:)');
                    targeta(j,:) = ([db1*1e8 db2*1e9 l]);
                end
            end
        end
    end
    input3d(db1index, :) = inputa
    target3d(db1index) = targeta
end
inputtarget = ([input target]);
inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = inputtarget(:, 1:size(inputtarget,2)-3);
targetshuffledb2 = inputtarget(:, size(input,2) + 2);
semilogx(tau,input(1,8:8:640)');

net1 = fitnet(5,'trainscg');
net1 = train(net1, inputshuffle', targetshuffledb2');
net2 = fitnet([10 3],'trainscg');
net2 = train(net2, inputshuffle', targetshuffledb2');
net2 = fitnet(20,'trainscg');
net3 = train(net3, inputshuffle', targetshuffledb2');


plotnnperf
%5,3 16.2



