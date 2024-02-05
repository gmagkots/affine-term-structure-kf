function optimize_model(QML)
%  Purpose:
%
%    Optimize model, and save the optimal parameters and the Fisher
%    information matrix associated with them.
%
%  Input:
%
%    None
%
%  Output:
%
%    The vector of optimal parameter values for the model, and the Fisher
%    information matrix (negative Hessian) associated with it (not
%    returned, but saved in corresponding class properties).
%
%  Reference:
%
%    1) Time Series Analysis, J.D. Hamilton, 1994
%    2) Maximum Likelihood Estimation of Misspecified Models
%       H. White, Econometrica, 50(1), 1–25 (1982)
%
%  Author : Georgios Magkotsios
%  Version: January  2012
%  Initial: November 2011
%

    %% Unconstrained optimization 
%{
    % Unconstrained optimization using Quasi-Newton schemes. The stability
    % constraints are imposed as "penalty function evaluations". HessUpdate
    % may be bfgs, dfp, or steepdesc.
    options = optimset('FinDiffType','forward', 'MaxFunEvals',50000, ...
                       'TolX',1e-7, 'TolFun',1e-7, 'MaxIter',10000, ...
                       'LargeScale','off', 'HessUpdate','bfgs');
    if QML.automatic_hessian
        % calculate Hessian matrix through fminunc
        [xopt,logLmax,exitflag,output,grad,hessian] = ...
            fminunc(@objective_fun_unc,QML.parameter_vector,options);
    else
        % calculate Hessian matrix manually
        [xopt,logLmax,exitflag,output,grad] = ...
            fminunc(@objective_fun_unc,QML.parameter_vector,options);

        dobj = numerical_differentiation;
        [hessian,~] = hessianest(dobj,@objective_fun_unc,xopt);
    end

    % Unconstrained optimization using derivative-free Nelder-Mead
    % simplex schemes
    %options = optimset('MaxIter',10000, 'MaxFunEvals',10000, ...
    %                   'TolX',1e-9, 'TolFun',1e-9, 'Display','final');
    %[xopt logLmax exitflag output] = ...
    %    fminsearch(@objective_fun_unc,QML.parameter_vector,options);
%}
    %% Constrained optimization
%%{
    % constrain the parameter values in the range (-1,1) or (0,1) where
    % appropriate (based on numerical tests and empirical results), to
    % facilitate the optimization algorithm
    lb = -0.9999*ones(1,length(QML.parameter_vector));
    %lb = 1e-10*ones(1,length(QML.parameter_vector));
    ub =  0.999999*ones(1,length(QML.parameter_vector));

    % force positive lambdas
    %lb(1:QML.param_vec_len(1)) = eps;
    lb(1:QML.param_vec_len(1)) = 1e-10;

    % force positive diagonal for the state transition matrix. This implies
    % the stability criterion for arbitrage-free models, and does not
    % conflict with the trends of dynamic models.
    %%lb(QML.param_vec_len(2)+1:(QML.state_par_dim(2)+1):QML.param_vec_len(3)) = eps;
    %lb(QML.param_vec_len(2)+1:(QML.state_par_dim(2)+1):QML.param_vec_len(3)) = 1e-10;

    % ignore the remaining fmincon internal matrices for linear constraints
    A = []; b = []; Aeq = []; beq = [];

    options = optimset('FinDiffType','forward', 'MaxFunEvals',50000, ...
                       'TolX',1e-7, 'TolFun',1e-7, 'MaxIter',10000, ...
                       'Algorithm','interior-point', 'Hessian','bfgs', ...
                       'Diagnostics','on');
                       %'Diagnostics','on', 'UseParallel','always');
    if QML.automatic_hessian
        % calculate Hessian matrix through fmincon
        [xopt,logLmax,exitflag,output,~,grad,hessian] = ...
            fmincon(@objective_fun_con,QML.parameter_vector,A,b, ...
                    Aeq,beq,lb,ub,@stability,options);
    else
        % calculate Hessian matrix manually
        [xopt,logLmax,exitflag,output,~,grad] = ...
            fmincon(@objective_fun_con,QML.parameter_vector,A,b, ...
                    Aeq,beq,lb,ub,@stability,options);

        dobj = numerical_differentiation;
        [hessian,~] = hessianest(dobj,@objective_fun_con,xopt);
    end
        
