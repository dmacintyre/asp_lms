clear;
clc;

N = 100000;
noise_pwr = -15;
rmax = 4;

r = randi([0 rmax-1],1,N);
angle = r*((2*pi)/(rmax));
angle_noise = angle + wgn(1,N,noise_pwr);

amp_noise = wgn(1,N,noise_pwr);
amp_noise = amp_noise + 1;

baseband_samples = amp_noise .* exp(1j*angle_noise)*exp(1j*pi/4);

% Transmitted Samples
plot(baseband_samples, 'x')

%channel = [1];
channel = [1 0.17 0.13 0.6 0.4 0.1];

y = conv(baseband_samples, channel, 'same');

plot(y, 'x')
axis([-2 2 -2 2 ]);

title('QPSK Receive Constellation')
xlabel('In-Phase Amplitude')
ylabel('Quadrature Amplitude')

