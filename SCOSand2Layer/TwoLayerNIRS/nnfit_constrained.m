addpath('../functions')
constants
load('gauss_lag_5000.mat')

db1 = 5e-9; db2 = 2e-8;
rho = .5:.5:4.5;
mua1s = [.100:.0025:.125];
mua2s = [.1:.015:.25];
mus1s = [12:.3:15];
mus2s = [5:1.0:15];
ell = 1.0:.1:2.0;

tau = 0;
w = 110e6*2*pi;

index = 0;
siz = size(mua1s,2)*size(mua1s,2)*size(mus1s,2)*size(mus2s,2)*size(rho,2);
input = zeros(siz,2*size(tau,2)*size(rho,2));
target = zeros(siz, 5);
lambda = 850;
n = 1.37;
Reff=-1.440./n^2+0.710/n+0.668+0.0636.*n;

for mua1 = mua1s
    mua1
    for mua2 = mua2s
        for mus1 = mus1s
            for mus2 = mus2s
                for l = ell
                    [amp phase] = diffusionforwardsolverPL(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2, gl);
                    total = [squeeze(amp) squeeze(phase)];
                    index = index + 1;
                    input(index,:) = total(:);
                    target(index,:) = [mua1*10, mus1/5, mua2*10, mus2/5, l];
                end
            end
        end
    end
end
inputtarget = ([input target]);
inputtarget = (inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = (inputtarget(:, 1:size(input,2)));
targetshuffle = inputtarget(:, size(input,2) + [1:size(target,2)]);
targetshuffleell = inputtarget(:, size(input,2) + 5);
architecture = [18, 18];
net = fitnet(architecture, 'trainlm');
train(net, inputshuffle', targetshuffleell')
