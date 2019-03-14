addpath('../functions')
constants
load('gauss_lag_5000.mat')
w = 110e6;
l = 1.01;
db1 = aDb1(1);
db2 = aDb2(1);
rho = 1:.1:2.5;
tau = 0;
AF = 100;

mua1s =[.1:.05:.5];
mua2s = mua1s;
mus1s = [5:.5:10];
mus2s = mus1s;
ell = [.5:.1:1.5];
AF = 1;
index = 0;
siz = size(mua1s,2)^2*size(mus1s,2)^2*size(ell,2)*size(af,2);
input = zeros(siz, 2*size(rho,2));
target = zeros(siz, 6);
for mua1 = mua1s
    for mua2 = mua2s
        for mus1 = mus1s
            for mus2 = mus2s
                for l = ell
                    for af = AF
                        index = index + 1;
                        lol = [];
                        for rh = rho
                            [amp phase] = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rh,w,l,mua2,mus2,db2);
                            lol = [lol amp phase];
                        end
                        input(index, :) = lol;
                        target(index, :) = [mua1*10, mus1, mua2*10, mus2, l*10, af*10];
                    end
                end
            end
        end
    end
end
inputtarget = single([input target]);
inputtarget = single(inputtarget(randperm(size(inputtarget,1)),:));
inputshuffle = inputtarget(:, 1:size(input,2));
targetshuffle = inputtarget(:, (1:size(target,2)) + size(input,2));
