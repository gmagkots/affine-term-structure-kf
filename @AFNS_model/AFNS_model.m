classdef AFNS_model < model_superclass
%  Purpose:
%
%    Estimates the yield term-structure according to the AFNS model.
%
%  Input:
%
%    The AFNS model containers.
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
        function AFNS = AFNS_model(model_name,lambda,theta,kappa_mat, ...
                                   sigma_mat,meas_cov,use_fed_data)
            % ensure column vectors
            lambda = lambda(:);
            theta = theta(:);
            
            % read the yield data, store the number of issuance months
            AFNS.use_fed_data = use_fed_data;
            if AFNS.use_fed_data
                read_fed_data(AFNS,false);
            else
                read_fama_bliss(AFNS);
            end

            % save the model name
            if ~strcmpi(model_name(1:4),'AFNS')
                model_name = ['AFNS_' model_name];
            end
            AFNS.model_name = model_name;

            % store the model parameters
            AFNS.lambda    = lambda;
            AFNS.theta     = theta;
            AFNS.kappa_mat = kappa_mat;
            AFNS.sigma_mat = sigma_mat;

            % define the state equation using a monthly step
            define_state_model(AFNS,1/12);

            % define the measurement equation
            initialize_measurement_parameters(AFNS);
            AFNS.meas_cov        = meas_cov*meas_cov';

            % allocate the yield and state vector repository matrices
            Zdim                 = length(AFNS.state_const_vec);
            AFNS.yield           = zeros(AFNS.issue_dates,length(AFNS.maturity));
            AFNS.state_array     = zeros(AFNS.issue_dates,Zdim);
            AFNS.hamilton_cov    = zeros(Zdim,Zdim,AFNS.issue_dates);
            AFNS.filter_cov      = zeros(Zdim,Zdim,AFNS.issue_dates);
            AFNS.parameter_cov   = zeros(Zdim,Zdim,AFNS.issue_dates);

            % locate the number and indices of the non-zero elements in the
            % state space matrices
            AFNS.state_par_idx   = find(kappa_mat)';
            AFNS.state_cov_idx   = find(sigma_mat)';
            AFNS.meas_cov_idx    = find(meas_cov)';

            % group model parameters in a single vector
            AFNS.parameter_vector = [lambda' theta' kappa_mat(AFNS.state_par_idx) ...
                sigma_mat(AFNS.state_cov_idx) meas_cov(AFNS.meas_cov_idx)];

            % define container length acronyms
            len_lambda    = length(AFNS.lambda);
            len_const_vec = length(AFNS.state_const_vec);
            len_kappa_mat = length(AFNS.state_par_idx);
            len_sigma_mat = length(AFNS.state_cov_idx);

            % set the param_vec_len vector (model container separator)
            AFNS.param_vec_len = ...
                [len_lambda, ...
                 len_lambda+len_const_vec, ...
                 len_lambda+len_const_vec+len_kappa_mat, ...
                 len_lambda+len_const_vec+len_kappa_mat+len_sigma_mat, ...
                 length(AFNS.parameter_vector)];
        end

        function super_obj = copy_superclass_object(AFNS)
            super_obj = model_superclass;
            set_property_struct(super_obj,get_property_struct(AFNS));
        end
    end

    methods (Access = 'private')
        function define_state_model(AFNS,dt)
        % for continuous time models you have to convert the volatility 
        % matrix into a one-month conditional covariance matrix
            AFNS.state_par       = expm(-AFNS.kappa_mat*dt);
            AFNS.state_cov       = volatility_to_covariance(AFNS,dt, ...
                                    AFNS.kappa_mat,AFNS.sigma_mat);
            AFNS.state_const_vec = (eye(3) - expm(-AFNS.kappa_mat*dt))*AFNS.theta;
        end

        function initialize_measurement_parameters(AFNS)
            maturity = AFNS.maturity;
            AFNS.meas_par = ones(length(maturity),3);
            AFNS.meas_par(:,2)  =  (1 - exp(-AFNS.lambda*maturity))./...
                                            (AFNS.lambda*maturity);
            AFNS.meas_par(:,3)  =  (1 - exp(-AFNS.lambda*maturity))./...
               (AFNS.lambda*maturity) - exp(-AFNS.lambda*maturity);

            AFNS.meas_const_vec = evaluate_meas_const_vector(AFNS);
        end
    end

end