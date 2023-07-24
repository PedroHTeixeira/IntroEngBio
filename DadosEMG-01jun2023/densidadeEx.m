%Exemplo Densidade Espectral de Potência (PSD)Pxx - Aula 5 - 21/06/2023
clear all
close all
clc

%=====senoidal
f=40; %Hz
fs=100*f; % freq. amostragem
ts=1/fs; % tempo de amostragem
L=977;%97-977 %número primo para ter número do ciclos completos da seoide para evitar vazamento espectral
N=L*fs/f; %fs/f=N/L; onde L número primo
t=[0:N-1]*ts;
T=t(end); %tempo do sinal em segundos
fase=0;
A=1; % amplitude em voltios (V)
x=A*sin(2*pi*f*t + fase);

%+++++++Rxx(Thao)=E[x(t)x(t-Thao)]
%Rxx(0)=E[x(t)^2]=A^2/2;  Para A=1; Rxx(0)=1/2
[Rxx_u, Lags]=xcorr (x,'unbiased');
Thao_u = Lags*ts; % Escala de tempo da Rxx
T_u= Thao_u(end)-Thao_u(1);  % Período temporal(duração) do sinal Rxx_u

%===(PSD) Densidade Espectral de Potência (V^2/Hz); vide slide 13 (aula 5 PSB)
% A PSD é a Potência por unidade de frequência. Então, por ser densidade a
% potência em uma frequência f é dada pela área entre  [f-df/2 f+df/2]; onde
% df é a resolução espectral.
%Em 40 Hz devo ter uma potência de (A^2/2)/2, pois são dois componentes espectrais; para A=1; Pxx(f=40)=1/4=0.25
%Então a área = 0.25=df*h; em este exemplo a df=0.2062; portanto h=1.2124 (V^2/Hz)

Exx=abs(fft(Rxx_u)); % Note que a Rxx é de segunda ordem, i.e., Exx1 é o espectro de energia e não de potência
N_Exx=length(Exx); % número de pontos do espectro de energia
PSDxx_u=Exx/fs; % Densidade Espectral de Potência, sendo a sua unidade (V^2/Hz)
df_PSDxx_u=1/T_u;  % resolução espectral da PSDxx
Esc_f_PSDxx_u=[0:N_Exx-1]*df_PSDxx_u;
figure
subplot(3,1,1)
plot(t,x)
xlabel('t (s)')
title('Senoidal de 40 Hz')
subplot(3,1,2)
plot(Thao_u,Rxx_u)
xlabel('Thao (s)')
ylabel ('Rxx')
title ('Rxx não viciada')
subplot(3,1,3)
plot(Esc_f_PSDxx_u,PSDxx_u)
xlabel('Hz')
ylabel ('V^2/Hz')
title ('Densidade Espectral de Potência')

%Espectro (spectrum) de potência Exx/Npontos
figure
plot(Esc_f_PSDxx_u,Exx/N_Exx)
xlabel('Hz')
ylabel ('V^2')
title ('Espectro de Potência - Espectrum')

%Ruído Branco
y=randn(1,N);
[Ryy_u, Lags]=xcorr (y,'unbiased');
Thao_u = Lags*ts;
Eyy=abs(fft(Ryy_u)); % Note que a Rxx é de segunda ordem, i.e., Exx1 é o espectro de energia e não de potência
N_Eyy=length(Eyy); % número de pontos do espectro de energia
PSDyy_u=Eyy/fs; % Densidade Espectral de Potência, sendo a sua unidade (V^2/Hz)
df_PSDyy_u=1/T_u;  % resolução espectral da PSDxx
Esc_f_PSDyy_u=[0:N_Eyy-1]*df_PSDyy_u;
figure
subplot(3,1,1)
plot(t,y)
xlabel('t (s)')
title('Ruído branco')
subplot(3,1,2)
plot(Thao_u,Ryy_u)
xlabel('Thao (s)')
ylabel ('Ryy')
title ('Ryy não viciada')
subplot(3,1,3)
plot(Esc_f_PSDyy_u,PSDyy_u)
xlabel('Hz')
ylabel ('V^2/Hz')
title ('Densidade Espectral de Potência')

