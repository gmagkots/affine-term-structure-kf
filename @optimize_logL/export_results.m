function export_results(QML)
%  Purpose:
%
%    Print calculated quantities in files and save them in a directory.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The class major output. This includes the vector of optimal model
%    parameters, its QML covariance matrix, the maximum value of the
%    log-likelihood function, and the relative difference between the
%    Fisher information matrix and the OPG estimate.
%
%  Author : Georgios Magkotsios
%  Version: January 2012
%

%% preface
% redefine parameter containers
[lambda mu state_par state_cov meas_cov] = ...
    extract_parameters(QML,QML.parameter_vector);

% invert the Fisher information matrix to get a (not-so-good) estimate of
% the parameter vector's covariance, and to compare with the more
% appropriate QML covariance
Fisher_covariance = inv(QML.Fisher_mat);

% create an acronym for the model container separator
xlen = QML.param_vec_len;

% define the output directory name
if QML.use_fed_data
    dirname = 'output_fed_optimization';
else
    dirname = 'output_fama_bliss_optimization';
end

% create the output directory to move the files in
if ~exist(dirname,'dir')
    fprintf(['Creating output directory "' dirname '".\n']);
    mkdir(dirname);
end

% replace the blank space with underscores and remove dots from model name
name_prefix = QML.model_name;
blk_idx = name_prefix == ' ';
dot_idx = name_prefix == '.';
name_prefix(blk_idx) = '_';
name_prefix(dot_idx) = '';

% optimization summary file
% open the generic file with write permission (in 'wt' to avoid various
% compatibility issues with newline and text editors)
filename = [name_prefix '_summary.txt'];
fid = fopen(filename,'wt');

% write some diagnostics
fprintf(fid,'-----------------------------\n');
fprintf(fid,'Optimization results synopsis\n');
fprintf(fid,'-----------------------------\n\n');
fprintf(fid,[datestr(now, 'mmmm dd, yyyy HH:MM:SS AM') '\n']);
fprintf(fid,'Model name: %s\n',QML.model_name);
fprintf(fid,'Number of model parameters     : %i\n',length(QML.parameter_vector));
fprintf(fid,'Maximum log-likelihood value   : %g\n',QML.logL_max);
fprintf(fid,'Maximum log-likelihood gradient: %g\n',abs(max(QML.grad_vec)) );
if floor(QML.tEnd/3600) > 0
    fprintf(fid,'Elapsed time is %i hours, %i minutes and %f seconds\n', ...
            floor(QML.tEnd/3600),floor(rem(QML.tEnd/60,60)),rem(QML.tEnd,60));
else
    fprintf(fid,'Elapsed time is %i minutes and %f seconds\n\n', ...
            floor(QML.tEnd/60),rem(QML.tEnd,60));
end

