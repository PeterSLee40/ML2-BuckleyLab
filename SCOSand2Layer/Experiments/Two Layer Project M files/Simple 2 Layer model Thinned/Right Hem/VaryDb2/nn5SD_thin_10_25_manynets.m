
addpath('..\..\..\..\..\functions');
addpath('..\..\..\..\..\multilayer');
addpath('..\..\..\..\..\neuralNet\Plotting');

%part 0: Initialization of variables

constants
load gauss_lag_5000.mat

%load the MC data and save it into trial
Dbfit_M_thinned_10_25_multiplenets

taurange = 1:70;
db1prediction = 8.8e-9;
db2prediction = 10.027e-08;
Db1s = [.80*db1prediction: .01*db1prediction: 1.0*db1prediction];
tau = DelayTime(taurange);
Ratio = 1.5:.1:12;
ell = .8: .01 : 1.2;
%Layer 1(Skull/Scalp): mu_a : 0.19 cm-1 mu_sp: 8.58 cm-1
mua1 = 0.19; mus1 = 8.58;
%Layer 2(Brain): mu_a:0.2 cm-1  mu_sp:  9.9 cm-1
mua2= 0.2; mus2= 9.9;
n = 1.37;
lambda = 852;%wavelength in mm

n0=1.37;%index of refraction for tissue
Reff=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;

Rhos = [1.0, 1.5, 2.0, 2.5];
intensities = [30 ,30, 30, 30].*1e3;

Rep = 1;    Betas = 1;
T = T(taurange);
numDetectors = size(Rhos,2);
g1s = zeros(numDetectors, size(tau,2)); g2s = g1s;  g2s_noise = g1s;
sigmas = zeros(numDetectors, size(tau,2));
numExamples = size(Db1s,2)*size(Ratio,2)*size(ell,2)*Rep*Betas;
input = zeros(numExamples,size(tau,2)*numDetectors);
target = zeros(numExamples,3);
inttime = 10;
meanBeta = .5;
j = 0;

%Part 1
%this section generates the data by iterating through every possible
%combination of variables
repnumber = 0;
for db1 = Db1s
    repnumber = repnumber+1;
    disp(repnumber)
    tic
    for ratio = Ratio
        for l = ell
            db2 = db1*ratio;
            %curmua1 = mua1.*(randn*.01+1); curmus1 = mus1.*(randn*.01+1);
            %curmua2 = mua2.*(randn*.02+1);  curmus2 = mus2.*(randn*.02+1);
            [g1s, gamma] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,Rhos',w,l,mua2,mus2,db2,gl);
            g1s = squeeze(g1s)';
            for beta = 1:Betas,    j = j + 1;
                %betaRand = meanBeta.*(randn(1).*meanbetastdfit.*2+1);
                betaRand = meanBeta;
                sigmas = getDCSNoise(intensities,T,inttime,betaRand,gamma,tau);
                noises = sigmas.*randn(numDetectors, size(tau,2));
                %betasRand = repmat(betaRand',1,size(tau,2));
                g2s = betaRand'.*g1s.^2 + 1;
                g2s_noise = g2s + noises.*1;
                input(j,:) = (g2s_noise(:)'); %inputnn(j,:) = (g2s(:)');
                target(j,:) = ([db1*1e8 db2*1e8 l]);
            end
        end
    end
    toc
end

%Part 2: Creating a neural network

%shuffles the data randomly
inputtarget = ([input target]);
inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = (inputtarget(:, 1:size(inputtarget,2)-3));
targetshuffle = inputtarget(:, size(input,2) + 2:size(input,2) + 3);
targetshuffledb1 = inputtarget(:, size(input,2) + 1);
targetshuffledb2 = (inputtarget(:, size(input,2) + 2));
targetshuffleell = inputtarget(:, size(input,2) + 3);

Nets = {};
perf = [];
netArch = {3, 5, 10, 10, [10, 5]};
[trainInd,valInd,testInd] = dividerand(size(inputshuffle, 1));

%this section creates and trains a neural network with matlabs NN toolbox
for retrainingIteration = 1:size(netArch,2)
    architecture = netArch{retrainingIteration};
    net = fitnet(architecture, 'trainscg');
    %net.divideFcn = 'divideind';%net.divideParam.trainInd = trainInd;
    %net.divideParam.valInd = valInd;%net.divideParam.testInd = testInd;
    net.trainParam.max_fail = 1;
    net.trainParam.epochs=1000;
    net.performFcn= 'mse';
    customweights = 100./(targetshuffledb2');
    [net1, tr] = train(net, inputshuffle', targetshuffledb2'./targetshuffledb1',{}, {}, customweights, 'useGPU', 'yes');
    %[net1, tr] = train(net, inputshuffle', targetshuffledb1', 'useGPU', 'yes');
    testTarget = targetshuffledb2(tr.testInd);
    testFit = net1(inputshuffle(tr.testInd,:)');
    performance = mean(abs(testTarget - testFit')./testTarget)*100;
    %archString = sprintf('%.0f,' , architecture);
    %disp(['The performance with hidden layer(s) of [' , archString, '] is an mpe of ', num2str(performance)]);
    Nets{retrainingIteration} = net1;
    perf(retrainingIteration) = performance;
end


testset = inputshuffle(testInd,:);
testlabel = targetshuffle(testInd,:);
testratio = targetshuffle(testInd,1);
testthiccness = targetshuffle(testInd,2)*1;
%feeds in a linearized version of the g2 curves into a neural network.
db2estimate = net1(testset')';
testError = 100*(testTarget-db2estimate)./testTarget;
%Creates a plot
%nnfitperformanceplotterfunc(testthiccness, testTarget, testError)
for k = 1:size(Nets,2)
   neuralnettrail(k,:) = Nets{k}(trial')
end