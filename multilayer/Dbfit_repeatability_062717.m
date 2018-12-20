%Red = 5HD rCHI (hit on M - F)
%Green = 3HD rCHI (hit on W - F)
%Blue = 1 CHI (hit on F)
%Black = Sham 
%All mice measured on Monday (time 1) as baseline.  Then measuring all mice
%again on Friday 4 hours after their final hit/sham injury

close all
clear all

ext='';
%time=[1 2 ];
time=[1 ];

plotfits=0;%If you want to display how well your fit compares to your raw g2 data
plotfigs=0;
fixbeta=0;%doesnt work yet in this code, must = 0
good_start = 2;

%Data directory
fdir = '/Users/erinbuckley/data/MiceCHIstudy/';
% SD distance
SD_dist = 6;%mm 
used_ch = 2;%Only looking at DCS data from detector 2
    
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
mua = 0.1;%cm-1
musp = 4.1;%cm-1
% Convert to values in mm-1
mua = mua/10;
musp = musp/10;
%Initial guess for our g2 fit, [Db beta]
guess = [1e-7 0.5];
%Upper and lower bounds for fit [Db beta]
lb=[1e-10 0.3];
ub=[1e-3 0.55];
%Only fit g2 values above cutoff:
cutoff=1.05;
datalength=70;
%How many points to average in each curve for
%smoothing
avgnum=10;
cutoff_I=25;%kHz
cutoffCOV=20;%require COV to be less than cutoff
n0=1.4;%index of refraction for tissue
lambda=852*1e-6;%wavelength in mm
k0=2*pi*n0/lambda; %this is the k0 for flow!
R=-1.440./n0^2+0.710/n0+0.668+0.0636.*n0;


meanbeta=0.4;

