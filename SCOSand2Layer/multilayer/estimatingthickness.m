%this code tries to estimate thickness
constants
ell = [.5:.1:1.5];
Rho1 = [.5:.1:1.6];
db1 = 1e-8;
db2 = 1e-7;
n = 1.37;
Reff = .493;
mua = .2; % cm-1
musp = 10; % cm-1
mua2 = .2;
musp2= 10;
w = 0;
Rep = 1;
dbbetasum = zeros(size(Rep,2),1);
tau = DelayTime(2:1:131);
T = T(1:130);
guess = [1e-7 0.5];
lb=[1e-10 0.4];
ub=[1e-3 .6];
Beta = .5;
good_start = 1;
lambda=852*1e-6;%mm
k0=2*pi*n/lambda;
n0=n;
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;
j = 0;
i = 0;
lambdaDCS = 852;
[X Y] = meshgrid(Rho1, ell);
for l = ell
    j = j + 1
for rho = Rho1
    i= i +1;
    db = 0;
    bet = 0;
    sep10 = diffusionforwardsolver(n,Reff,mua,musp,db1,tau,lambdaDCS,rho,w,l,mua2,musp2,db2);
    normsep15 = sep10/sep10(1);
    [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
    gamma = 1/tau(index15);
    nsep15 = getDCSNoise(200e3/rho,T,1,Beta,gamma,tau); %50 hz.
    noise = nsep15.*randn(length(tau),1)';
    g2 = Beta.*normsep15.*normsep15 + noise + 1;
    %g2 = Beta.*normsep10.*normsep10  + 1;
    %cuttoff
    foo = 40;
    %Fit non-smoothed g2 using 
    %cutoff obtained from smoothed g2
    %foo
    g2 = g2(1:foo);
    tau1 = tau(1:foo);
    dbbeta = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau1,g2,rho*10,mua/10,musp/10,1,k0,R),guess,lb,ub);
    calcdb1 = dbbeta(1)*1e-2;
    calcbeta = dbbeta(2);
    %cuttoff
    Z(i,j) = (calcdb1-db1)/db1*100;
end
i=0;
end