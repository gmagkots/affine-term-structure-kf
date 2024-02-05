function kalman_test
%  Purpose:
%
%    Test the Kalman filter class.
%
%  Input:
%
%    None.

    clc; clear;
    c = [0.0 0.0]';
    d = [0.0 0.0]';
    T = [0.5 0.3; 0 0.1];
    Z = [0.4 0.3; 0.5 0.4];
    Q = [0.2 0; 0 0.1];
    H = [0.2 0; 0 0.2];
    
    y = [0.3 0.4]';

    obj = Kalman_filter(c,d,T,Z,Q,H,0,0,1);
    for  n = 1:2
        %y = y.*1.1;
        [vec,cov] = evolve_filter(obj,y);
        vec
        cov
    end
    
end