%Look at each measurent time point
for d=1:length(time)
    %Find all data at this time point
    file_list = dir([ fdir 'day_' num2str(time(d)) '/*_flow_0.dat']);
    num_files=length(file_list);
    meas_number = 1;
    %Pre-allocate vars
    ID{d}=zeros(1,num_files);
    side{d}=zeros(1,num_files);
    repnum{d}=zeros(1,num_files);
    user{d}=zeros(1,num_files);
    state{d} = zeros(1,num_files);
    %For each file of data taken at this time point
    for II=1:num_files
        throwout=0;
        %Find what rat was measured by looking between underscores
        ind=strfind([file_list(II).name],'_');
        indend=strfind([file_list(II).name],'.');
        %Determine sham or injured and ID number, change to a numeric ID
        %number for ease of coding (< 100 = injured, > 100 = sham)
        if ~isempty(strfind([file_list(II).name],'black'))
            %3rCHI = green, change numbers to 11-16
            ID{d}(II)=10+str2num(file_list(II).name(6:ind(1)-1));
        elseif ~isempty(strfind([file_list(II).name],'red'))
            ID{d}(II)=10+str2num(file_list(II).name(4:ind(1)-1));
        end
        
        ind2 = strfind([ mouseID{i}(ind(1):ind(2)) ],'b');
        ind1 = strfind([ mouseID{i}(ind(1):ind(2)) ],'p');

        if ~isempty(ind2)
            user{d}(II) = 1;%bharat
        elseif ~isempty(ind1)
            user{d}(II) = 2;%paul
        else
            user{d}(II) = 3;%erin
        end
        
        %Find which side of the head by looking after 2nd underscore
        if ~isempty(strfind([file_list(II).name(ind(3):ind(4))],'r'))
            side{d}(II)=1;%1=right
        elseif ~isempty(strfind([file_list(II).name(ind(3):ind(4))],'l'))
            side{d}(II)=2;%2=left
        end
        
        %Find rep num
        repnum{d}(II)=str2num(file_list(II).name(ind(3)+2));
        
        state{d}(II)=str2num(file_list(II).name(ind(2)+1));
        
        
        %Find date of measurement
        filetime{d}(II)=file_list(II).datenum;
    
        clear ind indend
        
        %Load DCS data MODIFY!!!
        for i=1:6
            if exist([fdir 'day_' num2str(time(d)) '/' file_list(II).name(1:end-5) num2str(i-1) '.dat'])~=0
                data=load([fdir 'day_' num2str(time(d)) '/' file_list(II).name(1:end-5) num2str(i-1) '.dat']);
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
        corr = permute(corrset(1:6,:,1:8),[3 1 2]);
        
        
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
                %obtained from smoothed g2
                corr2fit{i}=signal(i,good_start:foo);
                taustmp=DelayTime(good_start:foo);
                
                %FIT G2 FOR CBFi and BETA
                if fixbeta
                    beta(i)=mean([1.5*corr2fit{i}(1) corr2fit{i}(2) 0.5*corr2fit{i}(3)])-1;
                    % EASHANI - USE THIS LINE IN CODE TO FIT YOUR DATA
                    % corr2fit{i} = measured g2 data
                    % mua, musp, k0 and R are defined above.  You can
                    % change the values to match your similtion
                    % Since you are fitting g1, not g2, you will need to
                    % tweak to not include the beta portion of this
                    % function
                    Dbfit(i) = fminsearchbnd(@(x) dcs_g2_Db_GT(x(1),beta(i),taustmp,corr2fit{i},SD_dist,mua,musp,1,k0,R),guess(1),lb(1),ub(1));
                else
                    
                    betaDbfit(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{i},SD_dist,mua,musp,1,k0,R),guess,lb,ub);
                    Dbfit(i)=betaDbfit(i,1);
                    beta(i)=betaDbfit(i,2);
                end
                %Get fit g2 to test fit
                %Curvefitg2avg(II,d,:)=dcs_g2fit_GT([DbFit(II,d) beta(II,d)],taus,SD_dist(d),mua,musp,k0,1);
                Curvefitg2avg(i,:)=dcs_g2fit_GT([Dbfit(i) beta(i)],DelayTime,SD_dist,mua,musp,k0,R,1);
            else
                beta(i)=NaN;
                Dbfit(i)=NaN;
                Curvefitg2avg(i,:)=NaN(1,length(DelayTime));
                signal(i,:) = NaN(size(DelayTime));
                corr2fit{i} = NaN(size(tau));
            end
        end
        
        %First data point has weird drop in coherence so remove
        Dbfit(1)=NaN;
        
        %Remove outliers across the 5 frames of data (any data that fall
        %outside of +/-- 1.5 standard deviations of the mean
        ind_outs=find( Dbfit > nanmean(Dbfit)+1.5*nanstd(Dbfit) | Dbfit < nanmean(Dbfit)-1.5*nanstd(Dbfit) );
        
        if plotfits
            %Check fits for det 2
            figure('Position',[1          61        1150       644]);
            for I=1:5
                subplot(2,3,I);
                semilogx(DelayTime,signal(I,:),'k-','LineWidth',1);
                hold on, semilogx(DelayTime,squeeze(Curvefitg2avg(I,:)),'k--','LineWidth',2);
                axis([2.25e-7 1e-2 0.95 1.6]);
            end
            subplot(2,3,6)
            plot(1:1:length(Dbfit),Dbfit,'.-','LineWidth',2,'MarkerSize',15);
            if ~isempty(ind_outs)
                hold on,plot(ind_outs,Dbfit(ind_outs),'ko','LineWidth',2,'MarkerSize',12)
            end
            grid on
            xlim([0.5 5.5])
            ylim([0 1e-4])
            xlabel('Frame')
            ylabel('CBFI')
            title(['Var = ' num2str(nanstd(Dbfit)./nanmean(Dbfit)*100,'%6.1f') ' %'])
            %maxwindows(gcf)
            set(gcf,'PaperPositionMode','Auto')
            saveas(gcf,[ fdir 'mice3hit_Levi_' num2str(time(d)) '/savedfigs/' file_list(II).name(1:end-4) ext '.jpg'],'jpg')
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
        
        
        clear signal_smooth taustmp index_ch ind_outs
        
        % Stats
        timept{II} = file_list(II).name;
        mean_fit{d}(II) = nanmean(Dbfit);
        beta_fit{d}(II) = nanmean(beta);
        stdev_fit{d}(II) = nanstd(Dbfit);
        stdev_beta_fit{d}(II) = nanstd(Dbfit);
        range_fit{d}(II) = (nanmax(Dbfit) - nanmin(Dbfit)) / nanmean(Dbfit)*100;
        variation_coeff{d}(II) = stdev_fit{d}(II) / mean_fit{d}(II);
        %EB edits - Kept pts = # of data frames
        %where data passed
        kepttpts{d}(II) = sum(~isnan(Dbfit));
        
        
        clear beta Dbfit Curvefitg2avg signal_alldets signal corr2fit sigma corrset corrset_intensity corrset_times
        
        close all
    end
    %save data from this time point
    save([ 'repeatability_timept' num2str(time(d)) ext '_allBFIdata.mat'],'timept','mean_fit','stdev_fit','ID','repnum','side','user','filetime')
end

%Reshape data to organize by time point and location
%All mice measured on first day, so get id's from that
ids=unique(ID{1});
%Also figure out which "batch" they came  from (i.e., group all mice who
%were hit on a certain day together)
times=datevec(filetime{1});
datemeas=unique(times(:,2:3),'rows');
total_batches=size(datemeas,1);

for i=1:length(ids)
    for d=1:length(time)
        for a = 1:2 %awake/anesth
            for j=1:3 %3 users
                for s=1:2 %right/left
                    ind=find(ID{d}==ids(i) & state{d}==a & user{d} == j & side{d} ==s);
                    bfi(i,d,a,j,s) = nanmean(mean_fit{d}(ind));
                    bfistd(i,d,a,j,s)=bfi(i,d,a,j,s).*sqrt(nansum((stdev_fit{d}(ind)./mean_fit{d}(ind)).^2));
                    if bfistd(i,d,a,j,s)./bfi(i,d,a,j,s) > cutoffCOV/100
                        bfi(i,d,a,j,s)=NaN;
                    end
                    clear ind
                end
           end
        end
    end
end
save([ 'repeatability' ext '_allBFIdata.mat'],'ids','bfi','bfistd','time')


for d=1:length(time)
    for a = 1:2
        figure('Position',[ 59         715        1028         270]),
        subplot(1,3,1)
        plot(squeeze(bfi(:,d,a,1,:)),squeeze(bfi(:,d,a,2,:)),'.','MarkerSize',30)
        for s = 1:2
            [R,p] = corrcoef(squeeze(bfi(:,d,a,1,s)),squeeze(bfi(:,d,a,2,s)));
            R_tmp(s) = R(2);
            p_tmp(s) = p(2);
            text(1,1,[ 'Side ' num2str(s) ', R = ' num2str(R(2)) ', p = ' num2str(p(2)) ])
        end
        grid on
        title(['Bharat vs. Paul'])
        
        hold on,plot([1 2.2],[1 2.2],'k--')
        xlim([1 2.2])
        ylim([1 2.2])
        subplot(1,3,2)
        plot(squeeze(cbf(:,1,:)),squeeze(cbf(:,3,:)),'.','MarkerSize',30)
        grid on
        hold on,plot([1 2.2],[1 2.2],'k--')
        xlim([1 2.2])
        ylim([1 2.2])
        title('Bharat vs. Erin')
        subplot(1,3,3)
        plot(squeeze(cbf(:,3,:)),squeeze(cbf(:,2,:)),'.','MarkerSize',30)
        grid on
        title('Erin vs. Paul')
        hold on,plot([1 2.2],[1 2.2],'k--')
        xlim([1 2.2])
        ylim([1 2.2])
        legend('Right','Left')
    end
    subplot_title_high(['Day ' num2str(d) ])
end

for d=1:length(time)
    for a = 1:2
        for s = 1:2
        figure('Position',[ 59         715        1028         270]),
        subplot(1,3,1)
        x = nanmean(squeeze(bfi(:,d,a,1,s)),squeeze(bfi(:,d,a,2,s)));
        y = squeeze(bfi(:,d,a,1,s))-squeeze(bfi(:,d,a,2,s));
        plot(x,y,'.','MarkerSize',30)
        xlims = get(gca,'XLim');
        hold on,plot(xlims,[nanmean(y) nanmean(y)],'k-')
        hold on,plot(xlims,[nanmean(y)+1.96*nanstd(y) nanmean(y)+1.96*nanstd(y)],'k--')
        hold on,plot(xlims,[nanmean(y)-1.96*nanstd(y) nanmean(y)-1.96*nanstd(y)],'k--')
        grid on
        title(['Bharat vs. Paul'])
        
        hold on,plot([1 2.2],[1 2.2],'k--')
        xlim([1 2.2])
        ylim([1 2.2])
        subplot(1,3,2)
        plot(squeeze(cbf(:,1,:)),squeeze(cbf(:,3,:)),'.','MarkerSize',30)
        grid on
        hold on,plot([1 2.2],[1 2.2],'k--')
        xlim([1 2.2])
        ylim([1 2.2])
        title('Bharat vs. Erin')
        subplot(1,3,3)
        plot(squeeze(cbf(:,3,:)),squeeze(cbf(:,2,:)),'.','MarkerSize',30)
        grid on
        title('Erin vs. Paul')
        hold on,plot([1 2.2],[1 2.2],'k--')
        xlim([1 2.2])
        ylim([1 2.2])
        legend('Right','Left')
    end
    subplot_title_high(['Day ' num2str(d) ])
    end
end