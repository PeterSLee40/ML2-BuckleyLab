close all
clear all
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\functions');
%ext='';
%time=[1 2 3 4 5 6 7];% 12 13];
%ratID = 'rat5';

plotfits=1;%If you want to display how well your fit compares to your raw g2 data
plotfigs=1;
fixbeta=0;%doesnt work yet in this code, must = 0
good_start = 2;

%Data directory
fdir = './';

id = '15';

OneLayerFit;

% SD distance
SD_dist = 15;%mm 
used_ch = 1;%Only looking at DCS data from detector 2

mua = 0.125;%cm-1
musp = 8;%cm-1
    
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



%PARAMETERS SPECIFIC TO THIS EXPERIMENT
%Define integration time (sec)
t=1;

% Convert to values in mm-1
mua = mua/10;
musp = musp/10;
%Initial guess for our g2 fit, [Db beta]
guess = [1e-7 0.5];
%Upper and lower bounds for fit [Db beta]
lb=[1e-10 0.3];
ub=[1e-3 0.55];
%Only fit g2 values above cutoff:
cutoff=1.05;  %default = 1.05
datalength=70;
%How many points to average in each curve for
%smoothing
avgnum=10;
cutoff_I=30;%kHz
cutoffCOV=20;%require COV to be less than cutoff
n0=1.33;%index of refraction for tissue
lambda=850*1e-6;%wavelength in mm
k0=2*pi*n0/lambda; %this is the k0 for flow!
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;


meanbeta=0.4;

temp = 50:-2:30;

