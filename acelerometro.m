%ACELEROMETRO

clear;
close all;
clc;
%% open file
all_data = Open_File_MAdq("DadosEmg-01jun2023\bruno_s1_v2.madq");
%%
fs = all_data.Fs; % Hz
signal_cru = all_data.ARQdigCal(1:3,:); % emg
signal_acel = all_data.ARQcanalesADC; 
% acel

n_amostras = length(signal_cru);
t = [0: n_amostras - 1]/fs;

%VISUALIZAÇÃO DOS SINAIS
%% acel
figure(1)
plot(t, signal_acel(1,:),'b',t,signal_acel(2,:),'r',t,signal_acel(3,:),'k');
legend('eixo-X', 'eixo-Y', 'eixo-Z');
xlabel('Time [s]'); ylabel('V');

%% acel
figure;
subplot(2,1,1);
plot(t, signal_acel);
xlabel('Time [s]'); ylabel('V');
legend('X', 'Y', 'Z');
subplot(2,1,2);
ma_fft_plot(signal_acel', fs, 0);

%% filtro passa baixo
f_lp = 5;  % Hz
order = 5;
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