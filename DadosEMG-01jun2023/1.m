%%Exemplo 1
%%gerar um sinal senoidal de 40 Hz e realizar a análise no domínio da
%%frequência

clear all
close all
clc

f=40; %Hz
fs=1000*f; % freq. amostragem.....exercício fazer para diferentes fs
ts=1/fs; % tempo de amostragem
L=97;%97 %número primo
N=L*fs/f; %fs/f=N/L; onde L número primo
%N=1000;
t=[0:N-1]*ts;
T=t(end); %tempo do sinal em segundos
fase=0;%pi/2;
A=1;
x=A*sin(2*pi*f*t + fase);
%======histograma da amplitude do seno
figure
subplot(1,2,1)
plot(t,x)
subplot(1,2,2)
histogram (x,50,'Normalization','pdf')

%======histograma da amplitude do Ruído Branco
y=randn(1,N);
figure
subplot(1,2,1)
plot(t,y)
subplot(1,2,2)
histogram (y,50,'Normalization','pdf')

%======histograma da amplitude do Ruído Branco + Senoidal
z=10*x+y; %variar a RSR, mudando a amplitude do seno
figure
subplot(1,2,1)
plot(t,z)
subplot(1,2,2)
histogram (z,50,'Normalization','pdf')

%======histograma da amplitude do Ruído Branco de banda estreita
f1=40;
ordem=2;
[b a]=butter(ordem,f1/(fs/2));
bE=filter(b,a,y);
figure
subplot(1,2,1)
plot(t,bE)
subplot(1,2,2)
histogram (bE,50,'Normalization','pdf')

%======histograma da amplitude do Ruído Branco de banda larga
f1=fs/8;
ordem=2;
[b a]=butter(ordem,f1/(fs/2));
bL=filter(b,a,y);
figure
subplot(1,2,1)
plot(t,bL)
subplot(1,2,2)
histogram (bL,50,'Normalization','pdf')

%=====Energia====
%seno
figure
subplot(1,2,1)
plot(t,x.^2)
subplot(1,2,2)
histogram (x.^2,50,'Normalization','pdf')

%ruído branco
figure
subplot(1,2,1)
plot(t,y.^2)
subplot(1,2,2)
histogram (y.^2,50,'Normalization','pdf')

