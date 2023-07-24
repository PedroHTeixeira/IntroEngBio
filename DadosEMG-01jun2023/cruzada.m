%Funão de Correlação Cruzada Rxy(Thao);Densidade Espectral Cruzada Pxy(f)-
%21/06/2023
clear all
close all
clc

f=40; %Hz
fs=1000*f; % freq. amostragem
ts=1/fs; % tempo de amostragem
L=977;%97-977 %número primo para ter número do ciclos completos da seoide para evitar vazamento espectral
N=L*fs/f; %fs/f=N/L; onde L número primo
t=[0:N-1]*ts;
T=t(end); %tempo do sinal em segundos

%===Dois Ruídos Brancos independentes
 x=randn(1,N);
 y=randn(1,N);
 [Rxy_u, Lags_xy]=xcorr (x,y,'unbiased');
 N_Rxy_u=length(Lags_xy);
 Thao_u = Lags_xy*ts;
 T_u= Thao_u(end)-Thao_u(1);  % Período temporal(duração) do sinal Rxy_u
 Exy=abs(fft(Rxy_u)); % Note que a Rxy é de segunda ordem, i.e., Exy é o espectro de energia cruzada e não de potência
 N_Exy=length(Exy); % número de pontos do espectro de energia
 PSDxy_u=Exy/fs; % Densidade Espectral de Potência cruzada, sendo a sua unidade (V^2/Hz)
 df_PSDxy_u=1/T_u;  % resolução espectral da PSDxy
 Esc_f_PSDxy_u=[0:N_Exy-1]*df_PSDxy_u;
 figure
 subplot(3,1,1)
 plot(t,x,'b',t,y,'r--')
 legend('x:ruído branco','y:ruído branco')
 xlabel('t (s)')
 subplot(3,1,2)
 plot(Thao_u,Rxy_u)
 xlabel('Thao (s)')
 ylabel ('Rxy')
 title ('Rxy não viciada')
 subplot(3,1,3)
 plot(Esc_f_PSDxy_u,PSDxy_u)
 xlabel('Hz')
 ylabel ('V^2/Hz')
 title ('PSDxy Cruzada')

%=====(z=seno de 40 Hz) com (y=ruído branco)
fase=0;
A=1; % amplitude em voltios (V)
z=A*sin(2*pi*f*t + fase);

%===Rxy não viciada
 [Rzy_u, Lags_zy]=xcorr (z,y,'unbiased');
 N_Rzy_u=length(Lags_zy);
 Thao_u = Lags_zy*ts;
 T_u= Thao_u(end)-Thao_u(1);  % Período temporal(duração) do sinal Rxy_u
 Ezy=abs(fft(Rzy_u)); % Note que a Rxy é de segunda ordem, i.e., Exy é o espectro de energia cruzada e não de potência
 N_Ezy=length(Ezy); % número de pontos do espectro de energia
 PSDzy_u=Ezy/fs; % Densidade Espectral de Potência cruzada, sendo a sua unidade (V^2/Hz)
 df_PSDzy_u=1/T_u;  % resolução espectral da PSDxy
 Esc_f_PSDzy_u=[0:N_Ezy-1]*df_PSDzy_u;

 figure
 subplot(3,1,1)
 plot(t,z,'b',t,y,'r--')
 legend('z:seno','y:ruído branco')
 xlabel('t (s)')
 subplot(3,1,2)
 plot(Thao_u,Rzy_u)
 xlabel('Thao (s)')
 ylabel ('Rzy')
 title ('Rzy não viciada')
 subplot(3,1,3)
 plot(Esc_f_PSDzy_u,PSDzy_u)
 xlabel('Hz')
 ylabel ('V^2/Hz')
 title ('PSDzy Cruzada')

%===== (w=ruido branco+seno 40Hz) com (v=ruido branco + seno de 70 Hz)
w=x+z;
f2=70; % freq
v=y+A*sin(2*pi*f2*t + fase);
%===Rxy não viciada
 [Rwv_u, Lags_wv]=xcorr (w,v,'unbiased');
 N_Rwv_u=length(Lags_wv);
 Thao_u = Lags_wv*ts;
 T_u= Thao_u(end)-Thao_u(1);  % Período temporal(duração) do sinal Rxy_u
 Ewv=abs(fft(Rwv_u)); % Note que a Rxy é de segunda ordem, i.e., Exy é o espectro de energia cruzada e não de potência
 N_Ewv=length(Ewv); % número de pontos do espectro de energia
 PSDwv_u=Ewv/fs; % Densidade Espectral de Potência cruzada, sendo a sua unidade (V^2/Hz)
 df_PSDwv_u=1/T_u;  % resolução espectral da PSDxy
 Esc_f_PSDwv_u=[0:N_Ewv-1]*df_PSDwv_u;

 figure
 subplot(3,1,1)
 plot(t,v,'b',t,y,'r--')
 legend('z:ruído branco + seno 40 Hz','y:ruído branco+ seno 70 Hz')
 xlabel('t (s)')
 subplot(3,1,2)
 plot(Thao_u,Rwv_u)
 xlabel('Thao (s)')
 ylabel ('Rwv')
 title ('Rwv não viciada')
 subplot(3,1,3)
 plot(Esc_f_PSDwv_u,PSDwv_u)
 xlabel('Hz')
 ylabel ('V^2/Hz')
 title ('PSDwv Cruzada')

%===== (w=ruido branco+seno 40Hz) com (ruido branco + seno de 70 Hz + seno de
%40 Hz s=v+z)
s=v+z;
 [Rws_u, Lags_ws]=xcorr (w,s,'unbiased');
 N_Rws_u=length(Lags_ws);
 Thao_u = Lags_ws*ts;
 T_u= Thao_u(end)-Thao_u(1);  % Período temporal(duração) do sinal Rxy_u
 Ews=abs(fft(Rws_u)); % Note que a Rxy é de segunda ordem, i.e., Exy é o espectro de energia cruzada e não de potência
 N_Ews=length(Ews); % número de pontos do espectro de energia
 PSDws_u=Ews/fs; % Densidade Espectral de Potência cruzada, sendo a sua unidade (V^2/Hz)
 df_PSDws_u=1/T_u;  % resolução espectral da PSDxy
 Esc_f_PSDws_u=[0:N_Ews-1]*df_PSDws_u;

 figure
 subplot(3,1,1)
 plot(t,w,'b',t,s,'r--')
 legend('w:ruído branco + seno 40 Hz','s:ruído branco+seno40Hz+seno70Hz')
 xlabel('t (s)')
 subplot(3,1,2)
 plot(Thao_u,Rws_u)
 xlabel('Thao (s)')
 ylabel ('Rws')
 title ('Rws não viciada')
 subplot(3,1,3)
 plot(Esc_f_PSDws_u,PSDws_u)
 xlabel('Hz')
 ylabel ('V^2/Hz')
 title ('PSDws Cruzada')


