clear;
close all;
clc;
%% open file
all_data = Open_File_MAdq();
%%
fs = all_data.Fs; % Hz
signal_cru = all_data.ARQdigCal(1:3,:); % emg
signal_acel = all_data.ARQcanalesADC;   % acel

n_amostras = length(signal_cru);
t = [0: n_amostras - 1]/fs;

%VISUALIZAÇÃO DOS SINAIS
%% acel
figure(1)
plot(t, signal_acel(1,:),'b',t,signal_acel(2,:),'r',t,signal_acel(3,:),'k');
legend('eixo-X', 'eixo-Y', 'eixo-Z');
xlabel('Time [s]'); ylabel('V');



%% emg
figure;
subplot(2,1,1);
plot(t, signal_cru(1,:),'b',t, signal_cru(2,:),'r',t, signal_cru(3,:),'k');
legend('EMG-ch1', 'EMG-ch2', 'EMG-ch3');
xlabel('Time [s]'); ylabel('V');
%% detrend
signal_cru_det = detrend(signal_cru');
subplot(2,1,2);
%--- plot
plot(t, signal_cru_det);
xlabel('Time [s]'); ylabel('V');
legend('ch1', 'ch2', 'ch3');
ma_fft_plot(signal_cru_det, fs, 1);
%% notch 60 Hz
w0 = 60/(fs/2);
bw = w0/35;
[num,den] = iirnotch(w0,bw);
signal_f = filtfilt(num,den, signal_cru_det);

%--- plot
figure;
subplot(2,1,1);
plot(t, signal_f);
xlabel('Time [s]'); ylabel('V');
legend('ch1', 'ch2', 'ch3');
subplot(2,1,2);
ma_fft_plot(signal_f, fs, 0);

%% filtro passa alta
f_hp = 10;  % Hz
order = 2;
[b,a] = butter(order, f_hp/(fs/2), "high");
signal_f_f1 = filtfilt(b, a, signal_f);

%--- plot
figure;
subplot(2,1,1);
plot(t, signal_f_f1);
xlabel('Time [s]'); ylabel('V');
legend('ch1', 'ch2', 'ch3');
subplot(2,1,2);
ma_fft_plot(signal_f_f1, fs, 0);

%% filtro passa baixo
f_lp = 400;  % Hz
order = 2;
[b,a] = butter(order, f_lp/(fs/2), "low");
signal_f_f2 = filtfilt(b, a, signal_f_f1);

%--- plot
figure;
subplot(2,1,1);
plot(t, signal_f_f2);
xlabel('Time [s]'); ylabel('V');
legend('ch1', 'ch2', 'ch3');
subplot(2,1,2);
ma_fft_plot(signal_f_f2, fs, 0);

%% filtro band pass
% fizemos o filtro passa-banda para comparar com o filtro passa-alto + passa-baixo
f_bp = [10, 400];
order = 2;
[b,a] = butter(order, f_bp/(fs/2), "bandpass");

signal_f_f3 = filtfilt(b, a, signal_f);

%--- plot
figure;
subplot(2,1,1);
plot(t, signal_f_f3);
xlabel('Time [s]'); ylabel('V');
legend('ch1', 'ch2', 'ch3');
subplot(2,1,2);
ma_fft_plot(signal_f_f3, fs, 0);

%% acel
figure;
subplot(2,1,1);
plot(t, signal_acel);
xlabel('Time [s]'); ylabel('V');
legend('X', 'Y', 'Z');
subplot(2,1,2);
ma_fft_plot(signal_acel', fs, 0);

%% filtro passa baixo
f_lp = 20;  % Hz
order = 4;
[b,a] = butter(order, f_lp/(fs/2), "low");  
signal_f_acel = filtfilt(b, a, signal_acel');

%--- plot
figure;
subplot(2,1,1);
plot(t, signal_f_acel);
xlabel('Time [s]'); ylabel('V');
legend('X', 'Y', 'Z');
subplot(2,1,2);
ma_fft_plot(signal_f_acel, fs, 0);