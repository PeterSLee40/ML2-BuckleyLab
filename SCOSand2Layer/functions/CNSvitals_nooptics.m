function CNSvitals_nooptics(subjectid,patdate,exten,savefigures,timeoffCPB,savematfile,invivo,hrmin,bpmin,bpmax,spo2min,rapmin,mapnans)
fdir=[ '../' subjectid '/' subjectid 'notes/' subjectid '_' patdate exten 'vitals/'];
bplim=[20 110];
SpO2lim=[50 100];
raplim=[0 20];

if invivo
    fnametmp=[ fdir 'HR,na,Numeric,Float,Invivo,data_part1of1.mat' ];
else
    fnametmp=[ fdir 'HR,na,Numeric,Float,Solar,data_part1of1.mat' ];
end

if exist(fnametmp)
    load([ fnametmp ]);
    hr=measurement_data;
    time_hr=time_vector./60;%convert to minutes
    %Sync time of HR data with time off CPB
    time_hr=time_hr+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;
    %Get rid of erroneous HR values
    for i=1:length(hr)
        if hr(i)<=hrmin
             hr(i)=NaN;
        end
    end
    figure,plot(time_hr,hr,'.k-','MarkerSize',40,'LineWidth',3)
    set(gca,'FontSize',34)
    xlim([min(time_hr) max(time_hr)])
    ylim([min(hr)-10 max(hr)+10])
    set(gcf,'PaperPositionMode','Auto')
    grid on
    h1=legend('HR');
    set(h1,'FontSize',30)
    ylabel('Heart Rate (bpm)')
    xlabel('Time (min)')
    maxwindows(gcf);
    if savefigures

        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_HR.fig'],'fig')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_HR.eps'],'epsc2')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_HR.png'],'png')

    end
    if savematfile
        tt=['save vitals' subjectid '_' patdate exten ' hr time_hr invivo'];
        eval(tt);
    end
end
clear fnametmp

%load([ fdir 'ETCO2,na,Numeric,Float,Invivo,data_part1of1.mat' ]);
%etco2=measurement_data;
%time_etco2=time_vector;
%figure,plot(time_etco2,etco2)

if invivo
    fnametmp=[ fdir 'inCO2,na,Numeric,Float,Invivo,data_part1of1.mat' ];
else
    fnametmp=[ fdir 'inCO2,na,Numeric,Float,GE,data_part1of1.mat' ];
end
if exist(fnametmp)
    load([ fnametmp ]);
    inco2=measurement_data;
    time_inco2=time_vector./60;
    %Sync time of inco2 data with time off CPB
    time_inco2=time_inco2+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;

    figure,plot(time_inco2,inco2,'.k-','MarkerSize',40,'LineWidth',3)
    set(gca,'FontSize',34)
    xlim([min(time_inco2) max(time_inco2)])
    grid on
    h1=legend('InCO_{2}');
    set(h1,'FontSize',30)
    ylabel('InCO_{2} (mmHg)')
    xlabel('Time (min)')
    maxwindows(gcf);
    set(gcf,'PaperPositionMode','Auto')
    if savefigures

        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_inco2.fig'],'fig')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_inco2.eps'],'epsc2')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_inco2.png'],'png')

    end
    if savematfile
        tt=['save vitals' subjectid '_' patdate exten ' inco2 time_inco2 -append'];
        eval(tt);
    end

end
clear fnametmp

if invivo
    fnametmp=[ fdir 'SpO2,na,Numeric,Float,Invivo,data_part1of1.mat' ];
else
    fnametmp=[ fdir 'SpO2,na,Numeric,Float,Solar,data_part1of1.mat' ];
end
if exist(fnametmp)
    load([ fnametmp ]);
    spo2=measurement_data;
    time_spo2=time_vector./60;
    %Sync time of spo2 data with time off CPB
    time_spo2=time_spo2+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;
    for i=1:length(spo2)
        if spo2(i)<=spo2min
            spo2(i)=NaN;
        end
    end
    figure,plot(time_spo2,spo2,'.k-','MarkerSize',40,'LineWidth',3)
    set(gca,'FontSize',34)
    xlim([min(time_spo2) max(time_spo2)])
    ylim(SpO2lim)
    grid on
    h1=legend('O_2 Sat');
    set(h1,'FontSize',30)
    ylabel('O_2 Sat(%)')
    xlabel('Time (min)')
    maxwindows(gcf);
    set(gcf,'PaperPositionMode','Auto')
    if savefigures

        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_SpO2.fig'],'fig')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_SpO2.eps'],'epsc2')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_SpO2.png'],'png')

    end
    if savematfile
        tt=['save vitals' subjectid '_' patdate exten ' spo2 time_spo2 -append'];
        eval(tt);
    end
