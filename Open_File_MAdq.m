function signals = Open_File_MAdq(Path)
%Open_File_MAdq.m 
% 
%*** DESCRIPCION ***
%Funci�n para lectura de archivo binario generado desde el sotfware 
%del Sistema de Adquisici�n Multicanal de Se�ales Fisiol�gicas - MAdq.
%del Proyecto Plataforma Multicanala de Se�ales Fisiol�gicas y Estimulaci�n
%Multimodal
%
%La funci�n retorna variables que corresponden a las se�ales 
%fisiol�gicas o se�ales de prop�sito general guardadas en un set de captura 
%de se�ales. Adem�s, el archivo binairo contiene informaci�n de 
%marcas realizadas por el usuario durante la captura de datos, cantidad 
%paquetes recibidos, frecuencia de muestreo, entre otros.
% 
%*** HISTORICO DE VERSIONES REFERENCIA ***
%Este archivo se basa en los algoritmos de lectura de se�ales 
%generados por M. Cagy (2006), A. d'Affons�ca (2011, 2013) y P. Cevallos (2018)
%  Modificado por L. Guamba�a 20/01/2021
%  Modificado por L. Guamba�a y P. Cevallos 02/08/2022 
%  Modificado por Molina Vidal, D.A. 01-jun-2023
%   - Compatible con version de SW v11 (mar-2023)
%   - Compatible con versi�n de FW 1.4.2.0
%  Ultimas modificaicones:
%   - Adici�n; lectura de marcas generadas desde el SW
%   - Adici�n; lectura de numero de canales analogos
%   - Adici�n; seperaci�n canales analogos (var: ARQcanalesADC)
%   - Adici�n; separaci�n canales digitales (Trigger de ADSs, var: ARQTrigger)
%   - Conversi�n correcta de unidades (volts) para los canales anal�gicos.
% 
%*** VARIABLES DE SALIDA ***
% Variable ARQdig: Contiene la se�al sin procesa
% Variable ARQdigCal: Contiene la se�al procesada con valores de ganancia, offset, escalas
% Variable ARQstatusAD: Contiene la se�al del StatusAD
% Variable ARQTrigger: Contiene la se�al de los trigger si estos estan habilitados
% Variable ARQcanalesADC: Contiene la se�al de los ADC si estos estan habilitados
% 
% Example to open file:
% all_data = Open_File_MAdq();
% disp(all_data)
%
% *** VERSION ***
% V2.0.2
% Last modification: 01-jun-2023 by Molina Vidal, D.A.

%Archiva la ruta que contiene los datos (path)
if nargin == 0
    Dialogo = true;
end

%directorio predeterminado vac�o
path_arq = [];

