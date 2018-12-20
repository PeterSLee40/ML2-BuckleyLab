function [AC,ph,ACstd,phstd]=loadCanondata(fname)
%Load data
fid = fopen([ fname], 'r');
for j=1:149
    tline=fgetl(fid);
end
[tmpdata, count]=fscanf(fid,'%g %g',[110 inf]);
fclose(fid);
data=tmpdata.';
%Unwrap phase and convert to radians
for j=38:53
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
for j=86:101
    data(:,j)=unwrap(data(:,j)*pi/180,pi/2);
end
AC(1,:)=mean(data(:,6:13),1);
AC(2,:)=mean(data(:,14:21),1);
AC(3,:)=mean(data(:,54:61),1);
AC(4,:)=mean(data(:,62:69),1);
ACstd(1,:)=std(data(:,6:13),0,1);
ACstd(2,:)=std(data(:,14:21),0,1);
ACstd(3,:)=std(data(:,54:61),0,1);
ACstd(4,:)=std(data(:,62:69),0,1);

%Get phase data for each separation and wavelength
ph(1,:)=mean(data(:,38:45),1);
ph(2,:)=mean(data(:,46:53),1);
ph(3,:)=mean(data(:,86:93),1);
ph(4,:)=mean(data(:,94:101),1);
phstd(1,:)=std(data(:,38:45),0,1);
phstd(2,:)=std(data(:,46:53),0,1);
phstd(3,:)=std(data(:,86:93),0,1);
phstd(4,:)=std(data(:,94:101),0,1);

clear tmpdata