end
clear fnametmp

if invivo
    fnametmp=[ fdir 'RAP,na,Numeric,Float,Invivo,data_part1of1.mat' ];
else
    fnametmp=[ fdir 'RAP,Mean,Numeric,Float,Solar,data_part1of1.mat' ];
end
if exist(fnametmp)
    load([ fnametmp ]);
    rap=measurement_data;
    time_rap=time_vector./60;
    %Sync time of spo2 data with time off CPB
    time_rap=time_rap+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;
    for i=1:length(rap)
        if rap(i)<=rapmin
            rap(i)=NaN;
        end
    end
    
    figure,plot(time_rap,rap,'.k-','MarkerSize',40,'LineWidth',3)
    set(gca,'FontSize',34)
    xlim([min(time_rap) max(time_rap)])
    ylim(raplim)
    grid on
    h1=legend('RAP');
    set(h1,'FontSize',30)
    ylabel('Right Atrial Press. (mmHg)')
    xlabel('Time (min)')
    maxwindows(gcf);
    set(gcf,'PaperPositionMode','Auto')
    if savefigures

        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_RAP.fig'],'fig')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_RAP.eps'],'epsc2')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_RAP.png'],'png')

    end
    if savematfile
        tt=['save vitals' subjectid '_' patdate exten ' rap time_rap -append'];
        eval(tt);
    end
end
clear fnametmp

if invivo
    fnametmp=[ fdir 'RR,na,Numeric,Float,Invivo,data_part1of1.mat' ];
else
    fnametmp=[ fdir 'RR,na,Numeric,Float,Solar,data_part1of1.mat' ];
end
if exist(fnametmp)
    load([ fnametmp ]);
    resp=measurement_data;
    time_resp=time_vector./60;
    %Sync time of spo2 data with time off CPB
    time_resp=time_resp+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;

    figure,plot(time_resp,resp,'.k-','MarkerSize',40,'LineWidth',3)
    set(gca,'FontSize',34)
    axis tight
    xlim([min(time_resp) max(time_resp)])
    grid on
    h1=legend('RR');
    set(h1,'FontSize',30)
    ylabel('Resp. Rate (bpm)')
    xlabel('Time (min)')
    maxwindows(gcf);
    set(gcf,'PaperPositionMode','Auto')
    if savefigures

        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_Resp.fig'],'fig')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_Resp.eps'],'epsc2')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_Resp.png'],'png')

    end
    if savematfile
        tt=['save vitals' subjectid '_' patdate exten ' resp time_resp -append'];
        eval(tt);
    end
end
clear fnametmp

if invivo
    fnametmp=[ fdir 'NBP,Dias,Numeric,Float,Invivo,data_part1of1.mat' ];
else
    fnametmp=[ fdir 'NBP,Dias,Numeric,Float,Solar,data_part1of1.mat' ];
end
if exist(fnametmp)
    load([ fnametmp ]);
    nbpdias=measurement_data;
    nbpdias(find(nbpdias==0))=NaN;
    time_nbpdias=time_vector./60;
    %Sync time of BPdias data with time off CPB
    time_nbpdias=time_nbpdias+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;

    %BPsystolic
    if invivo
        fnametmp=[ fdir 'NBP,Syst,Numeric,Float,Invivo,data_part1of1.mat' ];
    else
        fnametmp=[ fdir 'NBP,Syst,Numeric,Float,Solar,data_part1of1.mat' ];
    end
    load([ fnametmp ]);
    nbpsys=measurement_data;
    nbpsys(find(nbpsys==0))=NaN;
    time_nbpsys=time_vector./60;
    %Sync time of BPsys data with time off CPB
    time_nbpsys=time_nbpsys+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;

    %MAP
    if invivo
        fnametmp=[ fdir 'NBP,Mean,Numeric,Float,Invivo,data_part1of1.mat' ];
    else
        fnametmp=[ fdir 'NBP,Mean,Numeric,Float,Solar,data_part1of1.mat' ];
    end
    load([ fnametmp ]);
    nmap=measurement_data;
    nmap(find(nmap==0))=NaN;
    time_nmap=time_vector./60;
    %Sync time of BPsys data with time off CPB
    time_nmap=time_nmap+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;

    figure,plot(time_nbpsys,nbpsys,'.b-','MarkerSize',40,'LineWidth',3)
    hold on,plot(time_nmap,nmap,'.-','Color',[0 0.5 0],'MarkerSize',40,'LineWidth',3)
    hold on,plot(time_nbpdias,nbpdias,'.r-','MarkerSize',40,'LineWidth',3)
    set(gca,'FontSize',34)
    xlim([min(time_nbpdias) max(time_nbpdias)])
    ylim([min(nbpdias)-5 max(nbpsys)+5])
    grid on
    h1=legend('NBP-systolic','NBP-mean','NBP-diastolic');
    set(h1,'FontSize',30)
    ylabel('Cuff BP (mmHg)')
    xlabel('Time (min)')
    maxwindows(gcf);
    set(gcf,'PaperPositionMode','Auto')
    if savefigures

        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_NBP.fig'],'fig')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_NBP.eps'],'epsc2')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_NBP.png'],'png')

    end
    if savematfile
        tt=['save vitals' subjectid '_' patdate exten ' nbpsys nbpdias nmap time_nbpsys time_nbpdias time_nmap -append'];
        eval(tt);
    end
