classdef Kalman_filter < handle
%  Purpose:
%
%    Initialize the state vector based on the form of the state space model
%    and update it for incoming measurements according to the Kalman filter
%    process. The covariance matrix of the state vector is also calculated.
%
%  Input:
%
%    State space parameter matrices and vectors required for the filter
%    equations, as described in Harvey (1990). For the specific projects we
%    consider them time invariant. This means that they may be loaded only
%    once at the class constructor. Their description is in the properties
%    section. In addition, the measurement vector is input to the driver 
%    function evolve_filter for use in loops.
%
%  Output:
%
%    The updated state vector a_vec and its covariance matrix Pmat in the
%    evolve_filter function.
%
%  Reference:
%
%    Forecasting, structural time series models and the Kalman filter
%    A.C. Harvey, 1990
%    
%  Notes:
%
%    We eliminate the multiplicative matrix R to the state disturbances eta
%    (equation 3.1.3a in Harvey) by considering R equal to a unity matrix.
%    This implies that the state disturbances vector eta has the same
%    dimensions as the state vector alpha (indicated as a_vec here).
%
%    If the measurement vector y_vec is zero, then perform out-of-sample
%    forecasting (December 2011).
%
%  Author : Georgios Magkotsios
%  Version: November 2011
%  Updates: December 2011 (filter prediction)
%  Updates: January  2012 (additional filter stability criteria)
%
   properties (Access = 'private')
       ibar     % barrier (penalty) control for imposed stability criteria
       Npar     % dimension of (hidden) state vector
       Ndat     % dimension of measurement vector

       a_vec    % Npar x 1 state vector
       y_vec    % Ndat x 1 measurement vector
       c_vec    % Npar x 1 additive constant vector to state equation
       d_vec    % Ndat x 1 additive constant vector to measurement equation
       nu_vec   % Ndat x 1 innovation vector

       Tmat     % Npar x Npar state transition matrix
       Zmat     % Ndat x Npar measurement matrix
       Qmat     % Npar x Npar state disturbances covariance matrix
       Hmat     % Ndat x Ndat measurement disturbances covariance matrix

       Fmat     % Ndat x Ndat utility matrix whose inverse is only used
       Kmat     % Npar x Ndat Kalman gain matrix
       Pmat     % Npar x Npar Kalman covariance matrix

       Fdet     % determinant of Fmat, used in log-likelihood estimation
       logL     % negative log-likelihood function to be maximized
       barrier  % barrier to the log-likelihood function (penalty scheme)
   end

   methods
       function KF = Kalman_filter(c,d,T,Z,Q,H,a0,P0,ibar)
       %  Purpose:
       %
       %    Class constructor
       %
       %  Input:
       %
       %    The symbols used are the same as in Harvey (1990).
       %    c : state constant vector
       %    d : measurement constant vector
       %    T : state transition matrix
       %    Z : measurement parameter matrix
       %    Q : state covariance matrix
       %    H : measurement covariance matrix
       %    a0: initial estimate for the state vector (set 0 for default)
       %    P0: initial estimate for the state vector covariance matrix
       %

       % determine stability check flag
           KF.ibar = ibar;

       % arguments c, d, and a0 must be (or transposed to) column vectors
           c  = c(:);
           d  = d(:);
           a0 = a0(:);

           KF.Npar  = size(c,1);
           KF.Ndat  = size(d,1);

           KF.c_vec = c;
           KF.d_vec = d;

           KF.Tmat  = T;
           KF.Zmat  = Z;
           KF.Qmat  = Q;
           KF.Hmat  = H;

           KF.Fmat  = zeros(KF.Ndat,KF.Ndat);
           KF.Kmat  = zeros(KF.Npar,KF.Ndat);
           KF.Pmat  = zeros(KF.Npar,KF.Npar);

           KF.barrier = nan;%2.5e4;%7e8;

           initial_estimates(KF,a0,P0);
       end

       function [a_vec,Pmat,logL] = evolve_filter(KF,measurement)
           % argument 'measurement' must be a column vector
           KF.y_vec = measurement(:);

           evaluate_Kalman_covariance(KF);
           evaluate_Kalman_estimator(KF);
           update_log_likelihood(KF);

           a_vec = KF.a_vec;
           Pmat  = KF.Pmat;
           logL  = KF.logL;
       end
    
       % set and get functions for the log-likelihood function
       function set_logL(KF,value)
           KF.logL = value;
       end
       function value = get_logL(KF)
           value = KF.logL;
       end

       % set and get functions for the state vector and its covariance
       function set_state_vec(KF,value)
           KF.a_vec = value;
       end
       function value = get_state_vec(KF)
           value = KF.a_vec;
       end
       function set_state_cov(KF,value)
           KF.Pmat = value;
       end
       function value = get_state_cov(KF)
           value = KF.Pmat;
       end

       % set and get functions for state space containers, useful when
       % these containers are time dependent
       function set_state_mat(KF,value)
           KF.Tmat = value;
       end
       function value = get_state_mat(KF)
           value = KF.Tmat;
       end
       function set_meas_mat(KF,value)
           KF.Zmat = value;
       end
       function value = get_meas_mat(KF)
           value = KF.Zmat;
       end
       function set_state_const_vec(KF,value)
           KF.c_vec = value;
       end
       function value = get_state_const_vec(KF)
           value = KF.c_vec;
       end
       function set_meas_const_vec(KF,value)
           KF.d_vec = value;
       end
       function value = get_meas_const_vec(KF)
           value = KF.d_vec;
       end

   end

   methods (Access = 'private')
       % function prototype of the stability conditions check
       [res,msg] = Kalman_stability(KF)

       function initial_estimates(KF,a0,P0)
       % Estimate the initial values for the state vector and its
       % covariance matrix based on the unconditional distribution of the
       % state vector (Harvey, equation 3.3.18). Within 10 iterations the
       % covariance matrix tends to converge.
           if (a0 == 0)
               KF.a_vec = (eye(KF.Npar) - KF.Tmat)\KF.c_vec;
           else
               KF.a_vec = a0;
           end

           if (P0 == 0)
               for n = 1:10
                   KF.Pmat = KF.Tmat*KF.Pmat*KF.Tmat' + KF.Qmat;
               end
               %KF.Pmat = zeros(size(KF.Qmat));
           else
               KF.Pmat = P0;
           end
       end

       function evaluate_Kalman_covariance(KF)
           if (KF.y_vec ~= 0)
           % Harvey, equations 3.2.4b and 3.2.4c (with gain matrix replaced)
               evaluate_Fmat(KF);
               KF.Kmat = KF.Tmat*KF.Pmat*KF.Zmat'*KF.Fmat;
               KF.Pmat = KF.Tmat*KF.Pmat*KF.Tmat' - ...
                         KF.Kmat*KF.Zmat*KF.Pmat*KF.Tmat' + KF.Qmat;
           else
           % Harvey, equation 3.5.7b for filter prediction
               KF.Pmat = KF.Tmat*KF.Pmat*KF.Tmat' + KF.Qmat;
               KF.Fdet = -1;    % to avoid the calculation of logL
           end
       end

       function evaluate_Kalman_estimator(KF)
       % Harvey, equation 3.2.4a (or 3.5.7a for filter prediction)
       % rearranged to avoid duplicate calculation for the innovation term
       %    KF.a_vec = (KF.Tmat - KF.Kmat*KF.Zmat)*KF.a_vec + ...
       %                KF.Kmat*KF.y_vec + (KF.c_vec - KF.Kmat*KF.d_vec);
           if (KF.y_vec ~= 0)
               evaluate_innovation(KF);
           else
               KF.nu_vec = 0;
               KF.Kmat   = 0;
           end
           KF.a_vec = KF.Tmat*KF.a_vec + KF.c_vec + KF.Kmat*KF.nu_vec;
       end

       function evaluate_Fmat(KF)
       % Harvey, equation 3.2.3c (store inverse directly)
           Ftemp   = KF.Zmat*KF.Pmat*KF.Zmat' + KF.Hmat;
           KF.Fdet = det(Ftemp);
           KF.Fmat = inv(Ftemp);
       end

       function evaluate_innovation(KF)
       % Harvey, equations 3.4.4 and 3.4.6 replaced in equation 3.2.4a
           KF.nu_vec = KF.y_vec - (KF.Zmat*KF.a_vec + KF.d_vec);
       end

       function update_log_likelihood(KF)
       % Harvey, equation 3.4.5 for the logL function (negative for
       % maximization). Enforce related stability conditions for
       % time-invariant models by using a very simple "penalty method"
       % (barrier) scheme, i.e. change the value of logL to a large value 
       % (for negative logL) when a stability condition is violated to 
       % force the optimization algorithm in a direction change. Additional
       % penalty methods include positive values for the lambda parameters
       % in the optimization class optimize_logL.
           dim = max(size(KF.Fmat));
           if (isfinite(KF.Fmat) & KF.Fdet > 0 & isfinite(KF.Fdet))
               % verification of stability criteria
               if KF.ibar
                   [stable,stability_error] = Kalman_stability(KF);
               else
                   stable = true;
               end

               % update the log-likelihood function if applicable
               if stable
                   KF.logL = KF.logL + 1/2*(dim*log(2*pi) + ...
                      log(abs(KF.Fdet)) + KF.nu_vec'*KF.Fmat*KF.nu_vec);
               else
                   KF.logL = KF.barrier;
                   fprintf(stability_error);
               end
           else
               KF.logL = KF.barrier;
               %fprintf(['Matrix F in the Kalman filter may have ' ...
               %         'infinities or its determinant may be negative.\n']);
           end

       end

   end

end