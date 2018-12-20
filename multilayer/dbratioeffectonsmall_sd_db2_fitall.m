%this uses the twolayersolverall function to solve for db1, db2 and
%thickness
clear all
close all
constants
addpath('H:\SCOSand2Layer\functions');
Db1 = [.1e-8:.1e-8:1e-8];
Db2 = [.1e-7:.1e-7:1e-7];
ell = [.95:.1:1.05];%
%ratio is db2/db1
l = 1%cm
db = 1.0e-8;
db1 = 1.0e-8;
db2 = 1.0e-8;
rho = 1.0; %cm
rho2 = 2.5; %second detector in cm

Ratio = [0.3:.1:1];
dbbeta = zeros(length(ell),2);
Detector = 1:7
n = 1.37;
Reff = .493;
mua1 = .2; % cm-1
mus1 = 10; % cm-1
w = 0;
mua2 = .2;% cm-1
mus2 = 10;% cm-1
Rep = 1;
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
cutoff = 1.05;
good_start = 1;
i = 0;
j = 0;
load gauss_lag_5000.mat;
[X Y] = meshgrid(Ratio, ell);

op=optimset('fminsearch');
options=optimset(op,'MaxIter',3e5,'MaxFunEvals',3e5,'TolFun',1.000e-6,'TolX',1.000e-6,'Display','Final');

for ratio = Ratio
    j = j + 1
    db2 = db*(10^(ratio));
    for l = ell
        i=i+1;
        sep10 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho,w,l,mua2,mus2,db2);
        normsep10 = sep10/sep10(1);
        [b, index10] = min(abs(normsep10-1/exp(1))); %find where g1 = 1/e
        gamma = 1/tau(index10);
        nsep15 = getDCSNoise(300e3,T,5,Beta,gamma,tau); %50 hz.
        noise = nsep15.*randn(length(tau),1)';
       
        g2arr = noise + Beta.*normsep10.*normsep10  + 1;
        %g2 =g2 + noise;
        %cuttoff
        foo = min(find(g2arr <= cutoff))+ good_start -1;
        start10 = 10;
        if isempty(foo) || foo < good_start, foo=70;, end%Fit first 70 points
        %Fit non-smoothed g2 using
        %cutoff obtained from smoothed g2 foo
        g2 = g2arr(start10:foo);
        tau1 = tau(start10:foo);
        dbbeta(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau1,g2,rho*10,mua1/10,mus1/10,1,k0,R),guess,lb,ub);
        calcdb1 = dbbeta(i,1)*1e-2;
        calcbeta = dbbeta(i,2);
        %cuttoff
        for detector = Detector
            sep25 = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rho2,w,l,mua2,mus2,db2);
            norm25 = sep25/sep25(1);
            [b, index25] = min(abs(norm25-1/exp(1))); %find where g1 = 1/e
            gamma = 1/tau(index25);
            nsep25 = getDCSNoise(200e3,T,5,Beta,gamma,tau); %50 hz.
            noise25 = nsep25.*randn(length(tau),1)';
            %g2_25_arr(detector,:) = Beta.*norm25.*norm25 + noise25 + 1;
            g2_25_arr(detector,:) = Beta.*norm25.*norm25  + 1 + noise25;
        end
        g2_25=mean(g2_25_arr);
        cutoff25 = find(g2_25 <= 1+.43);
        foo25 = cutoff25(1) + good_start -1;
        foo25=20;
        start10 = 20;
        start25 = 5;
        if isempty(foo25) || foo25 < good_start, foo25=70;, end%Fit first 70 points
        g2cut = g2arr(start10:start10+foo25-1);
        tau1 = tau(start10:start10+foo25-1);
        g2_25 = g2_25(1:foo25);
        tau25 = tau(1:foo25);
        %beta25 = mean2(g2_25(1,1:10))-1;
        guess2 = [calcdb1*.98 calcdb1*2 1.0];
        lb2 = [calcdb1*.96 calcdb1*1.9 .95];
        ub2 = [calcdb1*.99 calcdb1*10  1.05];        
        [dbbeta25(i,:) a1(i,1)] = fminsearchbnd(@(x) twolayercostfitbothrhodb(x, 0.5, g2cut, g2_25,n,Reff,mua1,mus1,tau1, tau25,lambda,rho,rho2,w,mua2,mus2),guess2,lb2,ub2);
        %[dbbeta25(i,:) a1(i,1)] = fminsearchbnd(@(x) twolayercostfitbothrhodb(x, 0.5, g2cut, g2_25,n,Reff,mua1,mus1,tau1, tau25,lambda,rho,rho2,w,mua2,mus2),guess2,lb2,ub2,options);
        %[dbbeta25(i,:) a1(i,1)] = fminsearchbnd(@(x) twolayercostonlydb2(x, l, 0.5 ,g2_25,n,Reff,mua1,mus1,calcdb1,tau25,lambda,rho2,w,mua2,mus2),guessc(1),lbc(1),ubc(1));
        %(db2-dbbeta25(i,2))/db2.*100
        db1error = (db1-calcdb1)/db1*100
        error(i,j,1) = (db1-dbbeta25(i,1))/db1*100;
        db2error = (db2 - dbbeta25(i,2))/db2*100
        error(i,j,2) = db2error;
        thicknesserror = (l - dbbeta25(i,3))/l*100
        error(i,j,3) = thicknesserror;
        error(i,j,4) = (db1-calcdb1)/db1*100;
        
        Z(i,j,1) = db2error;
    end
    i=0;
end
surf(X,Y,Z), colorbar;
xlabel('log(ratio of db1/db2)');
ylabel('thickness');
zlabel('Percent Error of db2');
set(gca,'YDir','reverse');
c = colorbar;
caxis([-20 20]);

% cleaned up graph
% surf(X(1:8,1:8),Y(1:8,1:8),Z(1:8,1:8)), colorbar;
% xlabel('log(ratio of db1/db2)');
% ylabel('thickness');
% zlabel('Percent Error of db2');
% set(gca,'YDir','reverse');
% c = colorbar;
% caxis([-20 20]);
