clc;
clear;
close all;
% our main approach is to take fft of the signal and multiply it with
% transfer function of ach filter and take inverse of the result
%  LOAD AUDIO FILE
load handel         
% [y, Fs] = audioread('Bomboclat Fall.wav'); % gives y and Fs 
sound(y, Fs)
pause(3)
N = length(y);
t = (0:N-1)/Fs;

%  TIME DOMAIN
figure;
plot(t, y);
title('Original Signal - Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% 3. FFT ANALYSIS
X = fft(y);
magX = abs(X);

% we are only using half spectrum TO DISPLAY because for real values signals FFT
% repeats itself after half, conjugate symmetry so only half frequencies
% are useful
f = (0:N/2-1)*(Fs/N);
% N are total samples and Fs are samples per second
figure;
plot(f, magX(1:N/2));
title('Original Signal ki Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

%  Label the importannt components
hold on;

% DC component basicaly jaha 0 frequency ho or avgvalue of signal
plot(0, magX(1), 'ro', 'LineWidth', 2);

% 50–60 Hz interference
line([50 50], ylim, 'Color', 'r', 'LineStyle', '--');
line([60 60], ylim, 'Color', 'r', 'LineStyle', '--');

% Low high frequency boundary (im doing 2000 for visible difference)
xline(2000, '--y', 'LineWidth', 2);
legend('Spectrum','DC','50Hz','60Hz','Low High Freq');
% we can change these points but human range is 300 to 3400  so below that
% is ramble and above noise
fc_lp = 2000;
fc_hp = 2000;
fc1 = 2500;
fc2 = 3500;
f0 = 50;
% APPLY FILTERS USING FFT
X = fft(y);
k = 0:N-1;
% calculation  k lye full hi chahiye
f_full = k*(Fs/N);

% - LOW PASS 
H_lp = double(f_full <= fc_lp | f_full >= (Fs - fc_lp));
y_lp = ifft(X .* H_lp');

% - HIGH PASS
H_hp = double(f_full >= fc_hp & f_full <= (Fs - fc_hp));
y_hp = ifft(X .* H_hp');

%  BAND PASS 
H_bp = double((f_full >= fc1 & f_full <= fc2) | (f_full >= Fs-fc2 & f_full <= Fs-fc1));
y_bp = ifft(X .* H_bp');

%  NOTCH 
bw = 10;
H_notch = ones(size(f_full));

idx = (f_full > (f0-bw) & f_full < (f0+bw)) | (f_full > (Fs-(f0+bw)) & f_full < (Fs-(f0-bw)));

H_notch(idx) = 0;
y_notch = ifft(X .* H_notch');
%  TIME DOMAIN AFTER FILTER
figure;
plot(t, y_bp);
title('Filtered Signal - Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

disp('--- Frequency Info ---');
disp(['Sampling Frequency: ', num2str(Fs), ' Hz']);
disp('DC offset at 0 Hz');
disp('Powerline interference at 50–60 Hz');
disp('Low frequency noise: 0–100 Hz, 2000 here');
disp('Useful speech band: 300–3400 Hz, 2500 to 3500 here ');
disp('High frequency noise: >4000 Hz, 2000 here');
% ANALYSIS 

filters = {y_notch, y_hp, y_lp, y_bp};
names = {'Notch Filter', 'High Pass Filter', 'Low Pass Filter', 'Band Pass Filter'};

figure;

for i = 1:length(filters)

    y_temp = filters{i};
    Y_temp = fft(y_temp);
    magY_temp = abs(Y_temp);

    subplot(4,2,2*i-1);
    plot(t, y_temp);
    title([names{i} ' - Time Domain']);
    grid on;

    subplot(4,2,2*i);
    plot(f, magY_temp(1:floor(N/2)));
    title([names{i} ' - Frequency Domain']);
    grid on;

    sound(y_temp, Fs);
    pause(length(y_temp)/Fs + 0.5);

end