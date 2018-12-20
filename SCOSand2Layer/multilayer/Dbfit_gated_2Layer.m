close all
clear all

addpath('F:\2-Layer Neural Net\functions');
hr = 60;%Heart rate (bpm)
Fs = 50;%Hz
minDb = 0.5;%1e-6 mm2/s
maxDb = 1.25;%1e-6 mm2/s

maxT = 1;%min
dt = 1/Fs;
t = 0:dt:maxT*60-dt;%s

Db = (0.875+(maxDb-minDb)/2*sawtooth(2*pi*hr/60*t))*1e-6;

figure,plot(t,Db*1e6,'.-','MarkerSize',10)
xlim([0 10])
ylim([0.4 1.35])
grid on
xlabel('Time (s)')
ylabel('Simulated Db')

intensity = [10]*1e3;
r = 20;%mm
mua = 0.1;%cm-1
musp = 10;%cm-1
% Convert to values in mm-1
mua = mua/10;
musp = musp/10;
n0=1.4;%index of refraction for tissue
lambda=852*1e-6;%wavelength in mm
%Initial guess for our g2 fit, [Db beta]
guess = [1e-7 0.5];
good_start = 1;

%Upper and lower bounds for fit [Db beta]
lb=[1e-10 0.3];
ub=[1e-3 0.55];
%Only fit g2 values above cutoff:
cutoff=1.05;
datalength=130;
bin_width = 1e-6;
%How many points to average in each curve for
%smoothing
avgnum=10;
cutoff_I=25;%kHz
cutoffCOV=20;%require COV to be less than cutoff
cutoffBeta = 0.4;
k0=2*pi*n0/lambda; %this is the k0 for flow!
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;

%Define time points, tau, for g2 curves, FIXED TAU IN LABVIEW in Aug 2015!!!!  From sample.cpp code from jixiang to my gmail  on 3/18/15
 DelayTime=[1e-6:bin_width:bin_width*datalength];
% %{
% for I=1:16
%     DelayTime(I) = I*first_delay;
% end
% 
% for J=1:30
%     for I=0:7
%         DelayTime(I+(J-1)*8+17) = DelayTime((J-1)*8+16+I)+first_delay*(2^J);
%     end
% end

DelayTime=DelayTime(1:datalength);
%}
%Determine bin width for each tau
T=ones(size(DelayTime))*bin_width;


for j = 1:length(intensity)
    %Generate g2 at each Db
    for i=1:length(Db)
        g1 = diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,mus2,aDb2)
        g2(j,i,:) =g2twolayermodel(g1,beta);
        
        difference=abs(g2(j,i,:)-(1+0.5/exp(1)));
        ind=find(difference==min(difference));
        if ~isempty(ind)
            gamma(i)=1/DelayTime(min(ind));%use min(ind) in case ind is not a 1x1 vector.
        end
        sigma(j,i,:)=1./intensity(j).*sqrt(1./T./(1/Fs)).*sqrt(1+0.5.*exp(-gamma(i)*DelayTime));
        noise(j,i,:) = squeeze(sigma(j,i,:)).*randn(length(DelayTime),1);
        
        clear ind difference
    end
    
    g2_withnoise(j,:,:) = g2(j,:,:) + noise(j,:,:);
    %{
figure,semilogx(DelayTime,g2(1,:),'k-')
hold on,semilogx(DelayTime,g2_withnoise(1,:),'b')
xlim([0 1e-2])
ylim([0.9 1.6])
legend('True','Add noise')
    %}
end

j=1;

for i=1:length(Db)
    signal(i,:)=squeeze(g2_withnoise(j,i,:));
    %Smooth g2 to determine where to fit
    signal_smooth=slidingavg(signal(i,good_start:end),avgnum);
    %Find where smoothed g2 > cutoff (defined above)
    foo = min(find(signal_smooth <= cutoff))+good_start-1;
    if isempty(foo) || foo < good_start
        foo=70;%Fit first 70 points
    end
    %Fit non-smoothed g2 using cutoff
    %obtained from smoothed g2
    corr2fit{i}=squeeze(signal(i,good_start:foo));
    taustmp=DelayTime(good_start:foo);

    %FIT G2 FOR CBFi and BETA
    betaDbfit(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{i},r,mua,musp,1,k0,R),guess,lb,ub);
    Dbfit(i)=betaDbfit(i,1);
    betafit(i)=betaDbfit(i,2);
    %Get fit g2 to test fit
    Curvefitg2avg(i,:)=dcs_g2fit_GT([Dbfit(i) betafit(i)],DelayTime,r,mua,musp,k0,R,1);
    clear corr2fit