%======Ruído Branco + Senoidal
z=0.05*x+y; %variar a RSR, mudando a amplitude do seno (x)
[Rzz_u, Lags]=xcorr (z,'unbiased');
Thao_u = Lags*ts;
Ezz=abs(fft(Rzz_u)); % Note que a Rxx é de segunda ordem, i.e., Exx1 é o espectro de energia e não de potência
N_Ezz=length(Ezz); % número de pontos do espectro de energia
PSDzz_u=Ezz/fs; % Densidade Espectral de Potência, sendo a sua unidade (V^2/Hz)
df_PSDzz_u=1/T_u;  % resolução espectral da PSDxx
Esc_f_PSDzz_u=[0:N_Ezz-1]*df_PSDzz_u;
figure
subplot(3,1,1)
plot(t,z)
xlabel('t (s)')
title('Ruído branco + Senoidal')
subplot(3,1,2)
plot(Thao_u,Rzz_u)
xlabel('Thao (s)')
ylabel ('Rzz')
title ('Rzz não viciada')
subplot(3,1,3)
plot(Esc_f_PSDzz_u,PSDzz_u)
xlabel('Hz')
ylabel ('V^2/Hz')
title ('Densidade Espectral de Potência')

%====== Ree Ruído Branco de banda estreita
f1=10;
ordem=2;
[b a]=butter(ordem,f1/(fs/2));
aux=filter(b,a,y);
e=aux;
[Ree_u, Lags]=xcorr (e,'unbiased');
Thao_u = Lags*ts;
Eee=abs(fft(Ree_u)); % Note que a Rxx é de segunda ordem, i.e., Exx1 é o espectro de energia e não de potência
N_Eee=length(Eee); % número de pontos do espectro de energia
PSDee_u=Eee/fs; % Densidade Espectral de Potência, sendo a sua unidade (V^2/Hz)
df_PSDee_u=1/T_u;  % resolução espectral da PSDxx
Esc_f_PSDee_u=[0:N_Eee-1]*df_PSDee_u;
figure
subplot(3,1,1)
plot(t,e)
xlabel('t (s)')
title('Ruído branco de banda estreita')
subplot(3,1,2)
plot(Thao_u,Ree_u)
xlabel('Thao (s)')
ylabel ('Ree')
title ('Ree não viciada')
subplot(3,1,3)
plot(Esc_f_PSDee_u,PSDee_u)
xlabel('Hz')
ylabel ('V^2/Hz')
title ('Densidade Espectral de Potência')

%===Ruído Branco de banda larga
f1=fs/20;
ordem=2;
[b a]=butter(ordem,f1/(fs/2));
l=filter(b,a,y);
[Rll_u, Lags]=xcorr (l,'unbiased');
Thao_u = Lags*ts;
Ell=abs(fft(Rll_u)); % Note que a Rxx é de segunda ordem, i.e., Exx1 é o espectro de energia e não de potência
N_Ell=length(Ell); % número de pontos do espectro de energia
PSDll_u=Ell/fs; % Densidade Espectral de Potência, sendo a sua unidade (V^2/Hz)
df_PSDll_u=1/T_u;  % resolução espectral da PSDxx
Esc_f_PSDll_u=[0:N_Ell-1]*df_PSDll_u;
figure
subplot(3,1,1)
plot(t,l)
xlabel('t (s)')
title('Ruído branco de banda larga')
subplot(3,1,2)
plot(Thao_u,Rll_u)
xlabel('Thao (s)')
ylabel ('Rll')
title ('Rll não viciada')
subplot(3,1,3)
plot(Esc_f_PSDll_u,PSDll_u)
xlabel('Hz')
ylabel ('V^2/Hz')
title ('Densidade Espectral de Potência')
