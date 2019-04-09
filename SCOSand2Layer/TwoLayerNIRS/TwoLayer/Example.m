%% Setup
clear;

mu=[0.005, 0.01, 1.5, 0.5]; %1/mm
L=10; %mm
x0=[0.0075, 1, 5, 0.0075, 1, 1]; %[1/mm, 1/mm, mm, 1/mm, 1/mm, -]
rhoFwd=linspace(5, 30, 100); %mm
rhoInv=linspace(5, 30, 10); %mm
amp_err_scl=1; %Percent
phi_err_scl=pi/180; %rad

%% Forward Model
[amp, phi]=TwoLayerReflectance(mu, L, rhoFwd);

figure(1); clf;
subplot(2, 1, 1);
plot(rhoFwd, log(rhoFwd'.^2.*amp));
ylabel('ln(\rho^2I_{AC}) (-)');
xlabel('\rho (mm)');
title(sprintf(['Forward Model\n'...
    'X=[%.4f 1/mm, %.2f 1/mm, %.1f mm, %.4f 1/mm, %.2f 1/mm]\n'],...
    [mu(1), mu(3), L, mu(2), mu(4)]));

subplot(2, 1, 2);
plot(rhoFwd, unwrap(phi));
xlabel('\rho (mm)');
ylabel('\phi (rad)');

%% Create Noisy Data
[amp, phi]=TwoLayerReflectance(mu, L, rhoInv);
amp_err=amp*amp_err_scl/100;
amp=amp+randn(size(amp)).*amp_err;

phi_err=ones(size(phi))*phi_err_scl;
phi=phi+randn(size(phi)).*phi_err;

data=[rhoInv', phi, amp, phi_err, amp_err];

%% Inverse Model
[X, fitCurve, costf, info]=TwoLayer_InverseMarquardt(x0, data);

figure(2); clf;
semilogy(costf(1:info(5)));
xlabel('k');
ylabel('F(k)');
title('Cost');

figure(3); clf;
subplot(2, 1, 1);
errorbar(rhoInv, amp, amp_err, '.'); hold on;
plot(fitCurve(:, 1), fitCurve(:, 3)); hold off;
set(gca, 'YScale', 'log');
xlabel('\rho (mm)');
ylabel('I_{AC} (1/mm^2)');
legend('Data', 'Fit');
title(sprintf(['Inverse Model\n'...
    'X_{true}=[%.4f 1/mm, %.2f 1/mm, %.1f mm, %.4f 1/mm, %.2f 1/mm]\n'...
    'X_{fit}=[%.4f 1/mm, %.2f 1/mm, %.1f mm, %.4f 1/mm, %.2f 1/mm]'],...
    [mu(1), mu(3), L, mu(2), mu(4)], X(1:end-1)));

subplot(2, 1, 2);
errorbar(rhoInv, phi, phi_err, '.'); hold on;
plot(fitCurve(:, 1), fitCurve(:, 2)); hold off;
xlabel('\rho (mm)');
ylabel('\phi (rad)');