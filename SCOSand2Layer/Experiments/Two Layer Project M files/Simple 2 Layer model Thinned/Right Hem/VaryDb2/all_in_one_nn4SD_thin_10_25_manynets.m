
addpath('..\..\..\..\..\functions');
addpath('..\..\..\..\..\multilayer');
addpath('..\..\..\..\..\neuralNet\Plotting');
constants
load gauss_lag_5000.mat
%load the MC data and save it into trial


%PARAMETERS SPECIFIC TO THIS EXPERIMENT
plotfits=1;%If you want to display how well your fit compares to your raw g2 data
plotfigs=1;
%Layer 1(Skull/Scalp): mu_a : 0.19 cm-1 mu_sp: 8.58 cm-1
mua1 = 0.19; mus1 = 8.58;
%Layer 2(Brain): mu_a:0.2 cm-1  mu_sp:  9.9 cm-1
mua2= 0.2; mus2= 9.9;
%n=1.37
mua = mua1;
musp = mus1;
% Convert to values in mm-1
mua = mua/10;
musp = musp/10;
%Initial guess for our g2 fit, [Db beta]
guess = [1e-6 0.5];
%Upper and lower bounds for fit [Db beta]
lb=[1e-10 0.5];     ub=[1e-3 0.5];
%Only fit g2 values above cutoff:
cutoff=1.05;  %default = 1.05
datalength=70;
%How many points to average in each curve for smoothing
avgnum=10;
cutoff_I=30;%kHz
cutoffCOV=20;%require COV to be less than cutoff
n0=1.37;%index of refraction for tissue
lambda=852*1e-6;%wavelength in mm
k0=2*pi*n0/lambda; %this is the k0 for flow!
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;
SD_dist = [10, 15, 20, 25];
beta = .5;
taurange = 1:80;
l = .9;
db2real = [6, 9.5, 11.7, 4.2];

j = 0;
filename = 'mcx_g1_TwoLayerModelSimp_RightHem_1det_DB2';
differentDbs = ["_1_", "_2_", "_3_", "_4_"]
for differentDb = differentDbs
    j = j + 1;
    for i = 1:size(SD_dist,2)
        rho = SD_dist(i);
        data = load([filename char(differentDb) num2str(rho) 'mmSDS.mat']);
        g1 = data.gTau(taurange,:);
        g2 = beta*(g1).^2 + 1;
        g2s(i,:) = g2;
        tau = data.tauVals(taurange,:)';
        Dbbeta(i, :) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau,g2,rho,mua,musp,1,k0,R),guess,lb,ub);
        db1s(j, i) = Dbbeta(i, 1);
        asd = dcs_g2fit_GT([db1s(j, i) .5],tau,rho,mua,musp,k0,R,1);
        df = getG1(n0,R,mua1,mus1,db1s(j, i),tau,852e0,rho,w,l,mua2,mus2,db1s(j, i), gl);
    end
    g2slinearized = g2s(:);
end

%part 0: Initialization of variables

constants
load gauss_lag_5000.mat

db1prediction = mean(db1s(:,1));

Db1s = [.80*db1prediction: .01*db1prediction: 1.2*db1prediction];
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
Rhos = SD_dist;
intensities = [50 ,50, 50, 50].*1e3;


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