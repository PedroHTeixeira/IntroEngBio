%Exemplo Rxx, Espectro e Densidade Espectaral de Potência (PSD)
%%gerar um sinal senoidal de 40 Hz e realizar a análise no domínio da
%%frequência

clear all
close all
clc

f=40; %Hz
fs=1000*f; % freq. amostragem
ts=1/fs; % tempo de amostragem
L=97;%97 %número primo
N=L*fs/f; %fs/f=N/L; onde L número primo
t=[0:N-1]*ts;
T=t(end); %tempo do sinal em segundos
fase=0;
A=1; % amplitude em voltios (V)
x=A*sin(2*pi*f*t + fase);

%Estimador não viciado da função de autocorrelação Rxx
%+++++++Rxx(Thao)=E[x(t)x(t-Thao)]
%Rxx(0)=E[x(t)^2]=A^2/2;  Para A=1; Rxx(0)=1/2

%Rxx do seno
[Rxx_u, Lags]=xcorr (x,'unbiased');
Thao_u = Lags*ts;
figure
subplot(1,2,1)
plot(t,x) % ploto os primeiros 500 pontos do sinal no tempo
xlabel('t (s)')
title('Senoidal de 40 Hz')
subplot(1,2,2)
plot(Thao_u,Rxx_u)
xlabel('Thao (s)')
ylabel ('Rxx')
title ('Rxx não viciada')

%Ryy do ruido branco
y=randn(1,N);
[Ryy_u, Lags]=xcorr (y,'unbiased');
Thao_u = Lags*ts;
figure
subplot(1,2,1)
plot(t,y)
xlabel('t (s)')
title('Ruído Branco')
subplot(1,2,2)
plot(Thao_u,Ryy_u)
xlabel('Thao (s)')
ylabel ('Ryy')
title ('Ryy não viciada')

%======Rzz do Ruído Branco + Senoidal
z=10*x+y; %variar a RSR, mudando a amplitude do seno (x)
[Rzz_u, Lags]=xcorr (z,'unbiased');
Thao_u = Lags*ts;
figure
subplot(1,2,1)
plot(t,z)
xlabel('t (s)')
title('Ruído Branco+seno')
subplot(1,2,2)
plot(Thao_u,Rzz_u)
xlabel('Thao (s)')
ylabel ('Rzz')
title ('Rzz não viciada')

%====== Ree Ruído Branco de banda estreita
f1=10;
ordem=2;
[b a]=butter(ordem,f1/(fs/2));
aux=filter(b,a,y);
e=aux(1000:end);
[Ree_u, Lags]=xcorr (e,'unbiased');
Thao_u = Lags*ts;
figure
subplot(1,2,1)
plot(t(1000:end),e)
xlabel('t (s)')
title('Ruído Branco de banda estreita')
subplot(1,2,2)
plot(Thao_u,Ree_u)
xlabel('Thao (s)')
ylabel ('Ree')
title ('Ree não viciada')

%======histograma da amplitude do Ruído Branco de banda larga
f1=fs/20;
ordem=2;
[b a]=butter(ordem,f1/(fs/2));
l=filter(b,a,y);
[Rll_u, Lags]=xcorr (l,'unbiased');
Thao_u = Lags*ts;
figure
subplot(1,2,1)
plot(t,l)
xlabel('t (s)')
title('Ruído Branco de banda larga')
subplot(1,2,2)
plot(Thao_u,Rll_u)
xlabel('Thao (s)')
ylabel ('Rll')
title ('Rll não viciada')
