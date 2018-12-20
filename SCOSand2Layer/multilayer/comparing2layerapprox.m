clear all
close all
constants
n = 1.4;
Reff = .493;
mua1 = .1; % cm-1
mus1 = 10; % cm-1
w = 0;
mua2 = mua1;% cm-1
mus2 = mus2;% cm-1
Rep = 1;
dbbetasum = zeros(size(Rep,2),1);
ell = .0001;%
Db1 = [4e-8];
Db2 = [7e-10];
T = T(1:1:130);
tau = DelayTime(2:1:131);
guess = [1e-7 0.5];
Beta = [.5];
lb=[1e-10 0.4];
ub=[1e-3 .6];
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
rho = 1.5; %cm
cutoff = 1.05;
good_start = 1;

for rep = 1:Rep
for l = 1:length(ell)
    for beta = 1:length(Beta)
        for db1 = 1:length(Db1)
            for db2 = 1:length(Db2)
                db = 0;
                bet = 0;
                %diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,mus2,aDb2)
                sep15 = diffusionforwardsolver(n,Reff,mua1,mus1,Db1(db1),tau,lambda,rho,w,ell(l),mua2,mus2,Db2(db2));
                normsep15 = sep15/sep15(1);
                [b, index15] = min(abs(normsep15-1/exp(1))); %find where g1 = 1/e
                gamma = 1/tau(index15);
                nsep15 = getDCSNoise(10e3,T,50,Beta(beta),gamma,tau); %50 hz.
                noise = nsep15.*randn(length(tau),1)';
                %g2 = beta.*normsep15.*normsep15 +noise + 1;
                g2 = Beta(beta).*normsep15.*normsep15  + 1;
                %cuttoff
                foo = min(find(g2 <= cutoff))+ good_start -1;
                if isempty(foo) || foo < good_start, foo=70;, end%Fit first 70 points 
                %Fit non-smoothed g2 using cutoff obtained from smoothed g2
                foo
                g2 = g2(1:foo);
                tau1 = tau(1:foo);
                
                dbbeta = fminsearchbnd(@(x) dcs_g2_Db_GT([x Beta(beta)],tau1,g2,rho*10,mua1/10,mus1/10,1,k0,R),guess,lb,ub);
                
                index = index + 1;
                Dbfit(index) = dbbeta(1);
                estimatedBeta(index) = dbbeta(2);
                difdb(index) = ((db1-dbbeta(1))/db1*100);
            end
        end
    end
end
dbbetasum(rep,:) = dbbeta(1);
end
id = find(dbbetasum > 1.1e-11)
dbbetasum = dbbetasum(id)
alol = mean(dbbetasum)

