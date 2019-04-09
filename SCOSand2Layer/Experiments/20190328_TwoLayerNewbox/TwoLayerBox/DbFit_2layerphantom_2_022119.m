%Dbfit code template- EB 6/26/09
%see labnote book on why I chose some of these parameters

clear all
close all

plotfit = 1;

patID='2layer';
patdate='022119';
%Extension you want added to patID, if nothing, just use ext='';
exten='_1';

fdir = [ ];

usedflowdets=[5 6 7 8];%must be consecutive, cannot be ex. 1,3,4 or 2,4.  must change code if this is the case
SD_dist=[10 15 20 25];%mm
collectedo2=0;%Was oxygenation data collected in this study?  If so, will use changes in mua in our Dbfit

n0=1.33;%index of refraction for tissue
nout=1;%index of refraction for air
n=n0./nout;
c=2.99792458e11; %speed of light in vacuum,mm/s
vo=c/n0; %speed of light in medium
lambdaDCS=852;%wavelength in nm
R=-1.440./n^2+0.710/n+0.668+0.0636.*n;%Durduran RPP 2010
ze=2./3.*(1+R)./(1-R); %check this number, no need for 1/musp as Cecil takes ca\re of it in the files
muao=0.145/10;%mm-1
muspo=6.85/10;%mm-1
D=vo./(3.0.*muspo); %background diffusion coeff
k0=2*pi*n0/(lambdaDCS*1e-6); %this is the k0 for flow in mm-1



%%%% FITTING SETTINGS:
fitbeta=1; %=0 do not fit beta,use 1st 3 points, ==1 fit beta, ==2 use set beta, DO NOT RECOMMEND FITTING BETA UNLESS INTENSITY > 20kHz
betafitmin=0.3;
betafitmax=0.55;
op=optimset('fminsearch');
options=optimset(op,'MaxIter',300000,'MaxFunEvals',300000,'TolFun',1.000e-16,'TolX',1.000e-16,'Display','Final');
avgnum=10;%How many points to average in each curve before fitting
cutoff=1.15;%where to cut correlation curve off when fitting
setbeta=0.45; %used when calculating sigma
x0=[1e-8 setbeta];%Initial guess for Db and beta
startcorr=2;
cutoffintensity=8;%kHz
%Upper and lower bounds for fit [Db beta]
guess=[1e-8 setbeta];%Initial guess for Db and beta
lb=[1e-12 betafitmin];
ub=[1e-3 betafitmax];

%Find all data in this fold
% file_list = dir([ fdir  '*trail*flow*.dat']);
file_list = dir([ fdir  'TwoLayer_4_flow_*.dat']);
num_files=length(file_list);
meas_number = 1;

%Sort all files by time
for i=1:num_files
    a(i) = file_list(i).datenum;
end
[b,idx]=sort(a);

