classdef DNS_model < model_superclass
%  Purpose:
%
%    Estimates the yield term-structure according to the DNS model.
%
%  Input:
%
%    The DNS model containers, a logical for FED data use, and a flag for
%    copying the model to an object of the parent class.
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
        function DNS = DNS_model(model_name,lambda,mu,state_par, ...
                                 state_cov,meas_cov,use_fed_data)
            % ensure column vectors
            lambda = lambda(:);
            mu = mu(:);
            
            % read the yield data, store the number of issuance months
            DNS.use_fed_data = use_fed_data;
            if DNS.use_fed_data
                read_fed_data(DNS,false);
            else
                read_fama_bliss(DNS);
            end

            % save the model name
            if ~strcmpi(model_name(1:3),'DNS')
                model_name = ['DNS_' model_name];
            end
            DNS.model_name = model_name;

            % store the model parameters
            DNS.lambda = lambda;

            % define the state equation
            DNS.state_par       = state_par;
            DNS.state_cov       = state_cov*state_cov';
            DNS.state_const_vec = mu - state_par*mu;

            % define the measurement equation
            initialize_measurement_parameters(DNS);
            DNS.meas_cov        = meas_cov*meas_cov';
            DNS.meas_const_vec  = zeros(length(DNS.maturity),1);

            % allocate the yield and state vector repository matrices
            Zdim                = length(DNS.state_const_vec);
            DNS.yield           = zeros(DNS.issue_dates,length(DNS.maturity));
            DNS.state_array     = zeros(DNS.issue_dates,Zdim);
            DNS.hamilton_cov    = zeros(Zdim,Zdim,DNS.issue_dates);
            DNS.filter_cov      = zeros(Zdim,Zdim,DNS.issue_dates);
            DNS.parameter_cov   = zeros(Zdim,Zdim,DNS.issue_dates);

            % locate the number and indices of the non-zero elements in the
            % state space matrices
            DNS.state_par_idx   = find(state_par)';
            DNS.state_cov_idx   = find(state_cov)';
            DNS.meas_cov_idx    = find(meas_cov)';

            % group model parameters in a single vector
            DNS.parameter_vector = [lambda' mu' state_par(DNS.state_par_idx) ...
                state_cov(DNS.state_cov_idx) meas_cov(DNS.meas_cov_idx)];

            % define container length acronyms
            len_lambda    = length(DNS.lambda);
            len_const_vec = length(DNS.state_const_vec);
            len_state_par = length(DNS.state_par_idx);
            len_state_cov = length(DNS.state_cov_idx);

            % set the param_vec_len vector (model container separator)
            DNS.param_vec_len = ...
                [len_lambda, ...
                 len_lambda+len_const_vec, ...
                 len_lambda+len_const_vec+len_state_par, ...
                 len_lambda+len_const_vec+len_state_par+len_state_cov, ...
                 length(DNS.parameter_vector)];
        end

        function super_obj = copy_superclass_object(DNS)
            super_obj = model_superclass;
            set_property_struct(super_obj,get_property_struct(DNS));
        end
    end

    methods (Access = 'private')
        function initialize_measurement_parameters(DNS)
            maturity = DNS.maturity;
            DNS.meas_par = ones(length(maturity),3);
            DNS.meas_par(:,2) = (1 - exp(-DNS.lambda*maturity))./ ...
                                         (DNS.lambda*maturity);
            DNS.meas_par(:,3) = (1 - exp(-DNS.lambda*maturity))./ ...
             (DNS.lambda*maturity) - exp(-DNS.lambda*maturity);
        end
    end

end