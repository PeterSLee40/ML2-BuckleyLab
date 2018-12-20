%%Time-stamp: "2005-12-19 23:03:00 matlabuser"
%to filter the stroke signals
function output=strokefilter_new(mydata,myfiltersize)


%Filter data, however, if NaN, filtfilt doesnt work, so break into chunks
%where there are no NaNs
nans=find(isnan(mydata));
if isempty(nans)
    %gaussian sliding filter
    width=ceil(myfiltersize./2)/2; 
    gaussaxis=-2.*width:1:width.*2;
    myfunction= exp( - (gaussaxis.^2./2./width.^2));
    myfunction=myfunction./sum(myfunction);
    output=filtfilt(myfunction,1,mydata-mean(mydata))+mean(mydata);

else
    for i=1:length(nans)-1
        diff(i)=nans(i+1)-nans(i);
    end
    minchunk=nans(find(diff>5));
    maxchunk=nans(find(diff>5)+1);
    %Smooth the inital part of the data until reaching first NaN
    if length(1:min(nans)-1)>3*length(-2*(ceil(myfiltersize./2)/2):1:(ceil(myfiltersize./2)/2)*2)
        %gaussian sliding filter
        width=ceil(myfiltersize./2)/2; 
        gaussaxis=-2.*width:1:width.*2;
        myfunction= exp( - (gaussaxis.^2./2./width.^2));
        myfunction=myfunction./sum(myfunction);
        output(1:min(nans)-1)=filtfilt(myfunction,1,mydata(1:min(nans)-1)-mean(mydata(1:min(nans)-1)))+mean(mydata(1:min(nans)-1));
    end
    %Smooth the final part of the data after last NaN
    if length(max(nans)+1:length(mydata))>3*length(-2*(ceil(myfiltersize./2)/2):1:(ceil(myfiltersize./2)/2)*2)
        %gaussian sliding filter
        width=ceil(myfiltersize./2)/2; 
        gaussaxis=-2.*width:1:width.*2;
        myfunction= exp( - (gaussaxis.^2./2./width.^2));
        myfunction=myfunction./sum(myfunction);
        output(max(nans)+1:length(mydata))=filtfilt(myfunction,1,mydata(max(nans)+1:end)-mean(mydata(max(nans)+1:end)))+mean(mydata(max(nans)+1:end));
    else
        output(max(nans)+1:length(mydata))=mydata(max(nans)+1:end);
    end
    %Smooth chunks, but only if they are at least 3 times greater than the
    %filter size, otherwise filtfilt doesnt work.
    for l=1:length(minchunk)
        chunk=minchunk(l)+1:maxchunk(l)-1;
        if length(chunk)>3*length(-2*(ceil(myfiltersize./2)/2):1:(ceil(myfiltersize./2)/2)*2)
            %gaussian sliding filter
            width=ceil(myfiltersize./2)/2; 
            gaussaxis=-2.*width:1:width.*2;
            myfunction= exp( - (gaussaxis.^2./2./width.^2));
            myfunction=myfunction./sum(myfunction);
            output(chunk)=filtfilt(myfunction,1,mydata(chunk)-mean(mydata(chunk)))+mean(mydata(chunk));
        else
            output(chunk)=mydata(chunk);
        end
        clear chunk
    end
    output(nans)=NaN;
    
end

