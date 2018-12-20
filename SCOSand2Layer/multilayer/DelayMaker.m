first_delay=2e-7;
for I=1:16,
    DelayTime(I) = I*first_delay;
end
 
for J=1:30,
    for I=0:7,
        DelayTime(I+(J-1)*8+17) = DelayTime((J-1)*8+16+I)+first_delay*(2^J);
    end
end
 
DelayTime=DelayTime(1:256);