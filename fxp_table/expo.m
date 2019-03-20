
clear all;
close all;
clc;
image_resolution = 320;
anchors = [10,23,  27,70,  70,123,  77,242,  159,284,  319,306];

x_total_bits = 8;
y_total_bits = 16;
errmax = 1E-5; % Set the maximum allowed error
nptsmax = [];

xmin = -4;
% xmax = max_input_to_exp; % Set the maximum input of interest
xmax = 5; % Set the maximum input of interest

%%

funcstr = 'exp(x)';
% nptsmax = 256; % Specify the maximum number of points

% width_of_anchor = anchors(1:2:end);
% height_of_anchor = anchors(2:2:end);
min_anchors = min( anchors);
max_input_to_exp = ceil(log( ceil(image_resolution / min_anchors)));



% X_integer_part = floor( log2( max_input_to_exp) + 1);
X_integer_part = 3;
x_fraction = x_total_bits - X_integer_part;

fHandle = str2func(['@(x) ' funcstr]);
% Y_integer_part = floor( log2( ceil(image_resolution / min_anchors)) + 1);
Y_integer_part = 6;
y_fraction = y_total_bits - Y_integer_part;

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

save('lut_expo.mat','x_total_bits', 'x_fraction',...
    'y_total_bits', 'y_fraction', ...
    'fxp_x_axis', 'fxp_y_axis');
