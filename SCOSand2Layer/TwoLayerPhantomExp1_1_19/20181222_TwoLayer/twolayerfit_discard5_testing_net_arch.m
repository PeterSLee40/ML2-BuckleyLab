%discard5
%first do a semi-infinite approx of the 1st layer with a 10mm seperation
%next, we're going to create data where the 1st layer is 100-120% the
%approx
%then, we try to fit a neural net to the data.
%finally, we're going to fit the data to the neural net
load('discard5.mat')
addpath('..\..\functions');
addpath('..\..\multilayer');

taurange = 5:75;

constants
good_start = 5;
%Data directory
fdir = './';
id = 'TwoLayer_discard5_';
Rhos = [1.0, 1.5, 2.0];


% SD distance
SD_dist = 10;%mm
used_ch = 2;%Only looking at DCS data from detector 2
%CHANGE THIS TO ACTUAL VALUES
mua = 0.1287;%cm-1
musp = 6.7790;%cm-1=


%PARAMETERS SPECIFIC TO THIS EXPERIMENT
%Define integration time (sec)
t=1;
% Convert to values in mm-1
mua = mua/10;
musp = musp/10;
%Initial guess for our g2 fit, [Db beta]
guess = [1e-7 0.5];
%Upper and lower bounds for fit [Db beta]
lb=[1e-11 0.3];     ub=[1e-3 0.55];
%Only fit g2 values above cutoff:
cutoff=1.05;  %default = 1.05
datalength=70;
%How many points to average in each curve for smoothing
avgnum=10;
cutoff_I=30;%kHz
cutoffCOV=20;%require COV to be less than cutoff

n0=1.38;%index of refraction for tissue
lambda=850*1e-6;%wavelength in mm
k0=2*pi*n0/lambda; %this is the k0 for flow!
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;
%TwoLayer_discard5_1_flow_0
meanbeta=0.4;
temp = 50:-2:30;
%for temp_idx = 1:11;
taustmp = DelayTime(taurange);
tau = DelayTime(taurange);

%how many times to sample from Beta
Betas = 1;
%how many times to sample mua and musp (this will slow down your process)
Rep = 1;
meanDbfit = zeros(1,3); meanBeta = meanDbfit; meanbetastdfit = meanBeta;

for i = 1:3
    [meanDbfit(i), meanBeta(i), meanbetastdfit(i)] = Dbfit_2layer_discard5_estimate(Rhos(i)*10, false);
end
estimatedDb1 = meanDbfit(1);

Db1s = estimatedDb1*.75:estimatedDb1*.01:estimatedDb1*.90;
constants
tau = DelayTime(taurange);
Ratio = 2:.1:10;
ell = 0.90:.01:1.10;

T = T(taurange);
numDetectors = 3;
g1s = zeros(numDetectors, size(taustmp,2));
g2s = g1s;  g2s_noise = g1s;
sigmas = zeros(numDetectors, size(tau,2));
siz = size(Db1s,2)*size(Ratio,2)*size(ell,2)*Rep*Betas;
input = (zeros(siz,size(tau,2)*numDetectors));
target = (zeros(siz,3));
inputshuffle = input;   %inputnn =  input;
targetshuffle = target;
load gauss_lag_5000.mat
inttime = 10;
%top layer
mua1=0.1287; mus1=6.7790;
%bottom layer
mua2= 0.1391; mus2= 6.3814;
j = 0;


repnumber = 0;
for db1 = Db1s*1e-2
    repnumber = repnumber+1;
    disp(repnumber)
    tic
    for ratio = Ratio
        for l = ell
            for rep = 1:Rep
                db2 = db1*ratio;
                %db2 = db1*10^ratio;
                curmua1 = mua1.*(randn*.01+1); curmus1 = mus1.*(randn*.01+1);
                curmua2 = mua2.*(randn*.02+1);  curmus2 = mus2.*(randn*.02+1);
                %curmua1 = mua1; curmus1 = mus1;
                %curmua2 = mua2; curmus2 = mus2;
                %tau = DelayTime(1:120);
                [g1s, gamma] = getG1(n0,Reff,curmua1,curmus1,db1,tau,lambda,Rhos',w,l,curmua2,curmus2,db2,gl);
                g1s = squeeze(g1s)';
                for beta = 1:Betas,    j = j + 1;
                    %betaRand = meanBeta.*(randn(1).*meanbetastdfit.*2+1);
                    betaRand = meanBeta;
                    intensities = [400 ,80, 12].*1e3;
                    sigmas = getDCSNoise(intensities,T,inttime,betaRand,gamma,tau);
                    noises = sigmas.*randn(numDetectors, size(tau,2));
                    %betasRand = repmat(betaRand',1,size(tau,2));
                    g2s = betaRand'.*g1s.^2 + 1;
                    g2s_noise = noises + g2s;
                    input(j,:) = (g2s_noise(:)');
                    %inputnn(j,:) = (g2s(:)');
                    target(j,:) = ([db1*1e8 db2*1e9 l]);
                end
            end
        end
    end
    toc
end

inputtarget = ([input target]);
inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = (inputtarget(:, 1:size(inputtarget,2)-3));
targetshuffledb1 = inputtarget(:, size(input,2) + 1);
targetshuffledb2 = (inputtarget(:, size(input,2) + 2));
targetshuffleell = inputtarget(:, size(input,2) + 3);
Nets = [];
netArch = {[64, 16, 4], [100, 10], [36,6],[10,5], [5,3], 213, 100, 5, 3, 1};
[trainInd,valInd,testInd] = dividerand(size(inputshuffle, 1));

for retrainingIteration = 1:size(netArch,2)
    net.performFcn= 'mae';
    net = fitnet(netArch{retrainingIteration}, 'trainscg');
    net.divideFcn = 'divideind';
    net.divideParam.trainInd = trainInd;
    net.divideParam.valInd = valInd;
    net.divideParam.testInd = testInd;
    net.trainParam.max_fail = 5000;
    net.trainParam.epochs=10000;
    [net1, tr] = train(net, inputshuffle', targetshuffledb2','reduction',1);
    
    testTarget = targetshuffledb2(tr.testInd);
    testFit = net1(inputshuffle(tr.testInd,:)');
    
    performance = mse(testTarget,testFit');
    archString = sprintf('%.0f,' , netArch{retrainingIteration});
    archString = archString(1:end - 1);
    disp(['The performance with hidden layer(s) of [' , archString, '] is an mse of ', num2str(performance)]);
    Nets = [Nets performance];
end