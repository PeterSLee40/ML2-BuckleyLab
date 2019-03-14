addpath('../functions')
constants
load('gauss_lag_5000.mat')
db1 = 5e-9;
db2 = 1e-8;
tau = tau(5:85)
mua1s = [.1:.05:.5];
mua2s = mua1s;
mus1s = [5:.5:15];
ell = .5:.1:1.5
mus2s = mus1s;
index = 0;
siz = size(mua1s,2)*size(mus2s,2)*size(mus1s,2)*size(mus2s,2)*size(rho,2);
inputshuffle = zeros(siz,2*size(tau,2)*size(rho,2));
target = zeros(siz, 5);
for mua1 = mua1s
    mua1
    for mua2 = mus2s
        for mus1 = mus1s
            for mus2 = mus2s
                for l = ell
                    total = [];
                    for a = 1:size(rho,2)
                        rh = rho(a);
                        %[amp phase] = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rh,w,l,mua2,mus2,db2);
                        [amp phase] = diffusionforwardsolverPL(n,Reff,mua1,mus1,db1,tau,lambda,rh,w,l,mua2,mus2,db2, gl);
                        total = [total, amp, phase];

                    end
                    index = index + 1;
                    inputshuffle(index,:) = total;
                    target(index,:) = [mua1, mus1, mua2, mus2, l];
                end
            end
        end
    end
end
