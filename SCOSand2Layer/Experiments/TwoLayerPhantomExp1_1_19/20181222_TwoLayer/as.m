    for a = 1:5
        for b = 2:5
            for c = 2:4
                j = j + 1;
                data = squeeze(Allcorrset(a,b, taurange, c));
                semilogx(tau, data); hold on;
            end
        end
    end