clc,clear,close all

% filter coefficients
h=0.5.^[0:4];
% input signal
u=randn(1000,1);
% filtered input signal == desired signal
d=conv(h,u);
% LMS
[e,w]=lms(0.1,5,u,d);