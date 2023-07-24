clear;
close all;
clc;
% Passo 1: Preparação dos dados
% Suponha que você tenha duas classes (classe1 e classe2) e seus respectivos dados de treinamento (X1 e X2).

% Cálculo das médias
mean1 = mean(X1);
mean2 = mean(X2);

% Cálculo das matrizes de covariância
cov1 = cov(X1);
cov2 = cov(X2);

% Passo 2: Cálculo da função de Fisher
% Cálculo da matriz de dispersão entre as classes (SB)
SB = (mean1 - mean2)' * (mean1 - mean2) * (size(X1, 1) + size(X2, 1));

% Cálculo da matriz de dispersão dentro das classes (SW)
SW = (size(X1, 1) - 1) * cov1 + (size(X2, 1) - 1) * cov2;

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
X1_projected = X1 * selected_eigen_vectors;
X2_projected = X2 * selected_eigen_vectors;

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

