clear;
close all;
clc;
sinal = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; % Sinal de exemplo
tamanho_janela = 5; % Tamanho da janela desejada
passo = 1; % Passo de deslocamento entre as janelas

% Divisão do sinal em janelas
num_janelas = floor((length(sinal) - tamanho_janela) / passo) + 1 % Número de janelas
janelas = zeros(num_janelas, tamanho_janela); % Matriz para armazenar as janelas

for i = 1:num_janelas
    inicio = (i - 1) * passo + 1 % Índice de início da janela
    fim = inicio + tamanho_janela - 1 % Índice de fim da janela
    janelas(i, :) = sinal(inicio:fim); % Copia a janela do sinal para a matriz de janelas
end

% Exibição das janelas
disp(janelas);



