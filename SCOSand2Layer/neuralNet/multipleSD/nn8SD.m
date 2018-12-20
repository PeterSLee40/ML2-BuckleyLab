clc
tic
addpath('C:\Users\Peter LEe\Documents\SCOSand2Layer\functions');
constants

%MSE = 4.8;


%addpath('/Volumes/PETER1216/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = DelayTime(1:1:80);
T = diff(DelayTime(1:1:81));
%tau = 2e-7:2e-7:2e-4;
%T = 2e-7.*ones(1,size(tau,2));
g2s_noise= 0;
repnumber = 0;
<<<<<<< HEAD
rho = [.5, 1.0, 1.0, 1.50, 1.50, 1.50, 2.0, 2.0];
=======
>>>>>>> parent of ebcf133... added bfs for detector selection

Db1 = 7.00e-9:.1e-9:8.00e-9;
%Ratio = 3:.1:10;
Ratio = 2:.1:10;
ell = 0.95:.01:1.05;
Beta = .45:.01:.52;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 1;
rho = [1.5, 2.0];
g2_25a = [];
<<<<<<< HEAD
inttime = 10;
=======
inttime = 3;
>>>>>>> parent of ebcf133... added bfs for detector selection
numDetectors = 8;

g1s = zeros(numDetectors, size(tau,2));
g2s = g1s;
g2s_noise = g1s;
sigmas = zeros(numDetectors, size(tau,2));

siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Beta,2);
input = single(zeros(siz,size(tau,2)*numDetectors));
inputnn =  single(zeros(siz,size(tau,2)*numDetectors));
target = single(zeros(siz,3));
rho = [.5, 1.0, 1.25, 1.50, 1.75, 2.0, 2.25, 2.5];
load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    tic
    for ratio = Ratio1
        for l = ells
            db2 = db1*ratio;
            %db2 = db1*10^ratio;
            for i = 1:numDetectors
                currRho = rho(i);
                currInt = getIntensity(currRho,20);
                [g1s(i,:), gamma] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,currRho,w,l,mua2,mus2,db2,gl);
                sigmas(i,:) = getDCSNoise(currInt,T,inttime,beta,gamma,tau);
            end
            for rep = 1:Rep
                for beta = Beta,    j = j + 1;
                noises = sigmas.*randn(numDetectors, size(tau,2));
                g2s = beta.*g1s.^2 + 1;
                g2s_noise = noises + 1 + beta.*g1s.^2;
                
                input(j,:) = single(g2s_noise(:)');
                inputnn(j,:) = single(g2s(:)');
                target(j,:) = single([db1*1e8 db2*1e9 l]);
            end
            end
        end
    end
    toc
end
inputtarget = single([input target]);
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
<<<<<<< HEAD
inputshuffle = inputtarget(:, 1:size(inputtarget,2)-3);
targetshuffledb2 = inputtarget(:, size(input,2) + 2);
semilogx(tau,input(1,8:8:640)');

net = fitnet(10,'trainscg');
net = train(net, inputshuffle', targetshuffledb2');

%plotnnperf
=======
inputshuffle_single = inputtarget(:, 1:size(inputtarget,2)-3);
targetshuffledb2_single = inputtarget(:, size(input,2) + 2);
>>>>>>> parent of ebcf133... added bfs for detector selection



