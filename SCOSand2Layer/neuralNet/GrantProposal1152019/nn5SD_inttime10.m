
addpath('..\..\functions');
addpath('..\..\multilayer');

taurange = 5:105;
constants
Db1s = [1e-8]
constants
tau = DelayTime(taurange);
Ratio = 2:.1:10;
ell = 0.90:.01:1.10;

Rep = 1;
Betas = 1;
taustmp = tau;
T = T(taurange);
numDetectors = 5;
g1s = zeros(numDetectors, size(taustmp,2));
g2s = g1s;  g2s_noise = g1s;
sigmas = zeros(numDetectors, size(tau,2));
siz = size(Db1s,2)*size(Ratio,2)*size(ell,2)*Rep*Betas;
input = zeros(siz,size(tau,2)*numDetectors);
target = zeros(siz,3);
inputshuffle = input;   %inputnn =  input;
targetshuffle = target;
load gauss_lag_5000.mat
inttime = 10;
%top layer
mua1=0.125; mus1=8;
%bottom layer
mua2= 0.125; mus2= 8;
meanBeta = .5;
j = 0;

Rhos = [1.0, 1.5, 2.0, 2.2, 2.7];

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
                %curmua1 = mua1.*(randn*.01+1); curmus1 = mus1.*(randn*.01+1);
                %curmua2 = mua2.*(randn*.02+1);  curmus2 = mus2.*(randn*.02+1);
                curmua1 = mua1; curmus1 = mus1;
                curmua2 = mua2; curmus2 = mus2;
                %tau = DelayTime(1:120);
                [g1s, gamma] = getG1(n,Reff,curmua1,curmus1,db1,tau,lambda,Rhos',w,l,curmua2,curmus2,db2,gl);
                g1s = squeeze(g1s)';
                for beta = 1:Betas,    j = j + 1;
                    %betaRand = meanBeta.*(randn(1).*meanbetastdfit.*2+1);
                    betaRand = meanBeta;
                    intensities = [300 ,200, 50, 40, 20].*1e3;
                    sigmas = getDCSNoise(intensities,T,inttime,betaRand,gamma,tau);
                    noises = sigmas.*randn(numDetectors, size(tau,2));
                    %betasRand = repmat(betaRand',1,size(tau,2));
                    g2s = betaRand'.*g1s.^2 + 1;
                    g2s_noise = g2s;
                    input(j,:) = (g2s_noise(:)');
                    %inputnn(j,:) = (g2s(:)');
                    target(j,:) = ([db1*1e8 db2*1e9 l]);
                end
            end
        end
        endcf
    toc
end

inputtarget = ([input target]);
inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = (inputtarget(:, 1:size(inputtarget,2)-3));
targetshuffle = inputtarget(:, size(input,2) + 2:size(input,2) + 3);
targetshuffledb1 = inputtarget(:, size(input,2) + 1);
targetshuffledb2 = (inputtarget(:, size(input,2) + 2));
targetshuffleell = inputtarget(:, size(input,2) + 3);
Nets = [];
netArch = {[15,5]};
[trainInd,valInd,testInd] = dividerand(size(inputshuffle, 1));

for retrainingIteration = 1:size(netArch,2)
    architecture = netArch{retrainingIteration};
    net = fitnet(architecture, 'trainscg');
    net.divideFcn = 'divideind';
    net.divideParam.trainInd = trainInd;
    net.divideParam.valInd = valInd;
    net.divideParam.testInd = testInd;
    net.trainParam.max_fail = 1000;
    net.trainParam.epochs=10000;
    net.performFcn= 'mae';
    customweights = 100./(targetshuffledb2');
    [net1, tr] = train(net, inputshuffle', targetshuffledb2',{}, {}, customweights, 'useGPU', 'no');
    
    testTarget = targetshuffledb2(tr.testInd);
    testFit = net1(inputshuffle(tr.testInd,:)');
    
    performance = mean(abs(testTarget - testFit')./testTarget)*100;
    archString = sprintf('%.0f,' , architecture);
    archString = archString(1:end - 1);
    disp(['The performance with hidden layer(s) of [' , archString, '] is an mpe of ', num2str(performance)]);
    Nets = [Nets performance];
end
%contains your g2 curves, ordered such that c1|c2|c3|C4|c5|c1|c2|c3|c4|c5..
%the next value in the testset array corresponds to the next curve until it
%reaches 5, then goes to the next tau and gets the g2 value for curve 1
testset = inputshuffle(testInd,:);
%contains the label of the data, the first index is db2*1e9 cm2/s,
%second index is thickness
testlabel = targetshuffle(testInd,:);

testratio = targetshuffle(testInd,1)*10;
testthiccness = targetshuffle(testInd,2)*1;