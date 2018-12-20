addpath('C:\Users\PeterLee\Documents\GitHub\SCOSand2Layer\functions');
addpath('C:\Users\PeterLee\Documents\GitHub\SCOSand2Layer\multilayer');
constants

%addpath('/Volumes/PETER1216/SCOSand2Layer/functions');

%change this to alter the delaytime
tau = DelayTime(1:1:80);
T = diff(DelayTime(1:1:81));


%ALTER THIS TO CHANGE THE RANGE OF DB1
Db1 = 4.00e-9:.1e-9:6.00e-9;

%ALTER THIS TO CHANGE THE RANGE OF DB2
Ratio = 2.0:.1:10.0;

%ALTER THIS TO CHANGE THE RANGE OF BETA
Beta = .48:.002:.51;

%ALTER HOW MANY TIMES THE NET SEES THE SAME DATA
Rep = 1;

%initializes the datasets used
siz = size(Db1,2)*Rep*size(Beta,2)*size(Ratio,2);
input = single(zeros(siz,size(tau,2)));
inputnn =  single(zeros(siz,size(tau,2)));
target = single(zeros(siz,2));
Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));


%variables and constants
j = 0;
repnumber = 0;
g= 0;
rho = [1.5 2.0];
mua1 = 0.125;%cm-1
mus1 = 8;%cm-1
mua2 = mua1;
mus2 = mus1;
g2_25a = [];
inttime = 3;
lambda = 850;
n = 1.33;
load gauss_lag_5000.mat
l = 1.0;

for db1 = Db1s
    repnumber = repnumber+1;
    for ratio = Ratio
        db2 = db1*ratio;
            g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(1),w,l,mua2,mus2,db2,gl);
            normg1_10 = g1_10./g1_10(1);
            [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            sigma10 = getDCSNoise(200e3,T,inttime,beta,gamma,tau);
            for rep = 1:Rep
                for beta = Beta
                j = j+1;
                noise10_1 = sigma10.*randn(length(tau),1)';
                noise10_2 = sigma10.*randn(length(tau),1)';
                g2_10nn=  1 + beta.*normg1_10.^2;
                g2_10 = noise10_1 + g2_10nn;
                g2_10(1) = beta;
                %                 g2_10fit = strokefilter(g2_10,10);
                inputnn(j,:) = single(g2_10nn);
                input(j,:) = single([g2_10]);
                target(j,:) = single([db2*1e8 beta]);
                end
            end
    end
end
inputtarget = single([input target]);
%shuffles the dataset
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
%gets all the 
inputshuffle = inputtarget(:, 1:size(inputtarget,2) - 2);
targetshuffle = inputtarget(:, size(input,2):size(input,2)+1);
targetshuffledb1 = inputtarget(:, size(input,2) + 1);

%creates a function fitting net of size 10
%with Scaled conjugate gradient descent as optimizer funnction
net = fitnet(10, 'trainscg');
net1 = train( net, inputshuffle', targetshuffledb1');
%ensemble = fitrensemble(inputshuffle, targetshuffledb1);