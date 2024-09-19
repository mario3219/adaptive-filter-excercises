clc,clear

p = [6 4]';
R = [2 1; 1 2];
w0 = [0 0]';

v = calc(20);
plot(v(1,:))
hold on
plot(v(2,:))

function result = calc(n)
    result = [];
    w(n)
    function w_next = w(n)
        my = 0.5*1/3;
        R = [2 1; 1 2];
        p = [6 4]';
    
        if n <= 0
            w_next = [100 100]';
        else
            w_past = w(n-1);
            w_next = w_past+my*(p-R*w_past);
            result = [result w_next];
        end
    end
end