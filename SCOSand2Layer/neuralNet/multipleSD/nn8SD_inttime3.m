
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
Db1 = 8.0e-9:.01e-9:10.0e-9;
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

g1s = zeros(numDetectors, size(tau,2));
g2s = g1s;
g2s_noise = g1s;
sigmas = zeros(numDetectors, size(tau,2));

siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Beta,2);
input = (zeros(siz,size(tau,2)*numDetectors));
inputnn =  (zeros(siz,size(tau,2)*numDetectors));
target = (zeros(siz,3));
inputshuffle = input;
targetshuffle = target;
load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1;
    disp(repnumber)
    tic
    for ratio = Ratio1
        for l = ells
            db2 = db1*ratio;
            %db2 = db1*10^ratio;
            currRho = 0;
            for i = 1:numDetectors
                if currRho ~= rho(i)
                    currRho = rho(i);
                    currInt = getIntensity(currRho,20);
                    [g1s(i,:), gamma] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,currRho,w,l,mua2,mus2,db2,gl);
                    sigmas(i,:) = getDCSNoise(currInt,T,inttime,beta,gamma,tau);
                else
                    g1s(i,:) = g1s(i-1,:);
                    sigmas(i,:) = sigmas(i - 1,:);
                end
            end
            for rep = 1:Rep
                for beta = Beta,    j = j + 1;
                noises = sigmas.*randn(numDetectors, size(tau,2));
                g2s = beta.*g1s.^2 + 1;
                g2s_noise = noises + 1 + beta.*g1s.^2;
                
                input(j,:) = (g2s_noise(:)');
                inputnn(j,:) = (g2s(:)');
                target(j,:) = ([db1*1e8 db2*1e9 l]);
            end
            end
        end
    end
    toc
end
inputtarget = ([input target]);
inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = inputtarget(:, 1:size(inputtarget,2)-3);
targetshuffledb1 = inputtarget(:, size(input,2) + 1);
targetshuffledb2 = inputtarget(:, size(input,2) + 2);
semilogx(tau,input(1,8:8:8*size(tau,2))');
tic

%figures out db1, then feeds it into another neural net
db1net = fitnet(10,'trainscg');
db1net = train(db1net, inputshuffle', targetshuffledb1');
fitdb1 = db1net(inputshuffle');
db2net = fitnet(10,'trainscg');
db2net = train(db2net, [inputshuffle'; fitdb1], targetshuffledb2');
db2net_mse =  mse(db2net,targetshuffledb2',db2net([inputshuffle'; fitdb1]));
%mse = 16.2

regnet = fitnet(10,'trainscg');
regnet = train(regnet, inputshuffle', targetshuffledb2');
regnet_mse = mse(regnet, targetshuffledb2', regnet(inputshuffle'));
%mse = 16.3
