clc
tic
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\functions');
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\multilayer');
constants

noise = true;

ell = 0.95:.002:1.05;
tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
% tau = 5e-6:5e-6:1e-3;
% T = 5e-6.*ones(1,size(tau,2));
g= 0
repnumber = 0;
Db1 = 8e-9;
Ratio = 3:.1:10;
Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));

sigmashort = zeros(1,siztau), noiseshort = sigmashort, g2_short = sigmashort;
sigmalong = sigmashort, g2_long = sigmashort, noiselong = sigmashort;

j = 0;
Rep = 30;
Beta = 0.5;
Intensity = 20e3;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Intensity,2)
siztau = size(tau,2);
input = single(zeros(siz,8*size(tau,2)));
inputnn = single(zeros(siz,2*size(tau,2)));
target = single(zeros(siz,1));
beta = .5;
load gauss_lag_5000.mat
Rho1 = [.8:.1:1.5]
Rho2 = [1.5:.1:3.0]
i = 0;
j = 0;
optimalGrid = zeros(size(Rho1,2),size(Rho2,2));
for rho1 = Rho1
    i = i + 1;
    for rho2 = Rho2
        j = j + 1;
        for db1 = Db1s
            repnumber = repnumber+1
            for ratio = Ratio1
                ratio
                for l = ells
                    db2 = db1*ratio;
                    [g1_short, gammashort] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,rho1,w,l,mua2,mus2,db2, gl);
                    [g1_long, gammalong] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,rho2,w,l,mua2,mus2,db2, gl);
                    g2_shortnn =  1 + beta.*g1_short.^2;
                    g2_longnn =  1 + beta.*g1_long.^2;
                    
                    for rep = 1:Rep
                        j = j + 1;
                        
                        sigmashort = getDCSNoise(getIntensity(rho1, 20),T,3,beta,gammashort,tau);
                        noiseshort = sigmashort.*randn(length(tau),1)';
                        %noiseshort = 0;
                        g2_short = noiseshort + g2_shortnn;
                        
                        sigmalong = getDCSNoise(getIntensity(rho2, 20),T,3,beta,gammalong,tau);
                        noiselong = sigmalong.*randn(length(tau),7)';
                        %noiseshort = 0;
                        g2_long = noiselong + g2_longnn;
                        
                        input(j,:) = single([g2_short g2_long(:)']);
                        inputnn(j, :) = single([g2_shortnn g2_longnn]);
                        target(j,:) = single([db2*1e8]);
                    end
                end
            end
        end
        inputtarget = single([input target]);
        inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
        inputshuffle = inputtarget(:, 1:(size(inputtarget,2)-1));
        targetshuffle = inputtarget(:, size(inputtarget,2));
        
        net = train(net1,inputshuffle,targetshuffle);
        y = net(inputshuffle);
        optimalGrid(i,j) = perform(net1,y,targetshuffle)
        
    end
end




nnstart

