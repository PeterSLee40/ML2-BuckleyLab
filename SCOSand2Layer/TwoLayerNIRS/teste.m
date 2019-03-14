range = 1:100
for i = range
    a(i) = fun([i*.01 x0(2) x0(3) x0(4) x0(5)]);
end
plot(range*.01, log(a))
fminsearch(