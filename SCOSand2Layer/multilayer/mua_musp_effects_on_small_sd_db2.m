clear all
close all
constants
addpath('G:\2-Layer Neural Net\functions');
Db1 = [.1e-8:.1e-8:1e-8];
Db2 = [.1e-8:.1e-8:1e-8];
ell = [.8:.1:1];%
%ratio is db2/db1
l = .8%cm
db1 = 1e-7;
db2 = 1e-7;
Mua = [.1:.05:.3]
Musp = [5:2:15]

dbbeta = zeros(length(ell),2);
dbbeta25 = zeros(length(ell),2);
Detector = 1:7
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
Dbfit = zeros(1,siz);
difdb=estimatedBeta;
lambda = 852; %nm
index = 0;
rho = 1.0; %cm
rho2 = 2.5; %second detector in cm
cutoff = 1.05;
good_start = 1;
i = 0;
j = 0;
[X Y] = meshgrid(Mua, Musp);
for mua = Mua
    j = j + 1
for musp = Musp
    i=i+1;
    db = 0;
    bet = 0;
    sep10 = diffusionforwardsolver(n,Reff,mua,musp,db1,tau,lambda,rho,w,l,mua2,mus2,db2);
    normsep15 = sep10/sep10(1);
    [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
    gamma = 1/tau(index15);
    nsep15 = getDCSNoise(200e3,T,1,Beta,gamma,tau); %50 hz.
    noise = nsep15.*randn(length(tau),1)';
    g2 = Beta.*normsep15.*normsep15 + noise + 1;
    %g2 = Beta.*normsep10.*normsep10  + 1;
    %cuttoff
    foo = min(find(g2 <= cutoff))+ good_start -1;
    if isempty(foo) || foo < good_start, foo=70;, end%Fit first 70 points
    %Fit non-smoothed g2 using 
    %cutoff obtained from smoothed g2
    %foo
    g2 = g2(1:foo);
    tau1 = tau(1:foo);
    dbbeta(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau1,g2,rho*10,mua/10,musp/10,1,k0,R),guess,lb,ub);
    calcdb1 = dbbeta(i,1)*1e-2;
    calcbeta = dbbeta(i,2);
    %cuttoff
    Z(i,j,1) = (calcdb1-db1)/db1*100;
end
i=0;
end
surf(X,Y,Z), colorbar;
xlabel('Mua');
ylabel('Musp');
zlabel('Percent Error');
set(gca,'YDir','reverse');

