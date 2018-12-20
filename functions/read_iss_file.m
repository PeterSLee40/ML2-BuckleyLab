function iss_ms=read_iss_file(iss_file_name,varargin)

%fprintf('Reading %s...\n',iss_file_name);

%sd_seps wvs ac_data dc_data ph_data aux_data ac_cal dc_cal aux_cal
%timepts marks flags acq_rate

fid2=fopen(iss_file_name,'r');
if(fid2<0) %fprintf('Could not open ISS data file\n');
    iss_ms.discard=1;return;end;

dummy=fscanf(fid2,'%s',1);
while ~strcmp(dummy,'Version') dummy=fscanf(fid2,'%s',1); end

boxy_version=fscanf(fid2,'%f',1);
if boxy_version==0.4 
    %fprintf('BOXY Version 0.4 - old ISS\n');
    if isempty(varargin)
        %fprintf('SD-geo file name not given\n'); 
        iss_ms.discard=1;return;
    else sd_geo_file_name=varargin{1};
    end
    fid1=fopen(sd_geo_file_name,'r');
    if(fid1<0) %fprintf('Could not open SD-geo file\n');
        iss_ms.discard=1;return; end;
else %fprintf('BOXY Version 0.7 - new ISS\n');
end

frewind(fid2);

if boxy_version==0.4,

    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1); % skip a line
    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);
    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);

    num_src=fscanf(fid1,'%f',1);dummy=fscanf(fid1,'%s',1); % skip to next line after reading parameter value
    if(num_src~=1) %fprintf('Software not yet designed to deal with more than one source\n'); 
        iss_ms.discard=1;return;end

    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);
    num_det=fscanf(fid1,'%f',1);dummy=fscanf(fid1,'%s',1);
    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);
    num_aux=fscanf(fid1,'%f',1);dummy=fscanf(fid1,'%s',1);
    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);
    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);

    for I=1:num_det,
        dummy=fscanf(fid1,'%s',2);
        sd_seps(I)=fscanf(fid1,'%f',1);
    end

    dummy=fscanf(fid1,'%s',1);
    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);
    dummy=fscanf(fid1,'%*[^\n]',1); dummy=fscanf(fid1,'%*1[\n]',1);

    num_wv=fscanf(fid1,'%f',1);

    dummy=fscanf(fid1,'%s',1);
    while ~strcmp(dummy,'Wavelengths')
        dummy=fscanf(fid1,'%s',1);
    end;


    for I=1:num_wv,
        wvs(I)=fscanf(fid1,'%f',1);
    end

    %fprintf('Sources: %.0f, Detectors: %.0f, Aux channels: %.0f\n',num_src,num_det,num_aux);
    %fprintf('SD separations: ');
    for I=1:num_det, %fprintf('%.2f ',sd_seps(I));
    end;
    %fprintf('cm\n');
    %fprintf('Wavelengths: ');
    for I=1:num_wv, %fprintf('%.0f ',wvs(I));
    end;
    %fprintf('nm\n');

    fclose(fid1); % done with the SD-geo file

    % skip to acq_rate field

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'Waveform')
        dummy=fscanf(fid2,'%s',1);
    end;
    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'Waveform')
        dummy=fscanf(fid2,'%s',1);
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%

    acq_rate=fscanf(fid2,'%f',1);

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'INFORMATION')
        dummy=fscanf(fid2,'%s',1);
    end;

    % ensure the #FILE INFORMATION field is standard, i.e. T,F,T,F,F,F,F,Tab

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'TRUE')) %fprintf('Non standard ISS configuration\n');
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'TRUE')) %fprintf('Non standard ISS configuration\n');
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n');
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'Tab')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    % ensure we are dealing with calibrated data

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'STATE')
        dummy=fscanf(fid2,'%s',1);
    end;

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'TRUE')) %fprintf('Current version does not deal with uncalibrated data\n');
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    % read aux calibration values

    %fprintf('Reading aux calibration...');

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'Term')
        dummy=fscanf(fid2,'%s',1);
    end;

    for I=1:num_aux,
        aux_cal(I,1)=fscanf(fid2,'%f',1);
    end
    dummy=fscanf(fid2,'%s',1);
    for I=1:num_aux,
        aux_cal(I,2)=fscanf(fid2,'%f',1);
    end

    % read wfm calibration values

    %fprintf(' Done\nReading wfm calibration ...');

    for I=1:num_det,

        dummy=fscanf(fid2,'%s',1);
        while ~strcmp(dummy,'Term')
            dummy=fscanf(fid2,'%s',1);
        end;

        for J=1:num_wv,
            ac_cal(I,J,1)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

        for J=1:num_wv,
            dc_cal(I,J,1)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

        for J=1:num_wv,
            ph_cal(I,J)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>) no factor, only term
        end

        dummy=fscanf(fid2,'%s',1);
        while ~strcmp(dummy,'Factor')
            dummy=fscanf(fid2,'%s',1);
        end;

        for J=1:num_wv,
            ac_cal(I,J,2)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

        for J=1:num_wv,
            dc_cal(I,J,2)=fscanf(fid2,'%f',1); % dc_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

    end

    %fprintf(' Done\nReading data ... ');

    timepts=zeros(50000,1);
    marks=zeros(50000,1);
    flags=zeros(50000,1);

    ac_data=zeros(50000,num_det,num_wv);
    dc_data=zeros(50000,num_det,num_wv);
    ph_data=zeros(50000,num_det,num_wv);
    aux_data=zeros(50000,num_aux);

    counter=1;


    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,sprintf('aux-%.0f',num_aux))
        dummy=fscanf(fid2,'%s',1);
    end;

    while 1,

        dummy=fscanf(fid2,'%s',1);
        if strcmp(dummy,'#DATA') break; end;

        timepts(counter)=str2double(dummy);
        dummy=fscanf(fid2,'%f',1);
        marks(counter)=fscanf(fid2,'%f',1);
        flags(counter)=fscanf(fid2,'%f',1);

        for J=1:num_det,
            for I=1:num_wv,
                ac_data(counter,J,I)=fscanf(fid2,'%f',1);
            end
            for I=1:num_wv,
                dc_data(counter,J,I)=fscanf(fid2,'%f',1);
            end
            for I=1:num_wv,
                ph_data(counter,J,I)=fscanf(fid2,'%f',1);
            end
        end

        for I=1:num_aux,
            aux_data(counter,I)=fscanf(fid2,'%f',1);
        end
        counter=counter+1;
    end

    timepts=timepts(1:counter-1);
    marks=marks(1:counter-1,1);
    flags=flags(1:counter-1,1);
    ac_data=ac_data(1:counter-1,:,:);
    dc_data=dc_data(1:counter-1,:,:);
    ph_data=ph_data(1:counter-1,:,:);
    aux_data=aux_data(1:counter-1,:);

    %[unwrapped_ph_data phjumps]=unwrap4(reshape(ph_data,length(timepts),num_det*length(wvs)), wvs,sd_seps', ones(num_det,1),ones(length(wvs),1),[]);

    %fprintf('%.0f timepoints, %.2f seconds\n',counter-1,timepts(end)-timepts(1));


    fclose(fid2);

    iss_ms.num_src=num_src;
    iss_ms.num_det=num_det;
    iss_ms.num_aux=num_aux;
    iss_ms.sd_seps=sd_seps;
    iss_ms.wvs=wvs;
    iss_ms.acq_rate=acq_rate;
    iss_ms.aux_cal=aux_cal;
    iss_ms.ac_cal=ac_cal;
    iss_ms.dc_cal=dc_cal;
    iss_ms.ph_cal=ph_cal;
    iss_ms.timepts=timepts;
    iss_ms.marks=marks;
    iss_ms.flags=flags;
    iss_ms.ac_data=ac_data;
    iss_ms.dc_data=dc_data;
    %keyboard
    iss_ms.ph_data=myunwrap(ph_data/180*pi);
    %iss_ms.ph_data=(reshape(unwrapped_ph_data,length(timepts),num_det,length(wvs)))/180*3.1415926;
    iss_ms.aux_data=aux_data;
    iss_ms.discard=0;
    test_null=find(iss_ms.ac_data==0); if(size(test_null)) iss_ms.discard=1; end;

else

       % temporarily hard coded parameters
    
    num_aux=4;
 
    
    
    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'INFORMATION')
        dummy=fscanf(fid2,'%s',1);
    end;
    
    num_det=fscanf(fid2,'%f',1);
    dummy=fscanf(fid2,'%s',2);
    num_wv=fscanf(fid2,'%f',1);
    
    if(num_wv==16) num_src=2; else num_src=4; end;
    if(num_wv==8) wvs=[635 669 691 752 758 781 811 830]; end
    
    % skip to acq_rate field

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'Waveform')
        dummy=fscanf(fid2,'%s',1);
    end;
    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'Waveform')
        dummy=fscanf(fid2,'%s',1);
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%

    acq_rate=fscanf(fid2,'%f',1);

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'INFORMATION')
        dummy=fscanf(fid2,'%s',1);
    end;

    % ensure the #FILE INFORMATION field is standard, i.e. T,F,T,F,F,F,F,Tab

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'TRUE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'TRUE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n');
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'FALSE')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'Tab')) %fprintf('Non standard ISS configuration\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

    % ensure we are dealing with calibrated data

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'STATE')
        dummy=fscanf(fid2,'%s',1);
    end;

    dummy=fscanf(fid2,'%s',1);
    if(~strcmp(dummy,'TRUE')) %fprintf('Current version does not deal with uncalibrated data\n'); 
        iss_ms.discard=1;return;end
    dummy=fscanf(fid2,'%*[^\n]',1); dummy=fscanf(fid2,'%*1[\n]',1);

 
    
    % read aux calibration values

    %fprintf('Reading aux calibration...');

    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,'Term')
        dummy=fscanf(fid2,'%s',1);
    end;

    for I=1:num_aux,
        aux_cal(I,1)=fscanf(fid2,'%f',1);
    end
    dummy=fscanf(fid2,'%s',1);
    for I=1:num_aux,
        aux_cal(I,2)=fscanf(fid2,'%f',1);
    end

    % read wfm calibration values

    %fprintf(' Done\nReading wfm calibration ...');

    
    for I=1:num_det,

        dummy=fscanf(fid2,'%s',1);
        while ~strcmp(dummy,'Term')
            dummy=fscanf(fid2,'%s',1);
        end;

        for J=1:num_wv,
            ac_cal(I,J,1)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

        for J=1:num_wv,
            dc_cal(I,J,1)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

        for J=1:num_wv,
            ph_cal(I,J)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>) no factor, only term
        end

        dummy=fscanf(fid2,'%s',1);
        while ~strcmp(dummy,'Factor')
            dummy=fscanf(fid2,'%s',1);
        end;

        for J=1:num_wv,
            ac_cal(I,J,2)=fscanf(fid2,'%f',1); % ac_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

        for J=1:num_wv,
            dc_cal(I,J,2)=fscanf(fid2,'%f',1); % dc_cal(<detector index>,<waveform index>,<1=term or 2=factor>)
        end

    end

    %fprintf(' Done\nReading distance settings ...');
    
    det_names='ABCD';
    
    for I=1:num_det,
        
        dummy=fscanf(fid2,'%s',1);
        while ~strcmp(dummy,sprintf('%s-%.0f',det_names(I)',num_wv))
            dummy=fscanf(fid2,'%s',1);
        end;
        
        for J=1:num_wv,
            sd_seps(I,J)=fscanf(fid2,'%f',1);
        end
        
    end
    
    %fprintf(' Done\nReading data ... ');

    timepts=zeros(50000,1);
    marks=zeros(50000,1);
    flags=zeros(50000,1);

    ac_data=zeros(50000,num_det,num_wv);
    dc_data=zeros(50000,num_det,num_wv);
    ph_data=zeros(50000,num_det,num_wv);
    aux_data=zeros(50000,num_aux);

    counter=1;


    dummy=fscanf(fid2,'%s',1);
    while ~strcmp(dummy,sprintf('aux-%.0f',num_aux))
        dummy=fscanf(fid2,'%s',1);
    end;

    while 1,

        dummy=fscanf(fid2,'%s',1);
        if strcmp(dummy,'#DATA') break; end;

        timepts(counter)=str2double(dummy);
        dummy=fscanf(fid2,'%f',2);
        marks(counter)=fscanf(fid2,'%f',1);
        flags(counter)=fscanf(fid2,'%f',1);

        for J=1:num_det,
            for I=1:num_wv,
                ac_data(counter,J,I)=fscanf(fid2,'%f',1);
            end
            for I=1:num_wv,
                dc_data(counter,J,I)=fscanf(fid2,'%f',1);
            end
            for I=1:num_wv,
                ph_data(counter,J,I)=fscanf(fid2,'%f',1);
            end
        end

        for I=1:num_aux,
            aux_data(counter,I)=fscanf(fid2,'%f',1);
        end
        counter=counter+1;
    end

    timepts=timepts(1:counter-1);
    marks=marks(1:counter-1,1);
    flags=flags(1:counter-1,1);
    ac_data=ac_data(1:counter-1,:,:);
    dc_data=dc_data(1:counter-1,:,:);
    ph_data=ph_data(1:counter-1,:,:);
    aux_data=aux_data(1:counter-1,:);

    %[unwrapped_ph_data phjumps]=unwrap4(reshape(ph_data,length(timepts),num_det*length(wvs)), wvs,sd_seps', ones(num_det,1),ones(length(wvs),1),[]);

    %fprintf('%.0f timepoints, %.2f seconds\n',counter-1,timepts(end)-timepts(1));


    fclose(fid2);

    iss_ms.num_src=num_src;
    if(exist('wvs')) iss_ms.wvs=wvs;end
    iss_ms.num_det=num_det;
    iss_ms.num_aux=num_aux;
    iss_ms.sd_seps=sd_seps;
%    iss_ms.wvs=wvs;
    iss_ms.acq_rate=acq_rate;
    iss_ms.aux_cal=aux_cal;
    iss_ms.ac_cal=ac_cal;
    iss_ms.dc_cal=dc_cal;
    iss_ms.ph_cal=ph_cal;
    iss_ms.timepts=timepts;
    iss_ms.marks=marks;
    iss_ms.flags=flags;
    iss_ms.ac_data=ac_data;
    iss_ms.dc_data=dc_data;
    %keyboard
    iss_ms.ph_data=myunwrap(ph_data/180*pi);
    %iss_ms.ph_data=(reshape(unwrapped_ph_data,length(timepts),num_det,length(wvs)))/180*3.1415926;
    iss_ms.aux_data=aux_data;
    iss_ms.discard=0;
    test_null=find(iss_ms.ac_data==0); if(size(test_null)) iss_ms.discard=1; end;

end;
