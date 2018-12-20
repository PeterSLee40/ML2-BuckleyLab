function [tmp]=readdpdwm(fname)


fi=fopen(fname,'rt');


       %s# c# d# d1a d1p d1i d1q d1at d4at mm/dd/yy hh:mm:ss am/pm 
tmp=fscanf(fi,['%g %g %g %g %g %g %g %g  %g %g %g %g %g  %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g  %d/%d/%d %d:%d:%d %*s %g\n'],[46 inf]);


fclose(fi);





%tmpsave='./data/dataoutput.mat';
%tmpvar='tmp';
%save(tmpsave,tmpvar);
