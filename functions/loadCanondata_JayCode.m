function [AC,ph,ACstd,phstd]=loadCanondata_JayCode(fname)
%Load data
fid = fopen([ fname], 'r');
for j=1:110
    tline=fgetl(fid);
    tmp = sscanf(tline,'%f');
    if j>7 && j<110
        data(j-7,:)=tmp(2:end);
    end
end
fclose(fid);
%Unwrap phase and convert to radians
for j=17:32
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
for j=49:64
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end

AC(1,:)=mean(data(:,1:8),1);
AC(2,:)=mean(data(:,9:16),1);
AC(3,:)=mean(data(:,33:40),1);
AC(4,:)=mean(data(:,41:48),1);
ACstd(1,:)=std(data(:,1:8),0,1);
ACstd(2,:)=std(data(:,9:16),0,1);
ACstd(3,:)=std(data(:,33:40),0,1);
ACstd(4,:)=std(data(:,41:48),0,1);

%Get phase data for each separation and wavelength
ph(1,:)=mean(data(:,17:24),1);
ph(2,:)=mean(data(:,25:32),1);
ph(3,:)=mean(data(:,49:56),1);
ph(4,:)=mean(data(:,57:64),1);
phstd(1,:)=std(data(:,17:24),0,1);
phstd(2,:)=std(data(:,25:32),0,1);
phstd(3,:)=std(data(:,49:56),0,1);
phstd(4,:)=std(data(:,57:64),0,1);

clear tmpdata

