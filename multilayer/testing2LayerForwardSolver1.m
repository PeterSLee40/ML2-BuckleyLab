%create a one layer forward model, try to fit for db1
addpath('F:\SCDOR03_033018\Peter\Functions\functionsP');
n = 1.37;
Reff = .493;
mua1 = .2; % cm-1
mus1 = 10; % cm-1
w = 0;
mua2 = .2;% cm-1
mus2 = 10;% cm-1
lambda = 852;
rho1 = 1.5;
rho2 = 2.5;
op=optimset('fminsearch');
options=optimset(op,'MaxIter',3e5,'MaxFunEvals',3e5,'TolFun',1.000e-12,'TolX',1.000e-12,'Display','Final');
db1mean = movmean(Dbfit(:,1),10);

dcs_g2fit_GT(x0,tau,p,mu_a,mu_sp,k0,Reff,alpha)
