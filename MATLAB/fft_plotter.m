clear;
clc;
clf;

x = dlmread('asp_lms-master/Modelsim/lms_weights.txt');
expected = [0.25 0.01 0 0.27 0 0 0 0 0 0 0 0 0 0 0 0];

error = dlmread('asp_lms-master/Modelsim/lms_error.txt');

for i = length(x)-1:length(x)
    x_ax = 0:(2*pi)/2047:2*pi;
    x_ax = x_ax / (pi);
    taps = x(i,:);
    taps = taps/((2^15)-1);
    fft_taps = fft(taps,2048);
    fft_expected = fft(expected,2048);
    clf;
    subplot(2,1,1)
    plot(x_ax,10*log10(abs(fft_taps)));
    hold on
    plot(x_ax,10*log10(abs(fft_expected)));
    legend('Magnitude Response of VHDL LMS Weights', 'Magnitude Response of System Weights');
    title('Magnitude Response of LMS Weights')
    xlabel('Normalized Frequency *pi')
    ylabel('Magnitude')
    
    subplot(2,1,2)
    plot(error(1:i)/((2^15)-1))
    title('LMS Error Signal')
    xlabel('Iteration')
    ylabel('Error')
    pause(0.00000001)
end


