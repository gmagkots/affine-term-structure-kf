function kalman_test2
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
    for  n = 1:15
        y = y.*1.05;
        [vec,cov] = evolve_filter(obj,y);
        if n==14
            y_save   = y;
            vec_save = vec;
            cov_save = cov;
        end
    end

    fprintf('Containers from regular filter\n');
    vec
    cov

    obj2 = Kalman_filter(c,d,T,Z,Q,H,vec_save,cov_save,1);
    [vec2,cov2] = evolve_filter(obj2,y_save*1.05);
    fprintf('Containers from new filter\n');
    vec2
    cov2
end
