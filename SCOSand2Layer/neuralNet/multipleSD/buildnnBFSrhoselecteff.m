%this script creates the optimal Source Detector seperations based off
%of information gain starting from 1 detector until 8, at each iteration
%it picks the Source Detector Seperation that yields the most information
%pseudcode

% from 1, then iterating until 8, get the next best rho to add on
% for int size = 1, size <= 8, size++,
% for each rho in Rho
% create training set given selected rho and new rho
% train neural net
% get max performance
% select the rho with max performance
% add it to the list of selected rho,

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
%Rho = .5:.1:2.5;
%Rho = .5:0.5:2.5;
Rho = [.5, 1.0, 1.25, 1.50, 1.75, 2.0, 2.25, 2.5];

Db1 = 8.00e-9:.2e-9:10.00e-9;
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
%CHANGE THIS TO INCREASE OR DECREASE NOISE
inttime = 3;
numDetectors = 8;

g1s = zeros(numDetectors, size(tau,2)); g2s = g1s; g2s_noise = g1s;
sigmas = zeros(numDetectors, size(tau,2));

siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Beta,2);
input = double(zeros(siz,size(tau,2)*numDetectors)); maxinput = input;
previnput = input; tempinput = input;
inputnn =  double(zeros(siz,size(tau,2)*numDetectors)); maxinputnn = inputnn;
tempinputnn = inputnn;
previnputnn = inputnn; maxinputnn = inputnn;
target = double(zeros(siz,3)); maxtarget = target;
inputshuffle = input; targetshuffle = target;
maxperf = Inf;
load gauss_lag_5000.mat
selectedRho = zeros(8, 2);
performanceByAddingRho = selectedRho;
rhos = zeros(1,8);
for curNumDetectors = 1:numDetectors
    maxperf = Inf;
    curNumDetectors
    rhoCounter = 0;
    for rho = Rho; rhoCounter = rhoCounter + 1;
        j = 0;
        tempinput = zeros(siz,size(tau,2)*numDetectors);
        for db1 = Db1s
            for ratio = Ratio1
                for l = ells, db2 = db1*ratio;
                    g1s = zeros(8,size(tau,2));
                    g2s_noise = g1s; g2s = g1s; sigmas = g1s;
                    i = curNumDetectors;
                    currRho = rho;    currInt = getIntensity(currRho,20);
                    [g1s(i,:), gamma] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,currRho,w,l,mua2,mus2,db2,gl);
                    sigmas(i,:) = getDCSNoise(currInt,T,inttime,beta,gamma,tau);
                    for rep = 1:Rep
                        for beta = Beta,    j = j + 1;
                            noises = sigmas.*randn(numDetectors, size(tau,2));
                            g2s(i,:) = beta.*g1s(i,:).^2 + 1;
                            g2s_noise(i,:) = noises(i,:) + 1 + beta.*g1s(i,:).^2;
                            tempinput(j,:) = (g2s_noise(:)');
                            inputnn(j,:) = (g2s(:)');
                            target(j,:) = ([db1*1e8 db2*1e9 l]);
                        end
                    end
                end
            end
        end
        input = previnput + tempinput;
        inputnn = previnputnn + tempinputnn;
        inputtarget = ([input target]);
        inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
        inputshuffle = inputtarget(:, 1:size(inputtarget,2)-3);
        targetshuffledb2 = inputtarget(:, size(input,2) + 2);
        %semilogx(tau,input(1,8:8:640)');
        net = feedforwardnet(10, 'trainscg');
        [net2 tr] = train(net, inputshuffle', targetshuffledb2');
        testSetInput = inputshuffle(tr.testInd,:)';
        testSetTarget = targetshuffledb2(tr.testInd,:)';
        testSetPred = net2(testSetInput);
        perf = perform(net2,testSetTarget,testSetPred);
        if perf < maxperf
            maxrho = rho
            maxperf = perf
            maxinput = input;
            maxinputnn = inputnn;
        end
    end
    selectedRho(curNumDetectors, :) = [maxrho maxperf];
    previnput = maxinput;
    previnputnn = maxinputnn;
end
