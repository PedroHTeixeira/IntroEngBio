clear;
close all;
clc;
%% open file
all_data = Open_File_MAdq("DadosEmg-01jun2023\bruno_s1_v3.madq");
%S1_v2 = 59-61
%v1 = 50-51
%v3 = 57-60
%%
fs = all_data.Fs; % Hz
signal_cru = all_data.ARQdigCal(1:3,:); % emg


n_amostras = length(signal_cru);
t = [0: n_amostras - 1]/fs;





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
%figure;
%subplot(2,1,1);
%plot(t, signal_f);
%xlabel('Time [s]'); ylabel('V');
%legend('ch1', 'ch2', 'ch3');
%%subplot(2,1,2);
%ma_fft_plot(signal_f, fs, 0);


%% filtro band pass
% fizemos o filtro passa-banda para comparar com o filtro passa-alto + passa-baixo
f_bp = [57, 60];
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



