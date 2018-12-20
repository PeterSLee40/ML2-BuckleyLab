clear all
close all
constants
addpath('F:\2-Layer Neural Net\functions');
load gauss_lag_5000.mat;
Db1 = [1e-8:1e-8:5e-8];
Db2 = [1e-8:1e-8:5e-7];
ell = [.8:.1:1.1];%
dbbeta = zeros(length(ell),2);
dbbeta25 = zeros(length(ell),3);
Detector = 1:7
g2_25_arr = zeros(length(Detector),130);
g2 = zeros(1,130);
n = 1.37;
Reff = .493;
mua1 = .19; % cm-1
mus1 = 7.8*(1-.89)*10; % cm-1
w = 0;
mua2 = .2;% cm-1
mus2 = 9*(1-.89)*10;% cm-1
Rep = 1;
dbbetasum = zeros(size(Rep,2),1);

tau = DelayTime(2:1:131);
T = diff(DelayTime(2:1:132));
guess = [1e-7 0.5];
Beta = .5;
lb=[1e-10 0.4];
ub=[1e-5 .6];
%lb and ub for twolayercost
lbc=[1e-10 .7];
ubc=[1e-5 1.15];
guessc = lbc;
guesscb = [1e-7 1 0.5];
lbcb=[1e-10 .75 0.45];
ubcb=[1e-5 1.25 0.55];
lambda=852*1e-6;%mm
k0=2*pi*n/lambda;
n0=n;
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;
beta = zeros;
siz = size(Beta,2)*size(Db1,2)*size(Db2,2)*size(ell,2);
estimatedBeta = zeros(1,siz);
Dbfit = zeros(1,siz);
error = zeros(siz,2);
difdb=estimatedBeta;
lambda = 852; %nm
index = 0;
rho = 1; %cm
rho2 = 2.25; %second detector in cm
Rho1 = [.5:.1:1.5]
Rho2 = [2:.1:3.5]
cutoff = 1.05;
good_start = 1;
i=0;
r1=0;
r2=0;
Z = zeros(length(Rho1),length(Rho2));
[X Y] = meshgrid(Rho2, Rho1);
for rho = Rho1
    r1 = r1 + 1;
    for rho2 = Rho2
        r2 = r2 + 1;
for db1 = Db1
    for db2 = Db2
        for l = ell;
            i=i+1
            sep10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2,gl);
            normsep15 = sep10/sep10(1);
            [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(200e3,T,1,Beta,gamma,tau); %50 hz.
            noise = nsep15.*randn(length(tau),1)';
            g2 = Beta.*normsep15.*normsep15 + noise + 1;
            %g2 = Beta.*normsep10.*normsep10  + 1;
            %cuttoff
            minexceedscutoff = find(g2 <= cutoff);
            foo = minexceedscutoff(1)+ good_start -1;
            if isempty(foo) || foo < good_start, foo=70;, end%Fit first 70 points
            %Fit non-smoothed g2 using cutoff obtained from smoothed g2 foo
            g2cut = g2(1:foo);
            tau1 = tau(1:foo);
            dbbeta(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau1,g2cut,rho*10,mua1/10,mus1/10,1,k0,R),guess,lb,ub);
            calcdb1 = dbbeta(i,1)*1e-2;
            calcbeta = dbbeta(i,2);
            %cuttoff
            for detector = Detector
                sep25 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho2,w,l,mua2,mus2,db2,gl);
                norm25 = sep25/sep25(1);
                [b, index25] = min(abs(norm25-1/exp(1))); %find where g1 = 1/e
                gamma = 1/tau(index25);
                nsep25 = getDCSNoise(25e3,T,3,Beta,gamma,tau); %50 hz.
                noise25 = nsep25.*randn(length(tau),1)';
                g2_25_arr(detector,:) = Beta.*norm25.*norm25 + noise25 + 1;
                %g2_25_arr(detector,:) = Beta.*normsep25.*normsep25  + 1;
            end
            g2_25 = mean(g2_25_arr);
            %cutoff25 = find(g2_25 <= cutoff);
            %foo25 = cutoff25(1) + good_start -1;
            %if isempty(foo25) || foo25 < good_start, foo25=70;, end%Fit first 70 points
            foo = 50;
            g2_25 = g2_25(1:foo);
            input(i,:) = [db1 rho rho2 mua1 mus1 mua2 mus2 db2 g2_25];
            tar(i,:) = [db2 l];
            tau25 = tau(1:foo);
            beta25 = mean2(g2_25(1,1:10))-1;
            dbbeta25(i,1:2) = fminsearchbnd(@(x) twolayercost(x,beta25,g2_25,n,Reff,mua1,mus1,calcdb1,tau25,lambda,rho2,w,mua2,mus2),guessc,lbc,ubc);
            error(i,1) = (db1-dbbeta(i,1)*1e-2)/db1*100;
            db2error = (db2-dbbeta25(i,1))/db2*100
            error(i,2) = db2error;
        end
    end
end
i = 0;
avgerr = mean(abs(error(:,2)));
%sted = std2(abs(error(:,2)));
Z(r1,r2) = avgerr;
    end
end
surf(X,Y,Z);