%% write the lambda vector and its standard errors (standard deviations)
fmt = [repmat('   % e', 1, size(lambda, 2)), '\n'];
fprintf(fid,'-------------\n');
fprintf(fid,'Lambda vector\n');
fprintf(fid,'-------------\n\n');
fprintf(fid,fmt,lambda');
fprintf(fid,'\n\n');

cov = sqrt(diag(Fisher_covariance( 1:xlen(1),1:xlen(1) )))';
fprintf(fid,'------------------------------------\n');
fprintf(fid,'Lambda vector Fisher standard errors\n');
fprintf(fid,'------------------------------------\n\n');
fprintf(fid,fmt,cov');
fprintf(fid,'\n\n');

if QML.estimate_OPG_QML_flag
    cov = sqrt(diag(QML.QML_covariance( 1:xlen(1),1:xlen(1) )))';
    fprintf(fid,'---------------------------------\n');
    fprintf(fid,'Lambda vector QML standard errors\n');
    fprintf(fid,'---------------------------------\n\n');
    fprintf(fid,fmt,cov');
    fprintf(fid,'\n\n');
end

%% write the mu (or theta) vector and its standard errors
fmt = [repmat('   % e', 1, size(mu, 2)), '\n'];
if (strcmpi('D',QML.model_name(1)))
    fprintf(fid,'---------\n');
    fprintf(fid,'Mu vector\n');
    fprintf(fid,'---------\n\n');
else
    fprintf(fid,'------------\n');
    fprintf(fid,'Theta vector\n');
    fprintf(fid,'------------\n\n');
end
fprintf(fid,fmt,mu');
fprintf(fid,'\n\n');

cov = sqrt(diag(Fisher_covariance( xlen(1)+1:xlen(2), ...
                                   xlen(1)+1:xlen(2) )))';
if (strcmpi('D',QML.model_name(1)))
    fprintf(fid,'--------------------------------\n');
    fprintf(fid,'Mu vector Fisher standard errors\n');
    fprintf(fid,'--------------------------------\n\n');
else
    fprintf(fid,'-----------------------------------\n');
    fprintf(fid,'Theta vector Fisher standard errors\n');
    fprintf(fid,'-----------------------------------\n\n');
end
fprintf(fid,fmt,cov');
fprintf(fid,'\n\n');

if QML.estimate_OPG_QML_flag
    cov = sqrt(diag(QML.QML_covariance( xlen(1)+1:xlen(2), ...
                                        xlen(1)+1:xlen(2) )))';
    if (strcmpi('D',QML.model_name(1)))
        fprintf(fid,'-----------------------------\n');
        fprintf(fid,'Mu vector QML standard errors\n');
        fprintf(fid,'-----------------------------\n\n');
    else
        fprintf(fid,'--------------------------------\n');
        fprintf(fid,'Theta vector QML standard errors\n');
        fprintf(fid,'--------------------------------\n\n');
    end
    fprintf(fid,fmt,cov');
    fprintf(fid,'\n\n');
end

%% write the state transition matrix and its standard errors
fmt = [repmat('   % e', 1, size(state_par, 2)), '\n'];
fprintf(fid,'-----------------------\n');
fprintf(fid,'State transition matrix\n');
fprintf(fid,'-----------------------\n\n');
fprintf(fid,fmt,state_par');
fprintf(fid,'\n\n');

cov = zeros(QML.state_par_dim);
cov(QML.state_par_idx) = sqrt(diag(Fisher_covariance( ...
    xlen(2)+1:xlen(3),xlen(2)+1:xlen(3) )))';
fprintf(fid,'----------------------------------------------\n');
fprintf(fid,'State transition matrix Fisher standard errors\n');
fprintf(fid,'----------------------------------------------\n\n');
fprintf(fid,fmt,cov');
fprintf(fid,'\n\n');

if QML.estimate_OPG_QML_flag
    cov = zeros(QML.state_par_dim);
    cov(QML.state_par_idx) = sqrt(diag(QML.QML_covariance( ...
        xlen(2)+1:xlen(3),xlen(2)+1:xlen(3) )))';
    fprintf(fid,'-------------------------------------------\n');
    fprintf(fid,'State transition matrix QML standard errors\n');
    fprintf(fid,'-------------------------------------------\n\n');
    fprintf(fid,fmt,cov');
    fprintf(fid,'\n\n');
end

%% write the state space covariance (or Sigma) matrix and its errors
fmt = [repmat('   % e', 1, size(state_cov, 2)), '\n'];
if (strcmpi('D',QML.model_name(1)))
    fprintf(fid,'----------------------------------\n');
    fprintf(fid,'State transition covariance matrix\n');
    fprintf(fid,'----------------------------------\n\n');
else
    fprintf(fid,'-------------------------\n');
    fprintf(fid,'Sigma (volatility) matrix\n');
    fprintf(fid,'-------------------------\n\n');
end
fprintf(fid,fmt,state_cov');
fprintf(fid,'\n\n');

cov = zeros(QML.state_cov_dim);
cov(QML.state_cov_idx) = sqrt(diag(Fisher_covariance( ...
    xlen(3)+1:xlen(4),xlen(3)+1:xlen(4) )))';
if (strcmpi('D',QML.model_name(1)))
    fprintf(fid,'---------------------------------------------------------\n');
    fprintf(fid,'State transition covariance matrix Fisher standard errors\n');
    fprintf(fid,'---------------------------------------------------------\n\n');
else
    fprintf(fid,'------------------------------------------------\n');
    fprintf(fid,'Sigma (volatility) matrix Fisher standard errors\n');
    fprintf(fid,'------------------------------------------------\n\n');
end
fprintf(fid,fmt,cov');
fprintf(fid,'\n\n');

if QML.estimate_OPG_QML_flag
    cov = zeros(QML.state_cov_dim);
    cov(QML.state_cov_idx) = sqrt(diag(QML.QML_covariance( ...
        xlen(3)+1:xlen(4),xlen(3)+1:xlen(4) )))';
    if (strcmpi('D',QML.model_name(1)))
        fprintf(fid,'------------------------------------------------------\n');
        fprintf(fid,'State transition covariance matrix QML standard errors\n');
        fprintf(fid,'------------------------------------------------------\n\n');
    else
        fprintf(fid,'---------------------------------------------\n');
        fprintf(fid,'Sigma (volatility) matrix QML standard errors\n');
        fprintf(fid,'---------------------------------------------\n\n');
    end
    fprintf(fid,fmt,cov');
    fprintf(fid,'\n\n');
end

% export covariance matrix Q for arbitrage-free models
if (strcmpi('AF',QML.model_name(1:2)))
    obj_temp = model_superclass;
    Qmat = volatility_to_covariance(obj_temp,1/12,state_par,state_cov);
    fmt  = [repmat('   % e', 1, size(Qmat, 2)), '\n'];
    fprintf(fid,'---------------------------------------------\n');
    fprintf(fid,'Covariance matrix Q for arbitrage-free models\n');
    fprintf(fid,'---------------------------------------------\n\n');
    fprintf(fid,fmt,Qmat');
    fprintf(fid,'\n\n');
end

%% write the diagonal of the measurement covariance matrix
fmt = repmat('   % e\n', 1, size(diag(meas_cov), 2));
fprintf(fid,'---------------------------------------------\n');
fprintf(fid,'Diagonal of the measurement covariance matrix\n');
fprintf(fid,'---------------------------------------------\n\n');
fprintf(fid,fmt,diag(meas_cov)');

% close the generic file
fclose(fid);

% move the file in the output directory
movefile(filename,dirname,'f');

%% create the individual container files

% write the parameter vector (and its indivisual containers), its QML
% covariance, the Fisher information matrix, the OPG estimate, their
% relative difference, the vector of total gradients to likelihood function
% generated by the optimization algorithm, and the maximum value of the
% log-likelihood.

if QML.perform_optimization
    % parameter vector and individual containers
    parameter_vector = QML.parameter_vector;
    filename = [name_prefix '_parameter_vector.mat'];
    save(filename,'parameter_vector','lambda','mu','state_par', ...
                  'state_cov','meas_cov','-mat');
    movefile(filename,dirname,'f');

    % Fisher information matrix
    Fisher_information_matrix = QML.Fisher_mat;
    filename = [name_prefix '_Fisher_matrix.mat'];
    save(filename,'Fisher_information_matrix','-mat');
    movefile(filename,dirname,'f');

    % gradients vector of the likelihood function output by the
    % optimization algorithm
    gradients_vector = QML.grad_vec;
    filename = [name_prefix '_logL_gradients.mat'];
    save(filename,'gradients_vector','-mat');
    movefile(filename,dirname,'f');

    % maximum value of the log-likelihood function
    logL_max = QML.logL_max;
    filename = [name_prefix '_logL_max.mat'];
    save(filename,'logL_max','-mat');
    movefile(filename,dirname,'f');
end

if QML.estimate_OPG_QML_flag
    OPG_matrix = QML.OPG_mat;
    filename = [name_prefix '_OPG_matrix.mat'];
    save(filename,'OPG_matrix','-mat');
	movefile(filename,dirname,'f');

    QML_covariance = QML.QML_covariance;
    filename = [name_prefix '_QML_covariance.mat'];
    save(filename,'QML_covariance','-mat');
	movefile(filename,dirname,'f');
end

end