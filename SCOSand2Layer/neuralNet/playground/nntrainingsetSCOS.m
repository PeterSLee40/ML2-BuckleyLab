% with musp & mua restriction
% add wavelength constraints
clear,
close all
addpath('H:\SCOSand2Layer\functions');


lambdas = [750 785 800 830]*1e-7; % cm-1
beta = 0.5;
pct_noise = 2;

exp_t = 50:50:500;
exp_t = exp_t*1e-6;
r = 1:0.1:2;

a = 10;
b = 1;
A = 5:1:15;
B = .5:.1:1.5;
A = A(randperm(length(A)));
B = B(randperm(length(B)));

HbT = 60e-6; % M
StO2 = 0.75; %

[eHbO,eHbR] = getextinctioncoef_new(0,0,lambdas*1e7);

musp = a*(lambdas/lambdas(1)).^(-b);
mua = 2.303*(eHbO*HbT*StO2 + eHbR*HbT*(1-StO2));
mu_eff = musp.*mua.';
Db_fixed = 1e-10:.3e-9:1e-8;
Db_fixed = Db_fixed(randperm(length(Db_fixed)));
index = 0;
Rep = 1:10

sim_kappa = zeros(11,10,4);
noisy_sim_kappa = sim_kappa;
siz = max(size(Rep)) * max(size(A)) * max(size(B)) * max(size(Db_fixed));
input = zeros(siz,440);
target = zeros(siz,3);


for rep = Rep
    tic
    rep
    for db_fixed = Db_fixed
        for a = A;
            for b = B;
                index = index + 1;
                sim_kappa = zeros(size(r,2),size(exp_t,2));
                for i = 1:size(r,2)
                    for j = 1:size(exp_t,2)
                        for k = 1:size(lambdas,2)
                            muspab = a.*(lambdas(k)/lambdas(1)).^(-b);
                            sim_kappa(i,j,k) = forward_kappa(muspab, mua(k),r(i),exp_t(j),db_fixed,lambdas(k),beta);
                        end
                    end
                end
                rn = (-1)*pct_noise + 2*(pct_noise)*rand(size(r,2),size(exp_t,2),size(lambdas,2));
                noisy_sim_kappa = sim_kappa.*(1+(rn/100));
                input(index, :) = noisy_sim_kappa(:);
                target(index,:) = [db_fixed*1e8 a/10 b];
            end
        end
    end
    toc
end
inputtarget = [input target];
inputtargetshuffle = inputtarget(randperm(size(inputtarget,1)),:);
inputshuffle = inputtargetshuffle(:,1:440);
targetshuffle = inputtargetshuffle(:,441:443);
nnstart

