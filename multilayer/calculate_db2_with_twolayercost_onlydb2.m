clear all
close all
constants
addpath('G:\2-Layer Neural Net\functions');
Db1 = [.1e-7:.2e-7:10e-7];
Db2 = [.1e-7:.2e-7:10e-7];
ell = 1.0;%
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
guessc = [1e-7 1];
lbc=[1e-10 .75];
ubc=[1e-5 1.25];
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
rho = 1.00; %cm
rho2 = 2.5; %second detector in cm
%Rho1 = [.5:.1:1.5]
%Rho2 = [2:.1:3.5]
cutoff = 1.05;
good_start = 1;
i=0;
for db1 = Db1
    for db2 = Db2
        for l = ell;
            i=i+1
            db = 0;
            sep10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2);
            normsep15 = sep10/sep10(1);
            [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
            gamma = 1/tau(index15);
            nsep15 = getDCSNoise(250e3,T,1,Beta,gamma,tau); %50 hz.
            noise = nsep15.*randn(length(tau),1)';
            g2 = Beta.*normsep15.*normsep15 + 1;
            %g2 = g2 + noise;
            %cuttoff
            minexceedscutoff = find(g2 <= cutoff);
            foo = minexceedscutoff(1) + good_start -1;
            if isempty(foo) || foo < good_start, foo=70;, end%Fit first 70 points
            %Fit non-smoothed g2 using cutoff obtained from smoothed g2 foo
            g2cut = g2(1:foo);
            tau1 = tau(1:foo);
            dbbeta(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau1,g2cut,rho*10,mua1/10,mus1/10,1,k0,R),guess,lb,ub);
            calcdb1 = dbbeta(i,1)*1e-2;
            calcbeta = dbbeta(i,2);
            %cuttoff
            for detector = Detector
                sep25 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho2,w,l,mua2,mus2,db2);
                norm25 = sep25/sep25(1);
                [b, index25] = min(abs(norm25-1/exp(1))); %find where g1 = 1/e
                gamma = 1/tau(index25);
                nsep25 = getDCSNoise(25e3,T,3,Beta,gamma,tau); %50 hz.
                noise25 = nsep25.*randn(length(tau),1)';
                %g2_25_arr(detector,:) = Beta.*norm25.*norm25 + noise25 + 1;
                g2_25_arr(detector,:) = Beta.*norm25.*norm25  + 1;
            end
            g2_25=mean(g2_25_arr);
            cutoff25 = find(g2_25 <= cutoff);
            foo25 = cutoff25(1) + good_start -1;
            if isempty(foo25) || foo25 < good_start, foo25=70;, end%Fit first 70 points
            g2_25 = g2_25(1:foo);
            tau25 = tau(1:foo);
            %beta25 = mean2(g2_25(1,1:10))-1;
            [dbbeta25(i,1) a1(i,1)] = fminsearchbnd(@(x) twolayercostonlydb2(x, ell, 0.5 ,g2_25,n,Reff,mua1,mus1,calcdb1,tau25,lambda,rho2,w,mua2,mus2),guessc(1),lbc(1),ubc(1));
            error(i,1) = (db1-dbbeta(i,1)*1e-2)/db1*100
            db2error = (db2-dbbeta25(i,1))/db2*100
            error(i,2) = db2error;
        end
    end
end
avg = mean(abs(error));
std = abs(std(error));