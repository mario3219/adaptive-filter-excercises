clc,clear,close all

% filter coefficients
h=0.5.^[0:4];
% input signal
u=randn(1000,1);
% filtered input signal == desired signal
d=conv(h,u);
% LMS
[e,w]=lms(0.1,5,u,d);

function [e,w] = lms(mu,M,u,d)
    wcalc(M);
    function w_next = wcalc(n)
        if n <= 0
            w_next = 0;
        else
            w_past = wcalc(n-1);
            e = d-w_past'*u;
            w = w_past+mu*u*e;
        end
    end
end