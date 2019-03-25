%close all
%clear all
addpath('..\..\functions');
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
guess = [1e-7 0.49];
%Upper and lower bounds for fit [Db beta]
lb=[1e-10 0.45];
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
SD_dist = [10, 15, 20, 25]
beta = .5;
taurange = 1:80;
l = 1.5;
tau = tau(taurange);
db1 = 3e-6;
x0 = 1;
rho = 2;
asd = dcs_g2fit_GT([db1 .5],tau,rho,mua1,mus1,k0,R,1);
df = getG1(n0,R,mua1,mus1,db1*1e-2,tau,850,rho,w,l,mua1,mus1,db1*1e-2, gl);
fun = @(x) calibrategetG1(x,asd,n0,R,mua1,mus1,db1*1e-2,tau,850,rho,w,l,mua1,mus1,db1*1e-2, gl);
x = fminsearch(fun,x0)

semilogx(tau, df.^2);hold on; semilogx(tau, 2*(asd-1));