%for temp_idx = 1:11;
    
    for II = 1:5
        
        maxfiles = 6;
        
        %Load DCS data 
        for i=1:maxfiles
            if exist([fdir id '_' num2str(II) '_flow_' num2str(i-1) '.dat'])~=0
                data=load([fdir id '_' num2str(II) '_flow_' num2str(i-1) '.dat']);
                corrset_intensity(i,:)=data(1,2:9);
                corrset(i,:,:)=data(2:end-1,2:9);%(file number x # taus x #dets)
            else
                corrset_intensity(i,:)=NaN;
                corrset(i,:,:)=NaN;
            end
        end
        clear data
        
        
        n_time_points = size( corrset,1);
        n_channels = size( corrset,2);
        
        tau = DelayTime(good_start:end);
        
        %Change g2 data to be 4x5x256 instead of
        %11x256x4, (4 detectors, 5 frames of g2 data, 272 time points for
        %g2)
        corr = permute(corrset(1:maxfiles,:,1:8),[3 1 2]);
        
        
        %For each data frame, smooth, average good dets and
        %fit for g2
        
        for i=1:size(corr,2)
            
            %End of g2 curve should fall to 1, if not, there is light
            %leakage or movement typically
            tail_avg=mean(corr(used_ch,i,115:125),3);
            
            if  tail_avg < 1.005 && tail_avg > 0.98 && corrset_intensity(i,used_ch) > cutoff_I
                
                signal(i,:)=squeeze(corr(used_ch,i,:));
                %Smooth g2 to determine where to fit
                signal_smooth=slidingavg(signal(i,good_start:end),avgnum);
                %Find where smoothed g2 > cutoff (defined above)
                foo = min(find(signal_smooth <= cutoff))+good_start;
                if isempty(foo) || foo < good_start
                    foo=70;%Fit first 70 points
                end
                %Fit non-smoothed g2 using cutoff
                foo;
                %obtained from smoothed g2
                corr2fit{i}=signal(i,good_start:foo);
                taustmp=DelayTime(good_start:foo);
                
                %FIT G2 FOR CBFi and BETA
                if fixbeta
                    beta(i)=mean([1.5*corr2fit{i}(1) corr2fit{i}(2) 0.5*corr2fit{i}(3)])-1;
                    Dbfit(i) = fminsearchbnd(@(x) dcs_g2_Db_GT(x(1),beta(i),taustmp,corr2fit{i},SD_dist,mua,musp,1),guess(1),lb(1),ub(1));
                else
                    %THIS IS WHERE THE FIT IS DONE, LOOK AT
                    %DCS_G2_DB_FMS_CANON.m CODE
                    %betaDbfit(II,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{II}.',SD_dist(d),mua,musp,1,k0),guess,lb,ub);
                    betaDbfit(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{i},SD_dist,mua,musp,1,k0,R),guess,lb,ub);
                    Dbfit(i)=betaDbfit(i,1);
                    beta(i)=betaDbfit(i,2);
                end
                %Get fit g2 to test fit
                %Curvefitg2avg(II,d,:)=dcs_g2fit_GT([DbFit(II,d) beta(II,d)],taus,SD_dist(d),mua,musp,k0,1);
                Curvefitg2avg(i,:)=dcs_g2fit_GT([Dbfit(i) beta(i)],DelayTime,SD_dist,mua,musp,k0,R,1);
                CurveNet(i,:)=dcs_g2fit_GT([net1([beta(i) corrset(i,2:70,1) ]')*1e-6 beta(i)],DelayTime,SD_dist,mua,musp,k0,R,1);
                CurveEn(i,:)=dcs_g2fit_GT([ensemble.predict([beta(i) corrset(i,2:70,1) ])*1e-6 beta(i)],DelayTime,SD_dist,mua,musp,k0,R,1);
            else
                beta(i)=NaN;
                Dbfit(i)=NaN;
                Curvefitg2avg(i,:)=NaN(1,length(DelayTime));
                signal(i,:) = NaN(size(DelayTime));
                corr2fit{i} = NaN(size(tau));
            end
        end
        
        if maxfiles>5
            %First data point has weird drop in coherence so remove
            Dbfit(1)=NaN;
        end
        
        %Remove outliers across the 5 frames of data (any data that fall
        %outside of +/-- 1.5 standard deviations of the mean
        ind_outs=find( Dbfit > nanmean(Dbfit)+1.5*nanstd(Dbfit) | Dbfit < nanmean(Dbfit)-1.5*nanstd(Dbfit) );
        
        if plotfits
            %Check fits for det 2
            figure('Position',[1          61        1150       644]);
            for K=1:5
                if maxfiles <5
                    I=K;
                else
                    I=K+1;
                end
                subplot(2,3,K);
                semilogx(DelayTime,signal(I,:),'k-','LineWidth',1);
                hold on, semilogx(DelayTime,squeeze(Curvefitg2avg(I,:)),'k--','LineWidth',2);
                hold on, semilogx(DelayTime,CurveNet(I,:),'k*','LineWidth',1);
                hold on, semilogx(DelayTime,CurveEn(I,:),'ko','LineWidth',1);
                axis([2.25e-7 1e-2 0.95 1.6]);
            end
            subplot(2,3,6)
            plot(1:1:length(Dbfit),Dbfit,'.-','LineWidth',2,'MarkerSize',15);
            if ~isempty(ind_outs)
                hold on,plot(ind_outs,Dbfit(ind_outs),'ko','LineWidth',2,'MarkerSize',12)
            end
            grid on
            xlim([0.5 5.5])
            ylim([0 1e-5])
            xlabel('Frame')
            ylabel('CBFI')
            title(['Var = ' num2str(nanstd(Dbfit)./nanmean(Dbfit)*100,'%6.1f') ' %'])
            %maxwindows(gcf)
            set(gcf,'PaperPositionMode','Auto')
%            saveas(gcf,[ fdir 'savedfigs/' id '_' num2str(II) '.jpg'],'jpg')
            pause(1.0);
        end
        
        if ~isempty(ind_outs)
            if length(ind_outs)==1
                Dbfit(ind_outs)=NaN;
            else
                Dbfit(:)=NaN;
            end
        end
        %If variation across 5 frames is > 20%, throw out data set
        if nanstd(Dbfit)./nanmean(Dbfit) > cutoffCOV/100 || length(find(isnan(Dbfit)))>2
            Dbfit(:)=NaN;
            throwout=1;
        end
        
        
        mean_fit(II) = nanmean(Dbfit)*1e6; % unit 10^-8 cm2/s
        beta_fit(II) = nanmean(beta);
        stdev_fit(II) = nanstd(Dbfit);
        stdev_beta_fit(II) = nanstd(Dbfit);
        
        if II < 3 
        clear beta Dbfit Curvefitg2avg signal_alldets signal corr2fit sigma corrset corrset_intensity corrset_times
        end 
        %close all
        
        
        
    end

    
figure, semilogx(DelayTime,signal(5,:),'k-','LineWidth',1);
hold on, semilogx(DelayTime,squeeze(Curvefitg2avg(5,:)),'k--','LineWidth',2);
axis([4e-7 1e-2 0.95 1.6]);
%end     
%save repfit_38c15mm_cut1.005.mat DelayTime signal Curvefitg2avg