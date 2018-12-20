%%Time-stamp: "2005-12-19 23:03:00 matlabuser"
%to filter the stroke signals
function output=strokefilter(mydata,myfiltersize)

%gaussian sliding filter
width=ceil(myfiltersize./2)/2; 
gaussaxis=-2.*width:1:width.*2;
myfunction= exp( - (gaussaxis.^2./2./width.^2));
myfunction=myfunction./sum(myfunction);
output=filtfilt(myfunction,1,mydata-mean(mydata))+mean(mydata);

