for i = 1:5
    asfas = squeeze(corrset(i,5:80,2:4));
    asfas = asfas';
    asfas = asfas(:);
    asdf(i) = net(asfas);
end
mean(asdf)