%%Exemplo 1
%%gerar um sinal senoidal de 40 Hz e realizar a análise no domínio da
%%frequência

clear all
close all
clc

f=40; %Hz
fs=10*f; % freq. amostragem
ts=1/fs; % tempo de amostragem
L=971;%97 %número primo
N=L*fs/f; %fs/f=N/L; onde L número primo
%N=1000;
t=[0:N-1]*ts;
T=t(end); %tempo do sinal em segundos
fase=0;%pi/2;
A=1;
x=A*sin(2*pi*f*t + fase);

%%DFT
Xf=fft(x);
re=1/T; % resolução espectral (Hz)
escala_f=[0:N-1]*re; %escala de frequência (Hz)
Re_Xf=real(Xf)/N; %Parte real da DFT escalada
Im_Xf=imag(Xf)/N; %Parte imaginária da DFT escalada
figure
subplot(3,1,1)
plot(t(1:500),x(1:500)) % ploto os primeiros 500 pontos do sinal no tempo
xlabel('t')
title('Senoidal de 40 Hz')
subplot(3,1,2)
plot(escala_f,Re_Xf)
xlabel('Hz')
title('Parte real da DFT')
subplot(3,1,3)
plot(escala_f,Im_Xf)
xlabel('Hz')
title('Parte imaginária da DFT')

%++++++++++++++
% Módulo quadrático da DFT
Xf2=abs(Xf).^2;
espectro_fase=angle(Xf)*180/pi; % fase em graus

figure
subplot(3,2,1)
plot(t,x)
xlabel('t')

subplot(3,2,3)
plot(escala_f,Xf2)
title('Módulo quadrático da DFT')
xlabel('Hz')
subplot(3,2,4)
plot(escala_f,espectro_fase)
title ('Espectro de fase')
xlabel('Hz')
%%%%%%%%
EspectroPotencia=Xf2/(N^2); % Espectro de potência
ind1=find(Xf2<0.001); % encontre potência < a 0.001
espectro_fase(ind1)=0;
espectro_fase_unwrap=unwrap(espectro_fase*pi/180)*180/pi; % fase em graus
ind2=find(abs(espectro_fase_unwrap)<0.001);
espectro_fase_unwrap(ind2)=0;
subplot(3,2,5)
plot(escala_f,EspectroPotencia)
title('Espectro de Potência')
xlabel('Hz')
subplot(3,2,6)
plot(escala_f,espectro_fase_unwrap)
title ('Espectro de fase-Unwrap')
xlabel('Hz')
