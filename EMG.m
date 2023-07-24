clear;
close all;
clc;
%% open file
all_data = Open_File_MAdq('DadosEMG_keith_fs2kHz_bipolar_04-jul-2023\keith_s2_v1.madq');

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

% Linear de Fisher
tamanho_janela = 20000; % Tamanho da janela desejada tava 18
passo = 20000; % Passo de deslocamento entre as janelas Tem q ver se a janela disso eh equivalente

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
extensor = extensor(2:num_janelas, :);
flexor = flexor(2:num_janelas,:) ;

for i  = 1:3:num_janelas
  if i <= num_janelas-1
    figure
    subplot(3,2,1);
    plot(flexor(i, :))
    subplot(3,2,2);
    plot(extensor(i, :))
    endif
     if i+1 <= num_janelas-1
    subplot(3,2,3);
     plot(flexor(i+1, :))
    subplot(3,2,4);
    plot(extensor(i+1, :))
  endif
  if i+2 <= num_janelas-1
    subplot(3,2,5);
     plot(flexor(i+2, :))
    subplot(3,2,6);
    plot(extensor(i+2, :))
   endif
end

% class 1 = repouso
% class 2 = extensao
% class 3 = flexao
class1_data= zeros(ceil(num_janelas/3),2);
class2_data= zeros(ceil(num_janelas/3),2);
class3_data= zeros(ceil(num_janelas/3),2);


% o intervalo q ta ruim !!!
for i  = 1:3:num_janelas
   if i <= num_janelas-1
   class1_data(((i+2)/3), :)= [mean(extensor(i , :)), mean(flexor(i, :))];
   endif
   if i+1 <= num_janelas-1
   class2_data(((i+2)/3), :)= [mean(extensor(i+1 , :)), mean(flexor(i+1, :))];
   endif
   if i+2 <= num_janelas-1
    class3_data(((i+2)/3), :)= [mean(extensor(i+2, :)), mean(flexor(i+2, :))];
   endif
end
% calma vamo ver as janelas concordo cntg, quer tentar o tal do fisher n sei
figure
scatter(class1_data(:, 1),class1_data(:, 2))
hold on
scatter(class2_data(:, 1),class2_data(:, 2))
scatter(class3_data(:, 1),class3_data(:, 2))
%class2_data, class3_data) kkkkkkkkkkkkk
legend('repouso', 'extensao', 'flexao');
hold off
% Função para calcular a matriz de dispersão dentro das classes (SW)
function SW = within_class_scatter(class_data)
    num_classes = length(class_data);
    num_features = size(class_data{1}, 2);
    SW = zeros(num_features, num_features);

    for i = 1:num_classes
        class_mean = mean(class_data{i});
        num_samples = size(class_data{i}, 1);
        centered_data = class_data{i} - repmat(class_mean, num_samples, 1);
        SW = SW + centered_data' * centered_data;
    end
end



% Cálculo das matrizes de dispersão dentro das classes (SW)
SW = within_class_scatter({class1_data, class2_data, class3_data});

% Cálculo das médias das classes
mean_class1 = mean(class1_data);
mean_class2 = mean(class2_data);
mean_class3 = mean(class3_data);

% Cálculo da matriz de dispersão entre as classes (SB)
SB = (mean_class1 - mean_class2)' * (mean_class1 - mean_class2) + ...
     (mean_class1 - mean_class3)' * (mean_class1 - mean_class3) + ...
     (mean_class2 - mean_class3)' * (mean_class2 - mean_class3);

% Cálculo da matriz de projeção ótima (W) ta e agr kkkk como usa isso
W = pinv(SW) * SB;

% Projeção dos dados de exemplo no espaço de recursos selecionado
class1_data_projected = class1_data * W;
class2_data_projected = class2_data * W;
class3_data_projected = class3_data * W;

% Exibição das projeções
disp('Projeção dos dados da Classe 1:');
disp(class1_data_projected);
disp('Projeção dos dados da Classe 2:');
disp(class2_data_projected);
disp('Projeção dos dados da Classe 3:');
disp(class3_data_projected);

% Vetor de direção da reta de Fisher
direcao_fisher = W(:, 1);

% Pontos médios projetados para cada classe
ponto_medio_class1 = mean(class1_data_projected);
ponto_medio_class2 = mean(class2_data_projected);
ponto_medio_class3 = mean(class3_data_projected);

% Plot dos dados projetados
figure;
scatter(class1_data_projected(:, 1), class1_data_projected(:, 2), 'red', 'filled');
hold on;
scatter(class2_data_projected(:, 1), class2_data_projected(:, 2), 'blue', 'filled');
scatter(class3_data_projected(:, 1), class3_data_projected(:, 2), 'green', 'filled');

% Plot das linhas de separação
line([ponto_medio_class1(1), ponto_medio_class1(1) + direcao_fisher(1)], ...
     [ponto_medio_class1(2), ponto_medio_class1(2) + direcao_fisher(2)], 'Color', 'red', 'LineWidth', 2);
line([ponto_medio_class2(1), ponto_medio_class2(1) + direcao_fisher(1)], ...
     [ponto_medio_class2(2), ponto_medio_class2(2) + direcao_fisher(2)], 'Color', 'blue', 'LineWidth', 2);
%line([ponto_medio_class3(1), ponto_medio_class3(1) + direcao_fisher(1)], ...
     %[ponto_medio_class3(2), ponto_medio_class3(2) + direcao_fisher(2)], 'Color', 'green', 'LineWidth', 2);

% Configurações do gráfico
title('Projeção dos Dados em Espaço de Recursos Transformado com Linhas de Separação');
xlabel('Característica 1');
ylabel('Característica 2');
legend('Classe 1', 'Classe 2', 'Classe 3', 'Linha de Separação Classe 1', 'Linha de Separação Classe 2', 'Linha de Separação Classe 3');
grid on;
hold off;
%figure
%plot(janelas(2,:))
%% Acelerometro com  filtro passa baixo
%f_lp = 5;  % Hz
%order = 5;
%b,a] = butter(order, f_lp/(fs/2), "low");
%signal_f_acel = filtfilt(b, a, signal_acel');


