clc,clear,close all

R = [2 1; 1 2];
p = [6 4]';
Jmin = 5;
winit = [0 0]';
mu = 0.1;
N = 1000;
sd(mu,winit,N,R,p,Jmin)

function [w,J] = sd(mu,winit,N,R,p,Jmin)
    w = 0;
    wcalc(N);
    J = Jmin + (w-inv(R)*p)'*R*(w-inv(R)*p);
    function w_next = wcalc(n)
        if n <= 0
            w_next = winit;
        else
            w_past = wcalc(n-1);
            w_next = w_past+mu*(p-R*w_past);
            w = w_next;
        end
    end
end
