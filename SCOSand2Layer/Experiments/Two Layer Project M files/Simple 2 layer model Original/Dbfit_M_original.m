close all
%clear all
addpath('..\..\..\functions');
constants
load gauss_lag_5000.mat

%ext='';
%time=[1 2 3 4 5 6 7];% 12 13];
%ratID = 'rat5';
%taus = tau;

plotfits=1;%If you want to display how well your fit compares to your raw g2 data
plotfigs=1;
fixbeta=0;%doesnt work yet in this code, must = 0
good_start = 2;

%Data directory
fdir = './';
id = '20';

% SD distance
SD_dist = 20;%mm 
used_ch = 1;%Only looking at DCS data from detector 2

mua = 0.125;%cm-1
musp = 4.8;%cm-1
    
%Define time points, tau, for g2 curves, FIXED TAU IN LABVIEW in Aug 2015!!!!  From sample.cpp code from jixiang to my gmail  on 3/18/15
first_delay=2e-7;
for I=1:16,
    DelayTime(I) = I*first_delay;
end

for J=1:30,
    for I=0:7,
        DelayTime(I+(J-1)*8+17) = DelayTime((J-1)*8+16+I)+first_delay*(2^J);
    end
end

DelayTime=DelayTime(1:256);
%Determine bin width for each tau
T=zeros(size(DelayTime));
for indt=1:length(T)-1
    T(indt)=DelayTime(indt+1)-DelayTime(indt);
end

%Layer 1(Skull/Scalp): mu_a : 0.19 cm-1 mu_sp: 8.58 cm-1
mua1 = 0.19; mus1 = 8.58;
%Layer 2(Brain): mu_a:0.2 cm-1  mu_sp:  9.9 cm-1
mua2= 0.2; mus2= 9.9;

%n=1.37
mua = .19;
musp = 8.58;
%PARAMETERS SPECIFIC TO THIS EXPERIMENT
%Define integration time (sec)
t=1;

% Convert to values in mm-1
mua = mua/10;
musp = musp/10;
%Initial guess for our g2 fit, [Db beta]
guess = [1e-6 0.5];
%Upper and lower bounds for fit [Db beta]
lb=[1e-10 0.5];
ub=[1e-3 0.5];
%Only fit g2 values above cutoff:
cutoff=1.05;  %default = 1.05
datalength=70;
%How many points to average in each curve for
%smoothing
avgnum=10;
cutoff_I=30;%kHz
cutoffCOV=20;%require COV to be less than cutoff
n0=1.37;%index of refraction for tissue
lambda=850*1e-6;%wavelength in mm
k0=2*pi*n0/lambda; %this is the k0 for flow!
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;
SD_dist = [10, 15, 20, 25, 30, 40]
beta = .5;
taurange = 1:80;
l = 1.5;

for i = 1:size(SD_dist,2)
    rho = SD_dist(i);
    data = load(['mcx_g1_TwoLayerModelSimp_1det_' num2str(rho) 'mmSDS.mat']);
    g1 = data.gTau(taurange,:);
    %g1 = g1/g1(1);
    g2 = beta*(g1).^2 + 1;
    g2s(i,:) = g2;
    tau = data.tauVals(taurange,:)';
    Dbbeta(i, :) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,tau,g2,rho,mua,musp,1,k0,R),guess,lb,ub);
    db1 = Dbbeta(i, 1);
    asd = dcs_g2fit_GT([db1 .5],tau,rho,mua,musp,k0,R,1);
    df = getG1(n0,R,mua1,mus1,db1,tau,850e0,rho,w,l,mua2,mus2,db1, gl);
end
%19.5709
g2slinearized = g2s(:)'
%prediction = net21(g2slinearized');
%semilogx(tau, g1.^2); hold on; semilogx(tau, df.^2);hold on; semilogx(tau, 2*(asd-1));
db1 = 1.0784e-8;
asd = dcs_g2fit_GT([db1 .5],tau,rho,mua,musp,k0,R,1);
df = squeeze(getG1(n0,R,mua1,mus1,db1,tau,850e0,SD_dist'/10,w,l,mua2,mus2,1.0519e-7, gl));
%hold on; semilogx(tau, df.^2);hold on; semilogx(tau, 2*(asd-1));
g2fit = df.^2*.5 + 1;
semilogx(tau, g2s'); hold on; semilogx(tau,g2fit);
guess = db1;
lb = 1e-10
ub = 1e-1;
fun = fminsearchbnd(@(x) norm(df - squeeze(getG1(n0,R,mua1,mus1,db1,tau,850e0,SD_dist'/10,w,l,mua2,mus2, x, gl))).^2, guess,lb,ub);