%Load all DCS data to start
for II=1:length(idx)
    
    if isempty(strfind([file_list(idx(II)).name],'FIT'))
        throwout=0;
        %LOAD DCS DATA
        fname1=([fdir file_list(idx(II)).name]);
        
        %Find time of frame:
        fid = fopen([ fname1 ], 'r');
        [tmpdata, count]=fscanf(fid,'%c %s',3);
        clear tmpdata
        [tmpdata, count]=fscanf(fid,'%c %s',2);
        time{II}=tmpdata;
        fclose(fid);
        
        %Load correlator data
        data=load(fname1);
        intensitydata(II,:)=data(1,2:9);
        corrs(II,:,:)=data(2:end-1,2:9);
        taus=data(2:end-1,1);
        %Record marks
        if data(end,1)>0
            %Marksflow(data(end,1))=measnum+1;
            Marksflow(II)=data(end,1);
        end
        
        %Get integration time (sec)
        t=data(1,1)/1000;
        
        clear data
        
        %Reshape corrs to (frame # x # dets x # taus)
        corr(II,:,:)=permute(corrs(II,:,:),[1,3,2]);
        
    else
        continue
    end
end
    
%Calculate time points corresponding to each data file
timeaxis_flow=datenum(time,'HH:MM:SS')-floor(datenum(time,'HH:MM:SS'));%In arbitrary units--1a.u.=24hrs, counting from 1/1/2000.
%Data in DCS files is not in military time, so add 12 hours to all data if
%need be
if timeaxis_flow(1)<0.5
    timeaxis_flow=timeaxis_flow+0.5;
end
%Unwrap time vector
for i=1:length(timeaxis_flow)-1
    if abs(timeaxis_flow(i+1)-timeaxis_flow(i))>0.4
        timeaxis_flow(i+1)=timeaxis_flow(i+1)+0.5;
    end
end
%Zero time axis so that t=0 is first flow curve
%timeaxis_flow=(timeaxis_flow-timeaxis_flow(1))*1.44e3;%Convert time to minutes
timeaxis_flow=(timeaxis_flow)*1.44e3;%Convert time to minutes

%Load NIRS data and use for mua in Db fit
figure,plot(timeaxis_flow)

if collectedo2
    load([ patID '_' patdate exten '_dpfout.mat'])
    %Set t=0 to the sync mark
    Markstmp = find(Marksflow);
    timeaxis_flow=timeaxis_flow-timeaxis_flow(Markstmp(syncmark_DCS));

    load lambda.mat
    [eHBO2,eHB,Muawater,mualipid]=getextinctioncoef_new(0,0,lambdaDCS);
    extDCS=[ eHBO2.*log(10) eHB.*log(10)];
    muaDCS=(cat(1,hbo2series,hbseries).'*extDCS.').';%cm-1
    
    mua = muao + interp1(ISStime,muaDCS,timeaxis_flow)/10;%mm-1
    musp = muspo*ones(size(idx));
    hold on,plot(ISStime)

else
    %Set t=0 to the first frame
    timeaxis_flow=timeaxis_flow-timeaxis_flow(1);

    mua = muao*ones(size(idx));
    musp = muspo*ones(size(idx));
end

% legend('DCS time','ISStime')


for II=1:size(corr,1)
    
       
    for det=1:length(usedflowdets)
        
        d=det;
        %Now average all detectors for this separation and make sure that
        %average data is good
        corravg(II,d,:)=nanmean(corr(II,usedflowdets(d),:),2);
        tail_avg=nanmean(corravg(II,d,115:125),3);
        
        if  tail_avg < 1.005 && tail_avg > 0.98 && nanmean(intensitydata(II,usedflowdets(d)),2) > cutoffintensity && ~isnan(mua(II))
            
            %Smooth g2 to determine where to
            %fit
            signal_smooth=slidingavg(squeeze(corravg(II,d,startcorr:end)),avgnum);
            %Find where smoothed g2 > cutoff (defined above)
            foo = min(find(signal_smooth <= cutoff))+startcorr;
            if isempty(foo) || foo < startcorr
                foo=70;%Fit first 70 points
            end
            %Fit non-smoothed g2 using cutoff
            %obtained from smoothed g2
            corr2fit{II}=squeeze(corravg(II,d,startcorr:foo)).';
            taustmp=taus(startcorr:foo);
            
            %Calculate noise from Chao's noise model
            if fitbeta==1
                %Calculate noise from Chao's noise model
                %sigma{i}=1./nanmean( corrset_intensity(i,d)).*sqrt(1./T(startcorr:foo)./t).*sqrt(1+meanbeta.*exp(-gamma*taustmp));
                %betaDbfit(i,:) = fminsearchbnd(@(x) dcs_g2_Db_fms_weighted_Canon(x,taustmp,corr2fit{i},SD_dist(d),mua,musp,1,sigma{i}),guess,lb,ub);
                [betaDbfit(II,:),fval(II,det),exitflag(II,det)] = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{II}.',SD_dist(det),mua(II),musp(II),1,k0,R),guess,lb,ub);
                Dbfit(II,det)=betaDbfit(II,1);
                beta(II,det)=betaDbfit(II,2);
            elseif fitbeta==2
                beta(II,det)=setbeta;
                %sigma{i}=1./nanmean( corrset_intensity(i,d)).*sqrt(1./T(startcorr:foo)./t).*sqrt(1+beta(i).*exp(-gamma*taustmp));
                [Dbfit(II,det),fval(II,det),exitflag(II,det)] = fminsearchbnd(@(x) dcs_g2_Db_GT([x(1) beta(II,det)],taustmp,corr2fit{II}.',SD_dist(det),mua(II),musp(II),1,k0,R),guess(1),lb(1),ub(1));
            else
                beta(II,det)=mean([1.5*corr2fit{II}(1) corr2fit{II}(2) 0.5*corr2fit{II}(3)])-1;
                %sigma{i}=1./nanmean( corrset_intensity(i,d)).*sqrt(1./T(startcorr:foo)./t).*sqrt(1+beta(i).*exp(-gamma*taustmp));
                [Dbfit(II,det),fval(II,det),exitflag(II,det)] = fminsearchbnd(@(x) dcs_g2_Db_GT([x(1) beta(II,det)],taustmp,corr2fit{II}.',SD_dist(det),mua(II),musp(II),1,k0,R),guess(1),lb(1),ub(1));
            end
            %Get fit g2 to test fit
            Curvefitg2avg(II,det,:)=dcs_g2fit_GT([Dbfit(II,det) beta(II,det)],taus,SD_dist(det),mua(II),musp(II),k0,R,1);
            %Calculate error in fit
            indtmp(II,det)=min(find(abs(squeeze(Curvefitg2avg(II,det,:))-0.3)==min(abs(squeeze(Curvefitg2avg(II,det,:))-0.3))));%Use min in case size(ind)>1
            errorfit(II,det,:)=(squeeze(corr(II,det,:))-squeeze(Curvefitg2avg(II,det,:)))./squeeze(Curvefitg2avg(II,det,:))*100;
            meanerror(II,det)=nanmean(errorfit(II,det,1:indtmp(II,det)));
            stderror(II,det)=nanstd(errorfit(II,det,1:indtmp(II,det)));
        else
            indtmp(II,det)=NaN;
            errorfit(II,det,:)=ones(size(taus)).*NaN;
            meanerror(II,det)=NaN;
            stderror(II,det)=NaN;
            fval(II,det)=NaN;
            exitflag(II,det)=NaN;
            beta(II,det)=NaN;
            Dbfit(II,det)=NaN;
            corravg(II,det,:)=NaN(1,length(taus));
            Curvefitg2avg(II,det,:)=NaN(1,length(taus));
            corr2fit{II} = NaN(size(taus));
            
        end
        
        
    end
    
end

nanmean(Dbfit) 

for d = 1:length(usedflowdets)
    meang2(d,:) = nanmean(corr(:,usedflowdets(d),:),1);
end
figure,semilogx(taus,meang2)
hold on
%semilogx(taus,Curvefitg2avg(1,:,:),'k--','LineWidth',2)
legend('10mm', '15mm', '20mm','25mm')
xlabel('Tau');
ylabel('g2')
ylim([0.9 1.6])
xlim([min(taus) 1e-2])
save('meandata.mat','meang2','taus')