end
clear fnametmp

if invivo
    fnametmp=[ fdir 'ABP,DIAS,Numeric,Float,Invivo,data_part1of1.mat' ];
else
    fnametmp=[ fdir 'ABP,Dias,Numeric,Float,Solar,data_part1of1.mat' ];
end
if exist(fnametmp)
    load([ fnametmp ]);
    bpdiastmp=measurement_data;
    time_bpdias=time_vector./60;
    %Sync time of BPdias data with time off CPB
    time_bpdias=time_bpdias+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;
    for i=1:size(mapnans,1)
        bpdiastmp(mapnans{i})=NaN;
    end
    for i=1:length(bpdiastmp)
        if bpdiastmp(i)<=bpmin || bpdiastmp(i)>=bpmax
            bpdiastmp(i)=NaN;
        end
    end
    bpdias=bpdiastmp(~isnan(bpdiastmp));
    time_bpdias=time_bpdias(~isnan(bpdiastmp));
    
    %BPsystolic
    if invivo
        fnametmp=[ fdir 'ABP,SYST,Numeric,Float,Invivo,data_part1of1.mat' ];
    else
        fnametmp=[ fdir 'ABP,Syst,Numeric,Float,Solar,data_part1of1.mat' ];
    end
    load([ fnametmp ]);
    bpsystmp=measurement_data;
    time_bpsys=time_vector./60;
    %Sync time of BPsys data with time off CPB
    time_bpsys=time_bpsys+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;
    for i=1:size(mapnans,1)
        bpsystmp(mapnans{i})=NaN;
    end
    for i=1:length(bpsystmp)
        if bpsystmp(i)<=bpmin || bpsystmp(i)>=bpmax
            bpsystmp(i)=NaN;
        end
    end
    bpsys=bpsystmp(~isnan(bpsystmp));
    time_bpsys=time_bpsys(~isnan(bpsystmp));
   
    if ~invivo
        fnametmp=[ fdir 'ABP,Mean,Numeric,Float,Solar,data_part1of1.mat' ];
        load([ fnametmp ]);
        maptmp=measurement_data;
        time_map=time_vector./60;
        %Sync time of MAP data with optical data
        time_map=time_map+(datenum(start_date_time)-datenum(timeoffCPB))*1.44e3;
        for i=1:size(mapnans,1)
            maptmp(mapnans{i})=NaN;
        end
        for i=1:length(maptmp)
            if maptmp(i)<=bpmin || maptmp(i)>=bpmax
                maptmp(i)=NaN;
            end
        end    
    end
    map=maptmp(~isnan(maptmp));
    time_map=time_map(~isnan(maptmp));
   
    figure,plot(time_bpsys,bpsys,'.b-','MarkerSize',20,'LineWidth',3)
    hold on,plot(time_bpdias,bpdias,'.r-','MarkerSize',20,'LineWidth',3)
    if ~invivo
        hold on,plot(time_map,map,'.-','Color',[0 0.5 0],'MarkerSize',20,'LineWidth',3)
    end
    set(gca,'FontSize',34)
    xlim([min(time_nmap) max(time_nmap)])
    ylim(bplim)
    grid on
    h1=legend('BP-systolic','BP-diastolic','BP-mean');
    set(h1,'FontSize',30)
    ylabel('Arterial BP (mmHg)')
    xlabel('Time (min)')
    maxwindows(gcf);
    set(gcf,'PaperPositionMode','Auto')
    if savefigures

        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_ABP.fig'],'fig')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_ABP.eps'],'epsc2')
        saveas(gcf,['../' subjectid '/' subjectid 'notes/savedfigs/' patdate '_' subjectid exten '_ABP.png'],'png')

    end
    if savematfile && invivo
        tt=['save vitals' subjectid '_' patdate exten ' bpsys bpdias time_bpsys time_bpdias -append'];
        eval(tt);
    elseif savematfile && ~invivo
        tt=['save vitals' subjectid '_' patdate exten ' bpsys bpdias map time_bpsys time_bpdias time_map -append'];
        eval(tt);
    end
end
clear fnametmp



