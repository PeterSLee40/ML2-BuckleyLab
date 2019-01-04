close all
for i = 1:3
    inputrange = input(1,i:3:end);
    semilogx(tau,inputrange); hold on;
end

for i = 1:3
    inputrange = g1s(i,:);
    semilogx(tau,inputrange); hold on;
end