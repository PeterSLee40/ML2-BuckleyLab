function [AC,ph,ACstd,phstd]=loadISS2015data(fname)
%Load data
fid = fopen([ fname], 'r');
for j=1:187
    tline=fgetl(fid);
end
[tmpdata, count]=fscanf(fid,'%g %g',[106 inf]);
fclose(fid);
data=tmpdata.';
%Unwrap phase and convert to radians
%Det A
for j=(5+16+1):(5+16+8)%22:22+7
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
%Det B
for j=(5+16+1+24):(5+16+8+24)%46:46+7
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
%Det C
for j=(5+16+1+24+24):(5+16+8+24+24)%70:70+7
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
%Det D
for j=(5+16+1+24+24+24):(5+16+1+24+24+24+8)%94:94+7
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end


AC(1,:)=mean(data(:,5+1:5+8),1);
AC(2,:)=mean(data(:,5+1+24:5+8+24),1);
AC(3,:)=mean(data(:,5+1+24+24:5+8+24+24),1);
AC(4,:)=mean(data(:,5+1+24+24+24:5+8+24+24+24),1);
ACstd(1,:)=std(data(:,5+1:5+8),0,1);
ACstd(2,:)=std(data(:,5+1+24:5+8+24),0,1);
ACstd(3,:)=std(data(:,5+1+24+24:5+8+24+24),0,1);
ACstd(4,:)=std(data(:,5+1+24+24+24:5+8+24+24+24),0,1);

%Get phase data for each separation and wavelength
ph(1,:)=mean(data(:,5+16+1:5+16+8),1);
ph(2,:)=mean(data(:,5+16+1+24:5+16+8+24),1);
ph(3,:)=mean(data(:,5+16+1+24+24:5+16+8+24+24),1);
ph(4,:)=mean(data(:,5+16+1+24+24+24:5+16+8+24+24+24),1);
phstd(1,:)=std(data(:,5+16+1:5+16+8),0,1);
phstd(2,:)=std(data(:,5+16+1+24:5+16+8+24),0,1);
phstd(3,:)=std(data(:,5+16+1+24+24:5+16+8+24+24),0,1);
phstd(4,:)=std(data(:,5+16+1+24+24+24:5+16+8+24+24+24),0,1);

clear tmpdata