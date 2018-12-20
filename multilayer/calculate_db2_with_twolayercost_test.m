clear all
close all
constants
addpath('F:\2-Layer Neural Net\functions');
Db1 = 3e-8;
Db2 = 3e-8;
ell = [.8:.01:1];%
dbbeta = zeros(length(ell),2);
dbbeta25 = zeros(length(ell),2);

n = 1.37;
Reff = .493;
mua1 = .19; % cm-1
mus1 = 7.8*(1-.89)*10; % cm-1
w = 0;
mua2 = .2;% cm-1
mus2 = 9*(1-.89)*10;% cm-1
Rep = 1;
dbbetasum = zeros(size(Rep,2),1);
T = T(1:1:130);
tau = DelayTime(2:1:131);
guess = [1e-7 0.5];
Beta = .5;
lb=[1e-10 0.4];
ub=[1e-3 .6];
%lb and ub for twolayercost
guessc = [1e-7 1];
lbc=[1e-10 .1];
ubc=[1e-3 3];
lambda=852*1e-6;%mm
k0=2*pi*n/lambda;
n0=n;
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;
beta = zeros;
siz = size(Beta,2)*size(Db1,2)*size(Db2,2)*size(ell,2);
estimatedBeta = zeros(1,siz);
j = 0;
Dbfit = zeros(1,siz);
difdb=estimatedBeta;
lambda = 852; %nm
index = 0;
rho = 1; %cm
rho2 = 2.5; %second detector in cm
cutoff = 1.05;
good_start = 1;
for i = 1:length(ell)
    l = ell(i)
    db = 0;
    bet = 0;
    %diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,mus2,aDb2)
    sep10 = diffusionforwardsolver(n,Reff,mua1,mus1,Db1,tau,lambda,rho,w,l,mua2,mus2,Db2);
    normsep10 = sep10/sep10(1);
    %[b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
    %gamma = 1/tau(index15);
    %nsep15 = getDCSNoise(10e3,T,50,Beta,gamma,tau); %50 hz.
    %noise = nsep15.*randn(length(tau),1)';
    %g2 = Beta.*normsep15.*normsep15 + noise + 1;
    g2 = Beta.*normsep10.*normsep10  + 1;
    %cuttoff
    foo = min(find(g2 <= cutoff))+ good_start -1;
    if isempty(foo) || foo < good_start, foo=70;, end%Fit first 70 points
    %Fit non-smoothed g2 using cutoff obtained from smoothed g2
    %foo
    g2 = g2(1:foo);
    tau1 = tau(1:foo);
    dbbeta(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau1,g2,rho*10,mua1/10,mus1/10,1,k0,R),guess,lb,ub);
    calcdb1 = dbbeta(i,1)*1e-2;
    calcbeta = dbbeta(i,2);
    sep25 = diffusionforwardsolver(n,Reff,mua1,mus1,Db1,tau,lambda,rho2,w,l,mua2,mus2,Db2);
    normsep25 = sep25/sep25(1);
    [b, index25] = min(abs(normsep25-1/exp(1))); %find where g1 = 1/e
    gamma = 1/tau(index25);
    nsep25 = getDCSNoise(25e3,T,50,Beta,gamma,tau); %50 hz.
    noise25 = nsep25.*randn(length(tau),1)';
    g2_25 = Beta.*normsep25.*normsep25 + noise25 + 1;
    %g2_25 = Beta.*normsep25.*normsep25  + 1;
    %cuttoff
    foo25 = min(find(g2_25 <= cutoff))+ good_start -1;
    if isempty(foo25) || foo25 < good_start, foo25=70;, end%Fit first 70 points
    g2_25 = g2_25(1:foo);
    tau25 = tau(1:foo);
    
    dbbeta25(i,:) = fminsearchbnd(@(x) twolayercost(x,calcbeta,g2_25,n,Reff,mua1,mus1,calcdb1,tau25,lambda,rho2,w,mua2,mus2),guessc,lbc,ubc);

end

index = index + 1;
Dbfit = dbbeta(:,1);
percentagediff = Dbfit./Db1
plot(percentagediff);

