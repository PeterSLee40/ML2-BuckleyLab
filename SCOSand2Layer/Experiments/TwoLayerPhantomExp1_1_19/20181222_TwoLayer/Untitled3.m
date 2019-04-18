close all
for i = [1 3 4 5 2]
    semilogx(DelayTime(5:100),squeeze(Allcorrset(i,2:5,5:100,3))); hold on;
end