%}
    %% Save optimal estimates and report results

    % replace the initial estimate to the parameter vector with the
    % optimal estimate, and save the output gradients vector (should be
    % close to zero for successful optimization)
    QML.parameter_vector = xopt;
    QML.grad_vec = grad;

    % save the Fisher information matrix (negative Hessian) and the maximum
    % (positive) value found for the log-likelihood function. No negative
    % sign is required for the Hessian, since we minimize the negative
    % log-likelihood.
    QML.Fisher_mat = hessian;
    QML.logL_max   = - logLmax;

    % display a few diagnostics and results
    fprintf('The total number of parameters for model %s is %d \n', ...
             QML.model_name,length(QML.parameter_vector));
    fprintf('The maximum logL value found is %e \n',QML.logL_max);
    fprintf('The maximum gradient value found is %e (should be zero) \n', ...
             max(abs(QML.grad_vec)));
    fprintf('Optimization algorithm exit status: %d \n',exitflag);
    fprintf('MATLAB command output:\n');
    output

    %% Objective function for unconstrained optimization

    function logL = objective_fun_unc(x)
    %  Purpose:
    %
    %    Objective function used for unconstrained optimization
    %
    %  Input:
    %
    %    Vector of model parameters as variables of the objective
    %    function.
    %
    %  Output:
    %
    %    Log-likelihood function
    %
    %  Author : Georgios Magkotsios
    %  Version: January  2012
    %  Initial: November 2011
    %

        % redefine parameter containers
        [lambda mu state_par state_cov meas_cov] = extract_parameters(QML,x);

        % use "barrier" scheme for non-positive lambdas (fminunc only)
        if (min(lambda) > 0)
            % create and evolve a temporary model with stability checks on
            model_temp = choose_model(QML,lambda,mu,state_par, ...
                                      state_cov,meas_cov,QML.use_fed_data);
            in_sample_yield(model_temp,true);

            % return the log-likelihood value
            logL = get_logL(model_temp);
        else
            logL = 2.5e4;%7e8;
        end

    end

    %% Objective function and non-linear constraint function for fmincon

    function logL = objective_fun_con(x)
    %  Purpose:
    %
    %    Objective function used for constrained optimization
    %
    %  Input:
    %
    %    Vector of model parameters as variables of the objective
    %    function.
    %
    %  Output:
    %
    %    Log-likelihood function
    %
    %  Author : Georgios Magkotsios
    %  Version: January 2012
    %

        % redefine parameter containers
        [lambda mu state_par state_cov meas_cov] = extract_parameters(QML,x);

        % create and evolve a temporary model with stability checks off
        model_temp = choose_model(QML,lambda,mu,state_par, ...
                                  state_cov,meas_cov,QML.use_fed_data);
        in_sample_yield(model_temp,false);

        % return the log-likelihood value
        logL = get_logL(model_temp);

    end

    function [c ceq] = stability(x)
    %  Purpose:
    %
    %    Constraint function used for constrained optimization (fmincon)
    %
    %  Input:
    %
    %    Vector of model parameters as variables of the constraint
    %    function.
    %
    %  Output:
    %
    %    The non-linear constraint condition
    %
    %  Author : Georgios Magkotsios
    %  Version: January 2012
    %

        % redefine parameter containers
        [~, ~, state_par] = extract_parameters(QML,x);

        % the eigenvalues of the state transition matrix should lie within
        % the unit circle (Harvey, equation 3.3.3)
        %c = abs(eig(state_par))' - (1-eps); % eps added to remove = in c(x)<=0
        %c = abs(eig(state_par))' - 0.999999999999999;
        c = abs(eig(state_par))' - 0.999999;
        ceq = [];

    end

end