
clear all;
close all;
clc;

x_total_bits = 8;
y_total_bits = 8;
x_fraction = 4;
y_fraction = 8;

funcstr = '1./(1+exp(-x))'; % Define the sine function
% funcstr = 'x.^2'; % Define the sine function

xmin = -10; % Set the minimum input of interest
xmax = 10; % Set the maximum input of interest

errmax = []; % Set the maximum allowed error
nptsmax = 256; % Specify the maximum number of points

%sfix range in (-2^(8-1)):xscale:(2^(8-1)-xscale)
xscale = 2^-x_fraction; % Set the x data scaling
xdt = sfix(x_total_bits); % Set the x data type

yscale = 2^-y_fraction; % Set the y data scaling
ydt = ufix(y_total_bits); % Set the y data type

%   RNDMETH   rounding method.  'floor' (default), 'ceil', 'near', or 'zero'
rndmeth = 'floor'; % Set the rounding method


%   SPACING   allowed Spacing: 'pow2', 'even', or 'unrestricted' (default).
spacing = 'pow2';


[xdata, ydata, errworst] = fixpt_look1_func_approx(funcstr, ...
xmin,xmax,xdt,xscale,ydt,yscale,rndmeth,errmax,nptsmax,spacing);

fixpt_look1_func_plot(xdata,ydata,funcstr,xmin,xmax,xdt, ...
xscale,ydt,yscale,rndmeth);


if strcmp(ydt.Signedness,'Unsigned')
    sign_flag = 0;
else
    sign_flag = 1;
end

ntBP = numerictype(sign_flag,y_total_bits,-log2(yscale));

yBP1 = quantize(fi(ydata),ntBP);

figure; plot(xdata,yBP1,'-bo',xdata,ydata,'-ro');grid on;
title('Real value (Red) versus FXP -> floating(Blue)')

figure; plot(xdata*2^x_fraction,ydata*2^y_fraction,'-bo',...
            xdata*2^x_fraction,double(yBP1)*2^y_fraction,'-ro');grid on;
title('Real value -> FXP(Red) versus FXP(Blue)')

% figure; plot(xdata,abs(ydata-double(yBP1)),'-ko');grid on;


% % interpMethod=2 ??
yyyy = fixpt_interp1(xdata,ydata,xdata,xdt,xscale,ydt,yscale,rndmeth);

figure; plot(xdata,yyyy,'-bo',xdata,ydata,'-ro');grid on;

figure; plot(xdata*2^x_fraction,yyyy*2^y_fraction,'-bo',...
    xdata*2^x_fraction,ydata*2^y_fraction,'-ro');grid on;

figure; plot(xdata,abs(yyyy-ydata),'o-');grid on;

fxp_x_axis = xdata*2^x_fraction;
fxp_y_axis = yyyy*2^y_fraction;

save('lut_sigmoid.mat','x_total_bits', 'x_fraction',...
    'y_total_bits', 'y_fraction', ...
    'fxp_x_axis', 'fxp_y_axis');
