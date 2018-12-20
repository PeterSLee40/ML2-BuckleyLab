function [tmp]=readdpdw_seqscan_het(fname)


fi=fopen(fname,'rt');


       %s# c# d# d1a d1p d1i d1q d1at d2a d2p d2i d2q d2at d3a d3p d3i d3q d3at d4a d4p d4i d4q d4at mm/dd/yy hh:mm:ss am/pm 
tmp=fscanf(fi,['%g %g %g %g %g %g %g %g  %g %g %g %g %g  %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %d/%d/%d %d:%d:%d %*s %g\n'],[46 inf]);
 

       

fclose(fi);





%tmpsave='./data/dataoutput.mat';
%tmpvar='tmp';
%save(tmpsave,tmpvar);
