function [AC,ph,ACstd,phstd]=loadISSdata_bankB(fname)
%Load data
fid = fopen([ fname], 'r');
for j=1:187
    tline=fgetl(fid);
end
[tmpdata, count]=fscanf(fid,'%g %g',[202 inf]);
fclose(fid);
data=tmpdata.';

%Unwrap phase and convert to radians
%Det A
for j=38:53
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
%Det B
for j=86:101
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
%Det C
for j=134:149
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
%Det D
for j=182:197
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end

AC(1,:)=mean(data(:,5+1+8:5+16),1);
AC(2,:)=mean(data(:,5+1+8+48:5+16+48),1);
AC(3,:)=mean(data(:,5+1+8+48+48:5+16+48+48),1);
AC(4,:)=mean(data(:,5+1+8+48+48+48:5+16+48+48+48),1);
ACstd(1,:)=std(data(:,5+8+1:5+16),0,1);
ACstd(2,:)=std(data(:,5+8+1+48:5+16+48),0,1);
ACstd(3,:)=std(data(:,5+8+1+48+48:5+16+48+48),0,1);
ACstd(4,:)=std(data(:,5+8+1+48+48+48:5+16+48+48+48),0,1);

%Get phase data for each separation and wavelength
ph(1,:)=mean(data(:,46:53),1);
ph(2,:)=mean(data(:,94:101),1);
ph(3,:)=mean(data(:,142:149),1);
ph(4,:)=mean(data(:,190:197),1);
phstd(1,:)=std(data(:,46:53),0,1);
phstd(2,:)=std(data(:,94:101),0,1);
phstd(3,:)=std(data(:,142:149),0,1);
phstd(4,:)=std(data(:,190:197),0,1);

clear tmpdata