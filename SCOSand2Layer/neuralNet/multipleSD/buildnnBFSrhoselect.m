%this script creates the optimal Source Detector seperations based off
%of information gain starting from 1 detector until 8, at each iteration
%it picks the Source Detector Seperation that yields the most information
%
clc
tic
addpath('C:\Users\PeterLee\Documents\GitHub\SCOSand2Layer\functions');
addpath('C:\Users\PeterLee\Documents\GitHub\SCOSand2Layer\multilayer');

constants

%addpath('/Volumes/PETER1216/SCOSand2Layer/functions');
%change this to add noise
noise = true;

%ell = 1.0;
tau = DelayTime(1:1:80);
T = diff(DelayTime(1:1:81));
%tau = 2e-7:2e-7:2e-4;
%T = 2e-7.*ones(1,size(tau,2));
repnumber = 0;
Rho = .5:.1:3.0;
%rho = [.5, 1.0, 1.25, 1.50, 1.75, 2.0, 2.25, 2.5];

Db1 = 7.50e-9:.1e-9:8.00e-9;
%Ratio = 3:.1:10;
Ratio = 2:.1:10;
ell = 0.95:.01:1.05;
Beta = .46:.01:.52;

Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));
j = 0;
Rep = 1;
g2_25a = [];
inttime = 10;
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
selectedRho = zeros(8, 2);
performanceByAddingRho = selectedRho;
for curNumDetectors = 1:numDetectors
    curNumDetectors
    rhoCounter = 0;
    for rho = Rho; rhoCounter = rhoCounter + 1
        j = 0;
        for db1 = Db1s
            %repnumber = repnumber+1
            for ratio = Ratio1
                for l = ells, db2 = db1*ratio;
                    for i = 1:curNumDetectors
                        if curNumDetectors ~= i
                            currRho = selectedRho(i);
                        else
                            currRho = rho;
                            currInt = getIntensity(currRho,20);
                            [g1s(i,:), gamma] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,currRho,w,l,mua2,mus2,db2,gl);
                            sigmas(i,:) = getDCSNoise(currInt,T,inttime,beta,gamma,tau);
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
            end
        end
        inputtarget = ([input target]);
        inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
        inputshuffle = inputtarget(:, 1:size(inputtarget,2)-3);
        targetshuffledb2 = inputtarget(:, size(input,2) + 2);
        %semilogx(tau,input(1,8:8:640)');
        net = feedforwardnet(1, 'trainscg');
        net2 = train(net, inputshuffle', targetshuffledb2');
        perf = mse(net2,inputshuffle',targetshuffledb2');
        performanceByAddingRho(rhoCounter, :) = [rho, perf];
    end
    [maxRho indexOfMaxRho] = max(performanceByAddingRho);
    selectedRho(rhoCounter) = [selectedRho, performanceByAddingRho(indexOfMaxRho(2), 1)];
end