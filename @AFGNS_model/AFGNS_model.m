classdef AFGNS_model < model_superclass
%  Purpose:
%
%    Estimates the yield term-structure according to the AFGNS model.
%
%  Input:
%
%    The AFGNS model containers.
%
%  Output:
%
%    None.
%
%  References:
%
%    1) J.H.E. Christensen, F.X. Diebold, G.D. Rudebusch,
%       Journal of Econometrics, 164, 4 (2011)
%    2) J.H.E. Christensen, F.X. Diebold, G.D. Rudebusch,
%       Econometrics Journal, 12, C33 (2009)
%    
%  Notes:
%
%    The state and measurement covariance matrices are initialized as lower
%    triangular (or diagonal) matrices. However, they are later redefined
%    by right-multiplying them with their transpose. This is done to allow
%    the initial parameters to have negative values, and ensure in addition
%    that the actual covariance will have positive variances. As a result,
%    the only constraint for the initial estimates is to have non-zero
%    values.
%
%    The variance terms in these matrices should always be non-zero to
%    ensure that the rank of the matrix is not decreased, and the stability
%    condition for the Kalman filter is not violated. It is possible for
%    some of the non-diagonal elements to be equal to zero, as long as the
%    outcome of the multiplication does not decrease the matrices' rank.
%
%  Author : Georgios Magkotsios
%  Version: November 2011
%
    properties (Access = 'protected')
        theta       % utility vector related to the state matrix
        kappa_mat   % utility matrix related to the state matrix
        sigma_mat   % volatility matrix related to the covariance
    end

    methods
        % class constructor
        function AFGNS = AFGNS_model(model_name,lambda,theta,kappa_mat, ...
                                     sigma_mat,meas_cov,use_fed_data)
            % ensure column vectors
            lambda = lambda(:);
            theta = theta(:);

            % read the yield data, store the number of issuance months
            AFGNS.use_fed_data = use_fed_data;
            if AFGNS.use_fed_data
                read_fed_data(AFGNS,false);
            else
                read_fama_bliss(AFGNS);
            end

            % save the model name
            if ~strcmpi(model_name(1:5),'AFGNS')
                model_name = ['AFGNS_' model_name];
            end
            AFGNS.model_name = model_name;

            % store the model parameters
            AFGNS.lambda    = lambda;
            AFGNS.theta     = theta;
            AFGNS.kappa_mat = kappa_mat;
            AFGNS.sigma_mat = sigma_mat;

            % define the state equation using a monthly step
            define_state_model(AFGNS,1/12);

            % define the measurement equation
            initialize_measurement_parameters(AFGNS);
            AFGNS.meas_cov        = meas_cov*meas_cov';

            % allocate the yield and state vector repository matrices
            Zdim                  = length(AFGNS.state_const_vec);
            AFGNS.yield           = zeros(AFGNS.issue_dates,length(AFGNS.maturity));
            AFGNS.state_array     = zeros(AFGNS.issue_dates,Zdim);
            AFGNS.hamilton_cov    = zeros(Zdim,Zdim,AFGNS.issue_dates);
            AFGNS.filter_cov      = zeros(Zdim,Zdim,AFGNS.issue_dates);
            AFGNS.parameter_cov   = zeros(Zdim,Zdim,AFGNS.issue_dates);

            % locate the number and indices of the non-zero elements in the
            % state space matrices
            AFGNS.state_par_idx   = find(kappa_mat)';
            AFGNS.state_cov_idx   = find(sigma_mat)';
            AFGNS.meas_cov_idx    = find(meas_cov)';

            % group model parameters in a single vector
            AFGNS.parameter_vector = [lambda' theta' kappa_mat(AFGNS.state_par_idx) ...
                sigma_mat(AFGNS.state_cov_idx) meas_cov(AFGNS.meas_cov_idx)];

            % define container length acronyms
            len_lambda    = length(AFGNS.lambda);
            len_const_vec = length(AFGNS.state_const_vec);
            len_kappa_mat = length(AFGNS.state_par_idx);
            len_sigma_mat = length(AFGNS.state_cov_idx);

            % set the param_vec_len vector (model container separator)
            AFGNS.param_vec_len = ...
                [len_lambda, ...
                 len_lambda+len_const_vec, ...
                 len_lambda+len_const_vec+len_kappa_mat, ...
                 len_lambda+len_const_vec+len_kappa_mat+len_sigma_mat, ...
                 length(AFGNS.parameter_vector)];
        end

        function super_obj = copy_superclass_object(AFGNS)
            super_obj = model_superclass;
            set_property_struct(super_obj,get_property_struct(AFGNS));
        end
    end

    methods (Access = 'private')
        function define_state_model(AFGNS,dt)
        % for continuous time models you have to convert the volatility 
        % matrix into a one-month conditional covariance matrix
            AFGNS.state_par       = expm(-AFGNS.kappa_mat*dt);
            AFGNS.state_cov       = volatility_to_covariance(AFGNS,dt, ...
                                     AFGNS.kappa_mat,AFGNS.sigma_mat);
            AFGNS.state_const_vec = ...
                (eye(5) - expm(-AFGNS.kappa_mat*dt))*AFGNS.theta;
        end

        function initialize_measurement_parameters(AFGNS)
            maturity = AFGNS.maturity;
            AFGNS.meas_par = ones(length(maturity),5);
            AFGNS.meas_par(:,2)  =  (1 - exp(-AFGNS.lambda(1)*maturity))./...
                                             (AFGNS.lambda(1)*maturity);
            AFGNS.meas_par(:,3)  =  (1 - exp(-AFGNS.lambda(2)*maturity))./...
                                             (AFGNS.lambda(2)*maturity);
            AFGNS.meas_par(:,4)  =  (1 - exp(-AFGNS.lambda(1)*maturity))./...
           (AFGNS.lambda(1)*maturity)  - exp(-AFGNS.lambda(1)*maturity);
            AFGNS.meas_par(:,5)  =  (1 - exp(-AFGNS.lambda(2)*maturity))./...
           (AFGNS.lambda(2)*maturity)  - exp(-AFGNS.lambda(2)*maturity);

            AFGNS.meas_const_vec = evaluate_meas_const_vector(AFGNS);
        end
    end

end