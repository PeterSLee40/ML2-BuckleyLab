

index = 11e2
subplot(2,1,1);
semilogx(target(index,:));
hold on;
semilogx(input(index,:));
hold on;
semilogx(denoisenet1_10_400_bay(input(index,:)));
legend('no-noise','noise','net-corrected');
subplot(2,1,2);
error_nn = (target(index,:) - input(index,:)) ./ target(1,:) .* 100;
error_net = (target(index,:) - denoisenet1_10_400_bay(input(index,:))) ./ target(index,:) .*100;
semilogx(error_nn);
hold on;
semilogx(error_net);
hold on;
semilogx(zeros(1,60));
legend('noise','net-corrected', 'no-noise');
