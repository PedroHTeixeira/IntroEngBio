% 
% Version:  1.1
% Date:     19-may-2023
% Autor:    Molina Vidal D.A. by Estudios MA
% Contact:  estudiosma01@gmail.com
% Download more functions on our Github:
% https://github.com/estudiosma/matlab
%
% ma_fft_plot(data, fs, new_figure)
% Plot in a new figure the magnitude of the discrete Fourier transform 
% (DFT) of 'data'.
%
% Example:
% data = ;  % 'data' can be an Nx1 vector or matrix
% fs = ;    % sampling frequency
% new_figure = 1;   % 1 to plot on a new figure (this is a default value). 
% Any other value to plot on an open figure.
% ma_fft_plot(data, fs, new_figure);
%
function ma_fft_plot(data, fs, new_figure)
% default value
if  nargin < 3
    new_figure = 1;
end

NNFT = length(data);   tamano = length(data);
%----- FFT
Y=fft(data,NNFT)/tamano;
f = fs/2*linspace(0,1,NNFT/2);
magnitude = abs(Y(1:NNFT/2, :));

if new_figure == 1
    figure;
end

plot(f, magnitude); grid minor
xlabel('Freq [Hz]');   ylabel('Amp');