if (nargin == 1)
    [path_arq,arq_name,est_arq] = fileparts(Path);
    
    if isempty(arq_name) || isempty(est_arq)
        Dialogo = true;
        if isempty(est_arq) && ~isempty(arq_name)
            path_arq = [path_arq,'\',arq_name];
        end
    else
        Dialogo = false;
        NombreARQdig = Path;
    end
end
    
%abre el di�logo de archivo con el directorio predeterminado    
if Dialogo
    [nameFile,PATH_]=uigetfile('*.madq','Seleccionar el archivo',path_arq);
    if nameFile==0
        signals = [];      %vuelve vac�o si se cancela la apertura
        return;
    end
    NombreARQdig=[PATH_,nameFile];
end

ARQ=fopen(NombreARQdig,'rb');

if ARQ<0
    error('�No se pudo abrir este archivo!', '�Error!');
    error('�Este archivo no se pudo abrir!')
end


% sinais.F_amost_in=[]; % Inicializa a freq. muestreo con una matriz vacia;
% Sirve para permitir la inclusi�n de un valor "predeterminado" en el cuadro de di�logo
% de frec. de muestreo, cuando sea posible obtenerlo del encabezado del archivo.

%Archivo formato PEB:
% elseif tipo==4,
Bph=1; %Bytes por elemento de encabezado
Bpa=4; %Bytes por muestra
preci='int32';
%preci='float64';

%Lectura de Cabecera
NChar=fread(ARQ,1,'uint8'); % se lee primero tama�o del vector de version PEB
signals.Version_PEB=setstr(fread(ARQ,NChar,'uchar')');%leemos el vector con el tama�o leido anteriormente
NChar=fread(ARQ,1,'uint8'); %leemos el tama�o del buffer de la version del Firmware
signals.Version_Firmware=setstr(fread(ARQ,NChar,'uchar')');

signals.Fs=fread(ARQ,1,'uint16');

Numero_Canales = fread(ARQ,1,'uint8'); 
signals.Numero_Canales= Numero_Canales;

Numero_Canales_Trigger = fread(ARQ,1,'uint8'); 
signals.Numero_Canales_Trigger= Numero_Canales_Trigger;

Numero_Canales_ADC = fread(ARQ,1,'uint8'); 
signals.Numero_Canales_ADC= Numero_Canales_ADC;

Pos_Canales_ADC = fread(ARQ,1,'uint8'); 
signals.Pos_Canales_ADC= Pos_Canales_ADC;

Pos_Canales_Trigger = fread(ARQ,1,'uint8'); 
signals.Pos_Canales_Trigger= Pos_Canales_Trigger;


%Lee Nombre de los canales
for i=1:Numero_Canales
    NChar=fread(ARQ,1,'uint8');
    signals.Nombre_Canales{i}=setstr(fread(ARQ,NChar,'uchar')');
end
%Lee Nombre de los canales de trigger
for i=1:Numero_Canales_Trigger
    NChar=fread(ARQ,1,'uint8');
    signals.Nombre_Canales_Tg{i}=setstr(fread(ARQ,NChar,'uchar')');
end
%Lee Ganancia de los canales
for i=1:Numero_Canales
    signals.Ganancia{i}=fread(ARQ,1,'float64');
end
%Lee Escalas de los canales
for i=1:Numero_Canales
    signals.Escalas{i}=fread(ARQ,1,'float64');
end
%Lee Offset de los canales
for i=1:Numero_Canales
    signals.Offset{i}=fread(ARQ,1,'float64');
end
%Leo la fecha
signals.Ano_Examen=fread(ARQ,1,'uint16');
signals.Mes_Examen=fread(ARQ,1,'uint8');
signals.Dia_Examen=fread(ARQ,1,'uint8');
signals.Hora_Examen=fread(ARQ,1,'uint8');
signals.Minutos_Examen=fread(ARQ,1,'uint8');
signals.Segundos_Examen=fread(ARQ,1,'uint8');
%Lee Comentarios
NChar=fread(ARQ,1,'uint8');
signals.Comentario=setstr(fread(ARQ,NChar,'uchar')');

Numero_Marcas = 100;
%Lee Posicion de las marcas
for i=1:Numero_Marcas
    signals.Posicion_Marcas{i}=fread(ARQ,1,'uint32');
end
%Lee Nombre de las marcas
for i=1:Numero_Marcas
    NChar=fread(ARQ,1,'uint8');
    signals.Nombre_Marcas{i}=setstr(fread(ARQ,NChar,'uchar')');
end


Tam_header=ftell(ARQ); %tama�o cabecera 

Ncanales_StatusAD =  Numero_Canales + ceil((Numero_Canales/8)); %Contiene el numero de canales mas el numero de status AD
fseek(ARQ,0,'eof');    %salta al final del archivo
NFrame_Count = 1;  %Variable para los datos del framecount
Tam_arq = (ftell(ARQ)-Tam_header)/Bpa;   %tama�o del archivo que contiene las muestras
Numero_muestras =fix(Tam_arq/(Ncanales_StatusAD + NFrame_Count + Numero_Canales_ADC)); %Tama�o de la se�al en n�mero de muestras intercaladas
Tam_arq = Numero_muestras*(Ncanales_StatusAD + NFrame_Count + Numero_Canales_ADC);   %Corrige el tama�o para que coincida con un n�mero entero de bytes
fseek(ARQ,Tam_header,'bof'); %omitir el encabezado

[ARQd,sr]=fread(ARQ,Tam_arq,'int32');

%ARQdig=reshape(ARQdig,Ncanales,Numero_muestras/2);   %ensambla la matriz con canales en filas y muestras en columnas
ARQd=reshape(ARQd,(Ncanales_StatusAD + NFrame_Count + Numero_Canales_ADC), Numero_muestras);   %ensambla la matriz con canales en filas y muestras en columnas

%Obtiene solo las se�ales de los canales
for k = 1:Numero_Canales,
       ARQdig(k,:) = ARQd(k,:);
end
signals.ARQdig = ARQdig;

%Se�al de los canales calibrados
of = cell2mat(signals.Offset)'*ones(1, Numero_muestras);
gan = cell2mat(signals.Ganancia)'*ones(1, Numero_muestras);
esca = cell2mat(signals.Escalas)'*ones(1, Numero_muestras);
% signals.ARQdig2 = (cell2mat(signals.ARQdig) + signals.Offset*ones(1,Numero_muestras)).*(signals.Ganancia*ones(1,Numero_muestras));  %escalona os valores
signals.ARQdigCal = ((ARQdig - of).*esca)./gan;  %escalona los valores

%Obtiene solo las se�ales del statusAD
%ARQstatusAD= 1;
for k = Numero_Canales + 1:Ncanales_StatusAD,
       ARQstatusAD(k-Numero_Canales,:) = ARQd(k,:);
end
signals.ARQstatusAD = ARQstatusAD;

%Obtiene el valor de los Canales de Trigger
%Comprobar el codigo para sacar el valor de los trigger
if (Numero_Canales_Trigger > 0),
    for k = 1 : Numero_muestras
        for j = 1 : Numero_Canales_Trigger,
           signals.ARQTrigger (j, k) = bitget(ARQstatusAD(1, k), j); %FFFFEF
        end
    end
end


%Obtiene solo las se�ales de los canales analogos
if (Numero_Canales_ADC > 0),
    for k = Numero_Canales + 3:(Ncanales_StatusAD + NFrame_Count + Numero_Canales_ADC),
           ARQcanalesADC(k-Numero_Canales-2,:) = ARQd(k,:)*2*3.3/4095;
    end
	signals.ARQcanalesADC = ARQcanalesADC;
else
    signals.ARQcanalesADC = 0;
end


%Obtiene solo las se�ales del frameCount
FrameCount(1,:) = ARQd(Ncanales_StatusAD + NFrame_Count,:);
signals.FrameCount = FrameCount;


signals.Numero_muestras = Numero_muestras;
signals.Path = NombreARQdig;   %Ruta de archivo elegida

signals.ARQcanalesADC_units = "Volts";
signals.ARQdigCal_units = "Volts";

fclose(ARQ);

%Para la visualizacion de las se�ales de Trigger es necesario separa la
%se�al ARQstatusAD en donde cada valor son 24bits y esta conformado como 
%1100 + 8 bits LOFF_STATP + 8 bits LOFF_STATN + 4 bits GPIO 
%Los 4 bits del GPIO esta desgnado como  GPIO4, GPIO3, GPIO2, GPIO1.