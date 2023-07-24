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
tamanho_janela = 14000; % Tamanho da janela desejada tava 18
passo = 14000; % Passo de deslocamento entre as janelas Tem q ver se a janela disso eh equivalente

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

for i  = 1:2:num_janelas
    if i <= num_janelas
      figure
      subplot(2,2,1);
      plot(flexor(i, :))
      subplot(2,2,2);
      plot(extensor(i, :))
    endif
    if i+1 <= num_janelas
      subplot(2,2,3);
      plot(flexor(i+1, :))
      subplot(2,2,4);
      plot(extensor(i+1, :))
    endif
end

% class 1 = repouso
% class 2 = extensao
% class 3 = flexao
class1_data= zeros(ceil(num_janelas/2),2);
class2_data= zeros(ceil(num_janelas/2),2);


for i  = 1:2:num_janelas
   if i <= num_janelas-1
   class1_data(((i+1)/2), :)= [mean(extensor(i , :)), mean(flexor(i, :))];
   endif
   if i+1 <= num_janelas-1
   class2_data(((i+1)/2), :)= [mean(extensor(i+1 , :)), mean(flexor(i+1, :))];
   endif
end

figure
scatter(class1_data(:, 1),class1_data(:, 2))
hold on
scatter(class2_data(:, 1),class2_data(:, 2))

legend( 'extensao', 'flexao');
hold off
% Passo 1: Preparação dos dados
% Suponha que você tenha duas classes (classe1 e classe2) e seus respectivos dados de treinamento (X1 e X2).

% Cálculo das médias
mean1 = mean(class1_data);
mean2 = mean(class2_data);

% Cálculo das matrizes de covariância
cov1 = cov(class1_data);
cov2 = cov(class2_data);

% Passo 2: Cálculo da função de Fisher
% Cálculo da matriz de dispersão entre as classes (SB)
SB = (mean1 - mean2)' * (mean1 - mean2) * (size(class1_data, 1) + size(class2_data, 1));

% Cálculo da matriz de dispersão dentro das classes (SW)
SW = (size(class1_data, 1) - 1) * cov1 + (size(class2_data, 1) - 1) * cov2;

% Cálculo da matriz de projeção ótima (W)
W = pinv(SW) * SB;

% Cálculo dos autovalores e autovetores de W
[eigen_vectors, eigen_values] = eig(W);

% Passo 3: Seleção de recursos
% Ordenar os autovalores em ordem decrescente
[eigen_values_sorted, sort_index] = sort(diag(eigen_values), 'descend');

% Selecionar os autovetores correspondentes aos maiores autovalores
selected_eigen_vectors = eigen_vectors(:, sort_index(1:k));

% Passo 4: Classificação
% Projetar os dados de treinamento e teste no espaço de recursos selecionado
X1_projected = class1_data * selected_eigen_vectors;
X2_projected = class2_data * selected_eigen_vectors;

% Classificar um novo exemplo (x) usando a regra do vizinho mais próximo
function label = classify(x, X1_projected, X2_projected, k)
    distances = sum((x - [X1_projected; X2_projected]).^2, 2);
    [~, min_index] = min(distances);
    if min_index <= size(X1_projected, 1)
        label = 'classe1';
    else
        label = 'classe2';
    end
end

% Exemplo de classificação de um novo exemplo (x_test)
x_test = [1, 2, 3]; % Novo exemplo a ser classificado
x_test_projected = x_test * selected_eigen_vectors;
predicted_label = classify(x_test_projected, X1_projected, X2_projected, k);
disp(predicted_label);

%figure
%plot(janelas(2,:))
%% Acelerometro com  filtro passa baixo
%f_lp = 5;  % Hz
%order = 5;
%b,a] = butter(order, f_lp/(fs/2), "low");
%signal_f_acel = filtfilt(b, a, signal_acel');


