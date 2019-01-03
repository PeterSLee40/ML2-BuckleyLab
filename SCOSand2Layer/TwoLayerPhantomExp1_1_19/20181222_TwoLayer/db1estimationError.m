constants

Db1 = .2e-8;
Db2 = Db1*10;
ell = 1
dbbeta = zeros(length(ell),2);

n = 1.37;
Reff = .493;
w = 0;

mua1=0.1287; mus1=6.7790;
%bottom layer
mua2= 0.1391; mus2= 6.3814;
Rep = 1;
dbbetasum = zeros(size(Rep,2),1);

T = T(1:1:100);
tau = DelayTime(2:1:101);
Beta = .5;

guess = [1e-7 0.5];
lb=[1e-11 0.4];
ub=[1e-2 .55];

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
lambda = 850; %nm
index = 0;
rho = 1; %cm
cutoff = 1.05;
good_start = 5;
i = 0;
load gauss_lag_5000.mat

Ratio = 2:.2:10;
Ell = .9:.02:1.1;
Rho = [.5:.1:2.5];
Beta  = .45:.01:.52;
inttime = 3;

db1 = Db1;
for ratio = Ratio
    ratio
    for ell = Ell
        for rho = Rho
            i = i + 1;
            db2 = ratio*Db1;
            l = ell;
            curmua1 = mua1; curmus1 = mus1;
            curmua2 = mua2; curmus2 = mus2;
            currInt = getIntensity(rho,20);
            [g1s, gamma] = getG1(n,Reff,curmua1,curmus1,db1,tau,lambda,rho,w,l,curmua2,curmus2,db2,gl);
            for beta = Beta,    j = j + 1;
                betaRand = beta.*(randn(1)*.01+1);
                sigmas = getDCSNoise(currInt,T,inttime,betaRand,gamma,tau);
                noises = sigmas.*randn(1, size(tau,2));
                g2s = betaRand.*g1s.^2 + 1;
                g2s_noise = noises + g2s;
            end
            g2 = g2s_noise;
            foo = min(find(g2 <= cutoff))+ good_start -1;
            if isempty(foo) || foo < good_start, foo=70;, end%Fit first 70 points
            %Fit non-smoothed g2 using cutoff obtained from smoothed g2
            %foo
            g2 = g2(1:foo);
            tau1 = tau(1:foo);
            dbbeta(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau1,g2,rho*10,mua1/10,mus1/10,1,k0,R),guess,lb,ub);
        end
        i = 0;
        Dbfit = dbbeta(:,1);
        percentagediff = (Dbfit*1e-2 - db1)./db1*100;
        xlabel('Source-Detector separation in cm');
        ylabel('Db1 estimation error percentage');
        plot(Rho, percentagediff'); hold on;
    end
end

