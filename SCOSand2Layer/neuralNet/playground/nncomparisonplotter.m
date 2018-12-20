Db = [.51 1.01 1.51].*1e-8;
lambdas = [750 785 800 830]*1e-7; % cm-1
beta = 0.5;
pct_noise = 100;
exp_t = 50:50:500;
exp_t = exp_t*1e-6;
r = 1:0.1:2;

HbT = 60e-6; % M
StO2 = 0.75; % 
[eHbO,eHbR] = getextinctioncoef_new(0,0,lambdas*1e7);
musp = a*(lambdas/lambdas(1)).^(-b);
mua = 2.303*(eHbO*HbT*StO2 + eHbR*HbT*(1-StO2));
mu_eff = musp.*mua.';
Rep = 1:5;
index = 0;
for db = Db
    for rep = Rep
        index = index + 1;
        for i = 1:size(r,2)
            for j = 1:size(exp_t,2)
                for k = 1:size(lambdas,2)
                    sim_kappa(i,j,k) = forward_kappa(musp(k),mua(k),r(i),exp_t(j),db,lambdas(k),beta);
                end
            end
        end
        rn = (-1)*pct_noise + 2*(pct_noise)*rand(size(r,2),size(exp_t,2),size(lambdas,2));
        noisy_sim_kappa = sim_kappa.*(1+(rn/100));
        
        input = noisy_sim_kappa(:);
        ouput = net(input);
        actual(index) = db;
        prediction(index) = [ouput(1)*1e-8 a b];
    end
    e
end

scatter(actual, prediction);