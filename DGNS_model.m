classdef DGNS_model < model_superclass
%  Purpose:
%
%    Estimates the yield term-structure according to the DGNS model.
%
%  Input:
%
%    The DGNS model containers.
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
    methods
        % class constructor
        function DGNS = DGNS_model(model_name,lambda,mu,state_par, ...
                                   state_cov,meas_cov,use_fed_data)
            % ensure column vectors
            lambda = lambda(:);
            mu = mu(:);
            
            % read the yield data, store the number of issuance months
            DGNS.use_fed_data = use_fed_data;
            if DGNS.use_fed_data
                read_fed_data(DGNS,false);
            else
                read_fama_bliss(DGNS);
            end

            % save the model name
            if ~strcmpi(model_name(1:4),'DGNS')
                model_name = ['DGNS_' model_name];
            end
            DGNS.model_name = model_name;

            % store the model parameters
            DGNS.lambda = lambda;

            % define the state equation
            DGNS.state_par       = state_par;
            DGNS.state_cov       = state_cov*state_cov';
            DGNS.state_const_vec = mu - state_par*mu;

            % define the measurement equation
            initialize_measurement_parameters(DGNS);
            DGNS.meas_cov        = meas_cov*meas_cov';
            DGNS.meas_const_vec  = zeros(length(DGNS.maturity),1);

            % allocate the yield and state vector repository matrices
            Zdim                 = length(DGNS.state_const_vec);
            DGNS.yield           = zeros(DGNS.issue_dates,length(DGNS.maturity));
            DGNS.state_array     = zeros(DGNS.issue_dates,Zdim);
            DGNS.hamilton_cov    = zeros(Zdim,Zdim,DGNS.issue_dates);
            DGNS.filter_cov      = zeros(Zdim,Zdim,DGNS.issue_dates);
            DGNS.parameter_cov   = zeros(Zdim,Zdim,DGNS.issue_dates);

            % locate the number and indices of the non-zero elements in the
            % state space matrices
            DGNS.state_par_idx   = find(state_par)';
            DGNS.state_cov_idx   = find(state_cov)';
            DGNS.meas_cov_idx    = find(meas_cov)';

            % group model parameters in a single vector
            DGNS.parameter_vector = [lambda' mu' state_par(DGNS.state_par_idx) ...
                state_cov(DGNS.state_cov_idx) meas_cov(DGNS.meas_cov_idx)];

            % define container length acronyms
            len_lambda    = length(DGNS.lambda);
            len_const_vec = length(DGNS.state_const_vec);
            len_state_par = length(DGNS.state_par_idx);
            len_state_cov = length(DGNS.state_cov_idx);

            % set the param_vec_len vector (model container separator)
            DGNS.param_vec_len = ...
                [len_lambda, ...
                 len_lambda+len_const_vec, ...
                 len_lambda+len_const_vec+len_state_par, ...
                 len_lambda+len_const_vec+len_state_par+len_state_cov, ...
                 length(DGNS.parameter_vector)];
        end

        function super_obj = copy_superclass_object(DGNS)
            super_obj = model_superclass;
            set_property_struct(super_obj,get_property_struct(DGNS));
        end
    end

    methods (Access = 'private')
        function initialize_measurement_parameters(DGNS)
            maturity = DGNS.maturity;
            DGNS.meas_par = ones(length(maturity),5);
            DGNS.meas_par(:,2) =    (1 - exp(-DGNS.lambda(1)*maturity))./ ...
                                             (DGNS.lambda(1)*maturity);
            DGNS.meas_par(:,3) =    (1 - exp(-DGNS.lambda(2)*maturity))./ ...
                                             (DGNS.lambda(2)*maturity);
            DGNS.meas_par(:,4) =    (1 - exp(-DGNS.lambda(1)*maturity))./ ...
             (DGNS.lambda(1)*maturity) - exp(-DGNS.lambda(1)*maturity);
            DGNS.meas_par(:,5) =    (1 - exp(-DGNS.lambda(2)*maturity))./ ...
             (DGNS.lambda(2)*maturity) - exp(-DGNS.lambda(2)*maturity);
        end
    end

end