end
clear corr2fit

%Compare average over 3s vs. downsampling to 1Hz and averaging 3 points
inttime = 3;%s
block_for_avg = 3*Fs;
total_curves = floor(max(t)/inttime);
tmp = 0;
for i=1:total_curves
    t_block(i) = t(tmp+1);
    signal(i,:)=squeeze(mean(g2_withnoise(j,tmp+1:tmp+block_for_avg,:),2));
    %Smooth g2 to determine where to fit
    signal_smooth=slidingavg(signal(i,good_start:end),avgnum);
    %Find where smoothed g2 > cutoff (defined above)
    foo = min(find(signal_smooth <= cutoff))+good_start;
    if isempty(foo) || foo < good_start
        foo=70;%Fit first 70 points
    end
    %Fit non-smoothed g2 using cutoff
    %obtained from smoothed g2
    corr2fit{i}=squeeze(signal(i,good_start:foo));
    taustmp=DelayTime(good_start:foo);
    %FIT G2 FOR CBFi and BETA
    betaDbfit(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{i},r,mua,musp,1,k0,R),guess,lb,ub);
    Dbfit_avg(i)=betaDbfit(i,1);
    betafit_avg(i)=betaDbfit(i,2);
    %Get fit g2 to test fit
    Curvefitg2avg(i,:)=dcs_g2fit_GT([Dbfit_avg(i) betafit_avg(i)],DelayTime,r,mua,musp,k0,R,1);
    tmp = tmp+block_for_avg;
end
clear corr2fit

start_pt = hr/60*Fs/2;
pts_per_beat = hr/60*Fs;
for i=1:floor(length(Db)/Fs)
    downsample_g2(j,i,:) = squeeze(mean(g2_withnoise(j,start_pt+(i-1)*Fs-4:start_pt+(i-1)*Fs+4,:),2));
end
%downsample_g2(j,:,:) = squeeze(g2_withnoise(j,start_pt:Fs:length(Db),:));
downsample_t = t(start_pt:Fs:length(Db)-start_pt-1);

for i=2:size(downsample_g2,2)-1
    signal(i,:)=squeeze(mean(downsample_g2(j,i-1:i+1,:),2));
    %Smooth g2 to determine where to fit
    signal_smooth=slidingavg(signal(i,good_start:end),avgnum);
    %Find where smoothed g2 > cutoff (defined above)
    foo = min(find(signal_smooth <= cutoff))+good_start;
    if isempty(foo) || foo < good_start
        foo=70;%Fit first 70 points
    end
    %Fit non-smoothed g2 using cutoff
    %obtained from smoothed g2
    corr2fit{i}=squeeze(signal(i,good_start:foo));
    taustmp=DelayTime(good_start:foo);

    %FIT G2 FOR CBFi and BETA
    betaDbfit(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{i},r,mua,musp,1,k0,R),guess,lb,ub);
    Dbfit_ds(i)=betaDbfit(i,1);
    betafit_ds(i)=betaDbfit(i,2);
    %Get fit g2 to test fit
    Curvefitg2avg(i,:)=dcs_g2fit_GT([Dbfit_ds(i) betafit_ds(i)],DelayTime,r,mua,musp,k0,R,1);
    clear corr2fit
end
clear corr2fit

figure,plot(t,Db*1e6,'k.-','MarkerSize',10)
hold on,plot(t,Dbfit*1e6,'.-','MarkerSize',10,'Color',[0 0.5 0])
hold on,plot(t_block,Dbfit_avg*1e6,'b.-','MarkerSize',10)
hold on,plot(downsample_t,Dbfit_ds*1e6,'r.-','MarkerSize',10)
legend('Expected','each frame','3s avg','triggered')
xlim([0 60])
ylim([0 2])
title('50Hz')
grid on
xlabel('Time (s)')
ylabel('Db')

