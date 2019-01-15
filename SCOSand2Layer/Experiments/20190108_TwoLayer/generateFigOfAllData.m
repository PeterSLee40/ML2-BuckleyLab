range = 5:80
for a = 1:size(allcorrset,1)
    for b = 2:size(allcorrset,2) - 1
        for d = 4
            semilogx(DelayTime(range),squeeze(allcorrset(a,b,range,d)));
            hold on;
        end
    end
end