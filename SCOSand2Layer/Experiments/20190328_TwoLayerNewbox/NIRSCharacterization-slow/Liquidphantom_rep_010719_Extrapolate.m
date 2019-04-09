close all
clear all

addpath('../../../functions');
%blockname='Calibration';
fdir = './';

figure_size = [200 200 800 500];

%load lambda.mat
lambda = [730 690 750 775 785 800 825 830];
%lambda_idx = 1:8;
lambda_idx = [1 2 3 5 6 8];

load colors.mat

%Kid
numreps = 10;
startrep = 1;

rep_range = startrep:numreps;
%removed 1 2 9 10 - bad data, outliers and balues non-linear
rep_range = [3 4 5 6 7 8 9 10];

r = [1.5 2.0 2.5 3.0];

ind2 = [1 2 3 4];

usedlambda_ind= 1:1:8;
%usedlambda_ind= [3 5 6 8];

% musset = 'l1'; % l l2_
% 
% muastep = '1'; % 1,2,3,4

exp = '1';

n0=1.38;%index of refraction for phantom
c=2.99792458e10; %speed of light in vacuum,cm/s
v=c/n0; %speed of light in medium
w=2*pi*110e6;%RF modulation frequency ISS uses 110MHz

for i= rep_range
    
    %LOAD DATA
    fname = [ 'slow_' num2str(i) '.txt'];
    fid = fopen([ fname ], 'r');
    for j=1:131
        tline=fgetl(fid);
    end
    [tmpdata, count]=fscanf(fid,'%g %g',[34 inf]);
    fclose(fid);
    tmpdata=tmpdata.';
    
    %Get AC and phase data for each and wavelength
    %ACtmp=tmpdata(:,6:13);
    %phtmp=tmpdata(:,38:45);%degrees
    
    %Marks=find(tmpdata(:,4));
    
    Marks=find(tmpdata(:,4)~=0);

    %Mark = [1 Marks(1) Marks(2) Marks(3)];

    % Average data between marks
    for m=1:length(Marks)/2
        AC(m,:)=mean(tmpdata(Marks(2*m-1):Marks(2*m),5+usedlambda_ind),1);
        ph(m,:)=mean(tmpdata(Marks(2*m-1):Marks(2*m),21+usedlambda_ind),1);%deg
        ACstd(m,:)=std(tmpdata(Marks(2*m-1):Marks(2*m),5+usedlambda_ind),0,1);
        phstd(m,:)=std(tmpdata(Marks(2*m-1):Marks(2*m),21+usedlambda_ind),0,1);%deg
    end
    
