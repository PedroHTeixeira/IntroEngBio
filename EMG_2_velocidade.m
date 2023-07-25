clear;
close all;
clc;
%% open file
v1_data = Open_File_MAdq('DadosEMG_keith_fs2kHz_bipolar_04-jul-2023\keith_s2_v1.madq');
v2_data = Open_File_MAdq('DadosEMG_keith_fs2kHz_bipolar_04-jul-2023\keith_s2_v2.madq');
v3_data = Open_File_MAdq('DadosEMG_keith_fs2kHz_bipolar_04-jul-2023\keith_s2_v3.madq');
function [signal_f_f5, d1] = pre_process(all_data)
%%Obtendo Sinal Cru
fs = all_data.Fs; % Hz
signal_cru = all_data.ARQdigCal(1:3,:); % emg
signal_acel = all_data.ARQcanalesADC;
n_amostras = length(signal_cru);
t = [0: n_amostras - 1]/fs;

%% Plot Do EMG
figure;
subplot(2,1,1);
plot(t, signal_cru(1,:),'b',t, signal_cru(2,:),'r',t, signal_cru(3,:),'k');
legend('EMG-ch1', 'EMG-ch2', 'EMG-ch3');
xlabel('Time [s]'); ylabel('V');

%% detrend
signal_cru_det = detrend(signal_cru');

%% notch 60 Hz
w0 = 60/(fs/2);
bw = w0/35;
[num,den] = pei_tseng_notch(w0,bw);
signal_f = filtfilt(num,den, signal_cru_det);

%% notch 120 Hz
w0 = 120/(fs/2);
bw = w0/35;
[num,den] = pei_tseng_notch(w0,bw);
signal_f_2 = filtfilt(num,den, signal_f);

%% filtro band pass
% fizemos o filtro passa-banda para comparar com o filtro passa-alto + passa-baixo
f_bp = [70, 150];
order = 2;
[b,a] = butter(order, f_bp/(fs/2), "bandpass");
signal_f_f3 = filtfilt(b, a, signal_f_2);

% Modulo
signal_f_f4 = sqrt(signal_f_f3 .^2);

%Passa Baixa
fb = 4; % Hz
order = 2;
[B,A] = butter(order, fb/(fs/2));
RMS = filtfilt(B, A, signal_f_f4);

% Media Movel
ordem = 2000;
AA = 1;
BB = ones(1,ordem)/ordem;
signal_f_f5 = filtfilt(BB, AA, RMS);

% Derivada Primeira
d1 = diff(signal_f_f5);
row_of_zeros = zeros(1, size(d1, 2));
d1_with_zeros = [d1; row_of_zeros];
%--- plot
figure;
subplot(2,1,1);

%canal 1 flexor
%canal 2 extensor

plot(t, signal_f_f5);
xlabel('Time [s]'); ylabel('V');
legend('ch1', 'ch2', 'ch3');
subplot(2,1,2);
plot(t, d1_with_zeros );
xlabel('Time [s]'); ylabel('V');
legend('ch1', 'ch2', 'ch3');

endfunction


% Linear de Fisher
 function [class1_data, class2_data] = janelar(d1, size)
tamanho_janela = size; % Tamanho da janela desejada tava 18
passo = size; % Passo de deslocamento entre as janelas Tem q ver se a janela disso eh equivalente

ch1 = d1(:,1);
ch2 = d1(:,2);

% Divisão do sinal em janelas pior q deu
num_janelas = floor((length(ch2) - tamanho_janela) / passo) + 1; % Número de janelas
extensor = zeros(num_janelas, tamanho_janela); % Matriz para armazenar as janelas

for i = 1:num_janelas
    inicio = (i - 1) * passo + 1; % Índice de início da janela
    fim = inicio + tamanho_janela - 1; % Índice de fim da janela
    extensor(i, :) = ch2(inicio:fim); % Copia a janela do sinal para a matriz de janelas
end

% Divisão do sinal em janelas
num_janelas = floor((length(ch1) - tamanho_janela) / passo) + 1; % Número de janelas
flexor = zeros(num_janelas, tamanho_janela); % Matriz para armazenar as janelas

for i = 1:num_janelas
    inicio = (i - 1) * passo + 1; % Índice de início da janela
    fim = inicio + tamanho_janela - 1; % Índice de fim da janela
    flexor(i, :) = ch1(inicio:fim); % Copia a janela do sinal para a matriz de janelas
end
%extensor = extensor(2:num_janelas, :);
%flexor = flexor(2:num_janelas,:) ;

%for i  = 1:2:num_janelas
%    if i <= num_janelas
%      figure
%      subplot(2,2,1);
%      plot(flexor(i, :))
%      subplot(2,2,2);
%      plot(extensor(i, :))
%    endif
%    if i+1 <= num_janelas
%      subplot(2,2,3);
%      plot(flexor(i+1, :))
%      subplot(2,2,4);
%      plot(extensor(i+1, :))
%    endif
%end


% class 1 = repouso
% class 2 = extensao
% class 3 = flexao
class1_data= zeros(ceil(num_janelas/2),2);
class2_data= zeros(ceil(num_janelas/2),2);


for i  = 1:2:num_janelas
   if i <= num_janelas-1
   class1_data(((i+1)/2), :)= [min(extensor(i , :)), min(flexor(i, :))];
   endif
   if i+1 <= num_janelas-1
   class2_data(((i+1)/2), :)= [min(extensor(i+1 , :)), min(flexor(i+1, :))];
   endif
end
endfunction
[signal_f_f5, d1]= pre_process(v1_data);
[class1_data, class2_data] = janelar(d1, 28000);
v1 = class1_data + class2_data;

[signal_f_f5, d1]= pre_process(v2_data);
[class1_data, class2_data] = janelar(d1, 24000);
v2 = class1_data + class2_data;

[signal_f_f5, d1]= pre_process(v3_data);
[class1_data, class2_data] = janelar(d1, 20000);
v3 = class1_data + class2_data;
% Dados de exemplo (duas classes com 2 características cada)


% Dados de exemplo (3 classes com 2 características cada)
class1_data = v1
class2_data = v2
class3_data = v3

figure
scatter(class1_data(:, 1),class1_data(:, 2))
hold on
scatter(class2_data(:, 1),class2_data(:, 2))
scatter(class3_data(:, 1),class3_data(:, 2))
legend( 'v1', 'v2', 'v3');
hold off

% Concatenando os dados das três classes em uma única matriz
all_data = [class1_data; class2_data; class3_data];

% Cálculo das médias das classes
mean_class1 = mean(class1_data);
mean_class2 = mean(class2_data);
mean_class3 = mean(class3_data);

% Cálculo da matriz de dispersão dentro das classes (SW)
SW = cov(class1_data) + cov(class2_data) + cov(class3_data);

% Cálculo da matriz de dispersão entre as classes (SB)
SB = (mean_class1 - mean_class2)' * (mean_class1 - mean_class2) + ...
     (mean_class1 - mean_class3)' * (mean_class1 - mean_class3) + ...
     (mean_class2 - mean_class3)' * (mean_class2 - mean_class3);

% Cálculo da matriz de projeção ótima (W)
W = pinv(SW) * SB;

% Projeção dos dados de exemplo no espaço de recursos selecionado
class1_data_projected = class1_data * W;
class2_data_projected = class2_data * W;
class3_data_projected = class3_data * W;

% Plot dos dados projetados
figure;
scatter(class1_data_projected(:, 1), class1_data_projected(:, 2), 'red', 'filled');
hold on;
scatter(class2_data_projected(:, 1), class2_data_projected(:, 2), 'blue', 'filled');
scatter(class3_data_projected(:, 1), class3_data_projected(:, 2), 'green', 'filled');

% Configurações do gráfico
title('Projeção dos Dados em Espaço de Recursos Transformado');
xlabel('Característica 1');
ylabel('Característica 2');
legend('Classe 1', 'Classe 2', 'Classe 3');
grid on;
hold off;
