clc
tic
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\functions');
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\multilayer');
constants

%addpath('/Volumes/PETER128/SCOSand2Layer/functions');
%change this to add noise
noise = true;

ell = 0.75:.02:1.15;
%
tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
% tau = 5e-6:5e-6:1e-3;
% T = 5e-6.*ones(1,size(tau,2));
g= 0
repnumber = 0;
Db1 = 7.8e-9:.01e-9:8e-9;
Ratio = 3:.1:10;
Db1s = Db1(:, randperm(size(Db1,2)));
ells = ell(:, randperm(size(ell,2)));
Ratio1 = Ratio(:, randperm(size(Ratio,2)));

j = 0;
Rep = 3;
Beta = 0.5;
Intensity = 370e3;
siz = size(Db1s,2)*size(Ratio1,2)*size(ells,2)*Rep*size(Intensity,2)
input = single(zeros(siz,8*size(tau,2)));
inputnn = single(zeros(siz,2*size(tau,2)));
targetdb1 = single(zeros(siz,1));
targetdb2 = single(zeros(siz,1));

beta = .5;

load gauss_lag_5000.mat
for db1 = Db1s
    repnumber = repnumber+1
    for ratio = Ratio1
        for l = ells
            db2 = db1*ratio;
            g1_short = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.0,w,l,mua2,mus2,db2, gl);
            normg1_short = g1_short./g1_short(1);
            [b, indexshort] = min(abs(normg1_short-1/e)); %find where g1 = 1/e
            gammashort = 1/tau(indexshort);
            
            g1_long = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2, gl);
            normg1_long = g1_long./g1_long(1);
            [b, indexlong] = min(abs(normg1_long-1/e)); %find where g1 = 1/e
            gammalong = 1/tau(indexlong);
            
            [g1_long1, gammalong1] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,2.0,w,l,mua2,mus2,db2, gl);
            
            
            g2_shortnn =  1 + beta.*normg1_short.^2;
            g2_longnn =  1 + beta.*normg1_long.^2;
            g2_long1nn =  1 + beta.*g1_long.^2;
            sigmashort = getDCSNoise(500e3,T,3,beta,gammashort,tau);
            sigmalong = getDCSNoise(Intensity,T,3,beta,gammalong,tau);
            sigmalong1 = getDCSNoise(100e3,T,3,beta,gammalong,tau);
            for rep = 1:Rep
                j = j + 1;
                noiseshort = sigmashort.*randn(length(tau),1)';
                %noiseshort = 0;
                
                g2_short = noiseshort + g2_shortnn;
                
                
                noiselong = sigmalong.*randn(length(tau),6)';
                
                noiselong1 = sigmalong1.*randn(length(tau),1)';

                %noiseshort = 0;
                
                g2_long = noiselong + g2_longnn;
                
                g2_long1 = noiselong1 + g2_long1nn;
                
                input(j,:) = single([g2_short(:)' g2_long(:)' g2_long1(:)']);
                inputnn(j, :) = single([g2_shortnn g2_longnn]);
                targetdb1(j,:) = single([db1*1e8]);
                targetdb2(j,:) = single([db2*1e8]);
            end
        end
    end
end

%inputbeta = single(zeros(siz*size(Beta,2),short0));
%targetbeta = single(zeros(siz*size(Beta,2),short0));
% i = 0;
% for bet = Beta
%     indices = [1:siz] + siz*i;
%     inputbeta(indices, :) = (input - 1).*bet/0.5 + 1;
%     targetbeta(indices,:) = target;
%     i = i + 1;
% end
%
inputtarget = single([input targetdb1]);
inputtarget1 = single([input targetdb2]);
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = inputtarget(:, 1:(size(inputtarget,2)-1));
targetshuffle = inputtarget(:, size(inputtarget,2));
%inputflip = fliplr(inputshuffle);


%csvwrite('TSG_db2_4_target.csv',targetshuffle)
%csvwrite('TSG_db2_4_input.csv',inputshuffle)
%csvwrite('TSG_db2_4_inputnn.csv',inputnnshuffle)

nnstart
% a = input';
% semilogx(tau, a(121:240, :));
% b = inputnn';
% semilogx(tau, b(121:240, :));
count = gpuDeviceCount;
gpu1 = gpuDevice(1);
net1 = fitnet(10,'trainscg');
net1 = train(net1,inputshuffle',targetshuffle', 'useGPU','yes');
y = net1(inputshuffle', 'useGPU','yes');