%     %Average AC/ph between marks 
%     for j=1:length(Marks)/2
%         AC(j,:)=nanmean(ACtmp(Marks(2*j-1):Marks(2*j),:),1);
%         ph(j,:)=nanmean(phtmp(Marks(2*j-1):Marks(2*j),:),1);
%     end
    
    %Unwrap phase
    for k=1:8
        ph(:,k)=unwrap(ph(:,k),180);
    end
    

    %Fit AC and ph vs. r for each wavelength
    for k= lambda_idx
        %AC
        [R,p]=corrcoef(r(ind2),log(AC(ind2,k).'.*r(ind2).^2));
        R2amp(i,k)=R(2)^2;
        pamp(i,k)=p(2);
        p_amp(k,:)=polyfit(r(ind2),log(AC(ind2,k).'.*r(ind2).^2),1);
        fitamp(k,:)=polyval(p_amp(k,:),r);
        
        %Phase
        p_pha(k,:)=polyfit(r(ind2),ph(ind2,k).'*pi/180,1); 
        [R,p]=corrcoef(r(ind2),ph(ind2,k)*pi/180);
        R2pha(i,k)=R(2)^2;
        ppha(i,k)=p(2);
        fitpha(k,:)=polyval(p_pha(k,:),r);
        %Make sure AC vs. r and ph vs. r was linear, if not, remove
        if R2pha(i,k)>0.95 && R2amp(i,k)>0.95
            fitmua(i,k)=abs(w/(2*v)*(p_amp(k,1)/p_pha(k,1)-p_pha(k,1)/p_amp(k,1)));
            fitmusp(i,k)=abs(2*v/3/w*p_amp(k,1)*p_pha(k,1));
        else
            fitmua(i,k)=NaN;
            fitmusp(i,k)=NaN;
        end
        
    end
        %Plot raw data
    figure('Position',[172         209        1056         776]),
    subplot(2,2,1)
    for k=1:lambda_idx
        hold on,plot(r,log(AC(1:length(r),k).'.*r.^2),'.','MarkerSize',30,'Color',colors(k,:))
    end
    ylabel('LN(A*r2)')
    h = legend(num2str(lambda.'),'Location','northwestoutside');
    set(h,'FontSize',5);
    xlim([min(r)-0.1 max(r)+0.1])
    grid on
    subplot(2,2,2)
    for k=lambda_idx
        hold on,plot(r,ph(1:length(r),k)-ph(1,k),'.','MarkerSize',30,'Color',colors(k,:))
    end
    ylabel('Phase (deg)')
    grid on
    xlim([min(r)-0.1 max(r)+0.1])
    subplot(2,2,3)
    hold on,plot(lambda(lambda_idx),fitmua(i,lambda_idx),'r.','MarkerSize',30)
    ylabel('mua (1/cm)')
    xlabel('\lambda (nm)')
    grid on
    %ylim([0.1 0.2])
    xlim([650 850])
    %ylim([0.05 0.12])
    subplot(2,2,4)
    hold on,plot(lambda(lambda_idx),fitmusp(i,lambda_idx),'b.','MarkerSize',30)
    ylabel('musp (1/cm)')
    xlabel('\lambda (nm)')
    grid on
    %ylim([3.5 8])
    xlim([650 850])
    %ylim([8 12])
    set(gcf,'PaperPositionMode','Auto')
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    %saveas(gcf,[ fdir 'savedfigs/' musset muastep '_' num2str(i) '.jpg'],'jpg')
    
    clear AC ph tmpdata Marks
end

%ind=find(lambda==690);
%fitmuatmp=fitmua;
%fitmuatmp(:,ind)=NaN;

% %Fit mua vs. wavelength over all reps
allmua=reshape(fitmua.',1,size(fitmua,1)*size(fitmua,2));
allmusp=reshape(fitmusp.',1,size(fitmusp,1)*size(fitmusp,2));
allmua(find(allmua==0))=NaN;
allmusp(find(allmusp==0))=NaN;
lambdatmp=repmat(lambda,1,size(fitmua,1)).';
alllambda=reshape(lambdatmp.',1,size(lambdatmp,1)*size(lambdatmp,2));

pmua_fit=polyfit(alllambda(find(~isnan(allmua))),allmua(find(~isnan(allmua))),1);
muaISS2015=polyval(pmua_fit,lambda);

pmusp_fit=polyfit(alllambda(find(~isnan(allmusp))),allmusp(find(~isnan(allmusp))),1);
muspISS2015=polyval(pmusp_fit,lambda);
% 
lambdaISS2015=lambda;

% Load absorbance data 

% date = '01-12-17_absorbance/';
% 
% conc = {'0.4mL','1.0mL','1.6mL','2.2mL'};
% 
% fname = [ fdir date conc{str2num(muastep)} '.txt'];
% fid = fopen([ fname ], 'r');
% for j=1:14
%     tline=fgetl(fid);
% end
% [tmpdata, count]=fscanf(fid,'%f %f',[2 inf]);
% fclose(fid);
% 
% tmpdata = tmpdata'; 
% 
% tmplambda = tmpdata(:,1);
% absorbance = tmpdata(:,2);
% 
% 
% absorbance_lambda = spline(tmplambda,absorbance,lambda);
% mualambda = 2.303*absorbance_lambda;

%save([ fdir 'Block_' blockname '_mua_musp.mat'],'muaISS2015','muspISS2015','lambdaISS2015','alllambda','allmusp','allmua')

figure('Position',figure_size);

for i=rep_range %startrep:numreps
    subplot(1,2,1)
    hold on,plot(lambda(lambda_idx),fitmua(i,lambda_idx),'r.','MarkerSize',30,'Color',colors(i,:))
    ylabel('mua (1/cm)')
    xlabel('\lambda (nm)')
    grid on
    ylim([0.0 0.2])
    xlim([650 850])
    
    % t = [exp(1:2) '-' musset muastep];
    %title(t);
    %ylim([0.05 0.12])
    subplot(1,2,2)
    hold on,plot(lambda(lambda_idx),fitmusp(i,lambda_idx),'.','MarkerSize',30,'Color',colors(i,:))
    ylabel('musp (1/cm)')
    xlabel('\lambda (nm)')
    grid on
    %ylim([3.5 8]) %9 13.5 % 3.5 8  % 8 12 
%     ylim([1 7])
    ylim([1 12])
    xlim([650 850])
    %ylim([8 12])
end



legend(num2str(rep_range.'))
subplot(1,2,1)
hold on,plot(lambdaISS2015(lambda_idx),muaISS2015(lambda_idx),'k.-','LineWidth',2)
%hold on,plot(lambdaISS2015,mualambda,'k.-','LineWidth',2)
subplot(1,2,2)
hold on,plot(lambdaISS2015(lambda_idx),muspISS2015(lambda_idx),'k.-','LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',20)
set(gcf,'PaperPositionMode','Auto')
mua_850nm=polyval(pmua_fit,850)
musp_850nm=polyval(pmusp_fit,850)
%subplot_title_high(title);

%saveas(gcf,[ fdir 'savedfigs/NIRS_allreps.jpg'],'jpg')

 mua_l_ref = nanmean(fitmua,1);
 musp_l_ref = nanmean(fitmusp,1);
% 
%save 'optprop_l2_2.mat' mua_l_ref musp_l_ref 