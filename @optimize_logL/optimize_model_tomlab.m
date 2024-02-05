function optimize_model_tomlab(QML)
%  Purpose:
%
%    Optimize model, and save the optimal parameters and the Fisher
%    information matrix associated with them using the TOMLAB package.
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
%  Version: February 2012
%

    %% Constrained optimization

    % name the problem
    Name = 'logL maximization';

    % starting point
    x_0 = QML.parameter_vector;

    % determine the lower bound for the lambdas (lambda > 0)
    x_L = -Inf*ones(1,length(x_0));
    %x_L(1:QML.param_vec_len(1)) = eps;
    x_L(1:QML.param_vec_len(1)) = 1e-10;

    % force positive diagonal for the state transition matrix. This implies
    % the stability criterion for arbitrage-free models, and does not
    % conflict with the trends of dynamic models.
    %x_L(QML.param_vec_len(2)+1:(QML.state_par_dim(2)+1):QML.param_vec_len(3)) = eps;
    %x_L(QML.param_vec_len(2)+1:(QML.state_par_dim(2)+1):QML.param_vec_len(3)) = 1e-10;

    % determine the lower and upper bounds for the nonlinear constraints
    c_L = zeros(1,max(QML.state_par_dim));
    %c_U = (1 - eps)*ones(1,max(QML.state_par_dim));
    c_U = 0.999999999999999*ones(1,max(QML.state_par_dim));

    % ignore the remaining internal matrices
    A = []; b_L = []; b_U = []; x_U = [];

    % Generate the problem structure using the TOMLAB Quick format
    Prob = conAssign('objective_fun_tomlab',[],[],[],x_L,x_U,Name,x_0, ...
                      [],[],A,b_L,b_U,'stability_tomlab',[],[],[],c_L,c_U);

    % Finite difference method to estimate function derivatives (1: default
    % forward or backward differences, 3: cubic smoothing splines)
    Prob.NumDiff = 1;

    % optimization additional options
    Prob.optParam.MaxFunc = 50000;
    Prob.optParam.MaxIter = 10000;
    Prob.optParam.eps_f   = 1e-7;
    Prob.optParam.eps_x   = 1e-7;

    % user-defined arguments
    [lambda mu state_par state_cov meas_cov] = extract_parameters(QML,x_0);
    Prob.user.current_object  = QML;
    Prob.user.lambda          = lambda;
    Prob.user.mu              = mu;
    Prob.user.state_par       = state_par;
    Prob.user.state_cov       = state_cov;
    Prob.user.meas_cov        = meas_cov;
    Prob.user.state_par_c     = state_par;
    Prob.user.temporary_model = [];

    % choose the non-linear optimization algorithm
    optimization_module = 'nlpSolve';
    %optimization_module = 'conSolve';
    if strcmpi(optimization_module,'conSolve')
        % Solver algorithm: [0,2] Schittkowski SQP, [3,4] Han-Powell SQP
        % see page 93 of TOMLAB manual for combinations with NumDiff
        Prob.Solver.Alg = 0;
    end

    % run the TOMLAB optimization with final output only
    Result = tomRun(optimization_module,Prob,1);

    %% Save optimal estimates and report results

    % replace the initial estimate to the parameter vector with the
    % optimal estimate, and save the output gradients vector (should be
    % close to zero for successful optimization)
    QML.parameter_vector = Result.x_k;
    QML.grad_vec = Result.g_k;

    % save the Fisher information matrix (negative Hessian) and the maximum
    % (positive) value found for the log-likelihood function. No negative
    % sign is required for the Hessian, since we minimize the negative
    % log-likelihood.
    QML.Fisher_mat = Result.H_k;
    QML.logL_max   = - Result.f_k;

    % display a few diagnostics and results
    fprintf('The total number of parameters for model %s is %d \n', ...
             QML.model_name,length(QML.parameter_vector));
    fprintf('The maximum logL value found is %e \n',QML.logL_max);
    fprintf('The maximum gradient value found is %e (should be zero) \n', ...
             max(abs(QML.grad_vec)));
    fprintf('Optimization algorithm exit status: %d \n',Result.ExitFlag);
    fprintf('Exit Status explanation:\n');
    Result.ExitTest
    fprintf('Solver used: %s\n',Result.Solver);
    fprintf('Solver algorithm used: %s\n',Result.SolverAlgorithm);

    %% Objective function and non-linear constraint function for fmincon

    function logL = objective_fun_tomlab(x,Prob)
    %  Purpose:
    %
    %    Objective function used for constrained optimization
    %
    %  Input:
    %
    %    Vector of model parameters as variables of the objective
    %    function, and the TOMLAB Prob structure.
    %
    %  Output:
    %
    %    Log-likelihood function
    %
    %  Author : Georgios Magkotsios
    %  Version: February 2012
    %

        % use the user-defined parameters from the Prob structure
        current_object = Prob.user.current_object;

        % redefine parameter containers
        [lambda mu state_par state_cov meas_cov] = ...
            extract_parameters(current_object,x);
        Prob.user.lambda    = lambda;
        Prob.user.mu        = mu;
        Prob.user.state_par = state_par;
        Prob.user.state_cov = state_cov;
        Prob.user.meas_cov  = meas_cov;

        % create a temporary model
        model_temp = choose_model(current_object, Prob.user.lambda, ...
            Prob.user.mu, Prob.user.state_par, Prob.user.state_cov, ...
            Prob.user.meas_cov, current_object.use_fed_data);
        Prob.user.temporary_model = model_temp;

        % evolve the temporary model with stability checks off
        in_sample_yield(Prob.user.temporary_model,false);

        % return the log-likelihood value
        logL = get_logL(Prob.user.temporary_model);

    end

    function c = stability_tomlab(x,Prob)
    %  Purpose:
    %
    %    Constraint function used for constrained optimization (fmincon)
    %
    %  Input:
    %
    %    Vector of model parameters as variables of the constraint
    %    function, and the TOMLAB Prob structure.
    %
    %  Output:
    %
    %    The non-linear constraint condition
    %
    %  Author : Georgios Magkotsios
    %  Version: February 2012
    %

        % use the user-defined parameters from the Prob structure
        current_object = Prob.user.current_object;

        % redefine parameter containers
        [~, ~, state_par] = extract_parameters(current_object,x);
        Prob.user.state_par_c = state_par;

        % the eigenvalues of the state transition matrix should lie within
        % the unit circle (Harvey, equation 3.3.3)
        c = abs(eig(Prob.user.state_par_c))';

    end

end