clc,clear,close all

Q = (1/sqrt(2))*[1 1;1 -2];
A = [3 0; 0 1];
R = Q*A*Q';
w = [2.6667 0.6667];
p = [6 4]';
Jmin = 5;
winit = [0;0];
mu1=1/3;
mu2=1/6;
N = 100;

[w1,J1] = sd(mu1,winit,N,R,p,Jmin);
[w2,J2] = sd(mu2,winit,N,R,p,Jmin);

v1=Q'*(w1-R\p*ones(1,N));
v2=Q'*(w2-R\p*ones(1,N));

plot([0:N-1],log(v2(1,:)));

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
