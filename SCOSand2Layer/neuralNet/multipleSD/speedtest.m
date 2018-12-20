
tic
a = 0;
b = 0;
for i = 1:1000000000
    a = 5 + 3;
end
toc
tic
for i = 1:1000000000
    a = plus(5, 3);
end
toc