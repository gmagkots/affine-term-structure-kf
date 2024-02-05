function plot_logL(pobj)
%  Purpose:
%
%    Plot the log-likelihood function as a function of the two of its
%    variables, assuming all other variables fixed at their optimal values.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The log-likelihood plots (two curve and one surface plots).
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

%% initial configurations and diagnostics

% get the routine specific options and replace the model name for the
% current plot object
pobj.model_name   = pobj.logL_model_name;
container_names   = pobj.logL_container_names;
parameter_numbers = pobj.logL_parameter_numbers;
parameter_range   = pobj.logL_parameter_range;
axis_label        = pobj.logL_axis_label;
log_axis_scale    = pobj.logL_log_axis_scale;

% choose the output directory to read the files from
if pobj.use_fed_data
    dirname = 'output_fed_optimization';
else
    dirname = 'output_fama_bliss_optimization';
end
if ~exist(dirname,'dir')
    error(['Directory "' dirname '" not found.\n']);
end

% load the optimal parameter values for this model
filename  = [pobj.model_name '_parameter_vector.mat'];
mat_path  = [dirname '/' filename];
load_struct = load(mat_path);
lambda    = load_struct.lambda;
mu        = load_struct.mu;
state_par = load_struct.state_par;
state_cov = load_struct.state_cov;
meas_cov  = load_struct.meas_cov;

% check if the state transition matrix is diagonal
isdiag = isequal(diag(diag(state_par)),state_par);

% load the maximum log-likelihood value for this model
filename  = [pobj.model_name '_logL_max.mat'];
mat_path  = [dirname '/' filename];
load_struct2 = load(mat_path);
logL_max  = load_struct2.logL_max;

% determine the number of points considered per axis, allocate the
% log-likelihood array, and the container to save the optimal values
Npoints = 20;
logL = zeros(Npoints+1,Npoints+1);
xopt = zeros(2,1);

% copy the maximum logL in the corresponding position in the container
logL(Npoints+1,Npoints+1) = logL_max;

% scale the axes either linearly or logarithmically
axis_ticks = cell(1,length(parameter_numbers));
for i=1:length(axis_ticks)
    if log_axis_scale
        axis_ticks{i} = logspace(floor(log10(min(parameter_range{i}))), ...
                                  ceil(log10(max(parameter_range{i}))),Npoints);
    else
        axis_ticks{i} = linspace(min(parameter_range{i}), ...
                                 max(parameter_range{i}),Npoints);
    end
end

%% calculate the log-likelihood at the test points

% regular grid
for i=1:Npoints
    % modify the first container
    k = 1;
    switch container_names{k}
        case 'lambda'
            lambda(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'mu'
            mu(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'state_par'
            state_par(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'state_cov'
            state_cov(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'meas_cov'
            meas_cov(parameter_numbers(k)) = axis_ticks{k}(i);
        otherwise
            error(['Wrong name for container in ' ...
                   'logL_container_names (dimension %i)\n'],k);
    end

    for j=1:Npoints
        % modify the second container
        k = 2;
        switch container_names{k}
            case 'lambda'
                lambda(parameter_numbers(k)) = axis_ticks{k}(j);
            case 'mu'
                mu(parameter_numbers(k)) = axis_ticks{k}(j);
            case 'state_par'
                state_par(parameter_numbers(k)) = axis_ticks{k}(j);
            case 'state_cov'
                state_cov(parameter_numbers(k)) = axis_ticks{k}(j);
            case 'meas_cov'
                meas_cov(parameter_numbers(k)) = axis_ticks{k}(j);
            otherwise
                error(['Wrong name for container in ' ...
                       'logL_container_names (dimension %i)\n'],k);
        end

        % create a new model with the modified parameter values
        plot_model = choose_model(pobj,lambda,mu,state_par, ...
                                  state_cov,meas_cov,pobj.use_fed_data);

        % evaluate the model and get the new logL
        if max(abs(eig(plot_model.state_par))) >= 0.999
            logL(i,j) = nan;
        else
            in_sample_yield(plot_model,false);
            logL(i,j) = abs(get_logL(plot_model));
        end

    end
end

% logL along the first of the dimensions of interest
k = 2;
switch container_names{k}
    case 'lambda'
        xopt(k) = load_struct.lambda(parameter_numbers(k));
        lambda(parameter_numbers(k)) = xopt(k);
    case 'mu'
        xopt(k) = load_struct.mu(parameter_numbers(k));
        mu(parameter_numbers(k)) = xopt(k);
    case 'state_par'
        xopt(k) = load_struct.state_par(parameter_numbers(k));
        state_par(parameter_numbers(k)) = xopt(k);
    case 'state_cov'
        xopt(k) = load_struct.state_cov(parameter_numbers(k));
        state_cov(parameter_numbers(k)) = xopt(k);
    case 'meas_cov'
        xopt(k) = load_struct.meas_cov(parameter_numbers(k));
        meas_cov(parameter_numbers(k)) = xopt(k);
    otherwise
        error(['Wrong name for container in ' ...
               'logL_container_names (dimension %i)\n'],k);
end

for i=1:Npoints
    % modify the first container
    k = 1;
    switch container_names{k}
        case 'lambda'
            lambda(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'mu'
            mu(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'state_par'
            state_par(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'state_cov'
            state_cov(parameter_numbers(k)) = axis_ticks{k}(i);
        case 'meas_cov'
            meas_cov(parameter_numbers(k)) = axis_ticks{k}(i);
        otherwise
            error(['Wrong name for container in ' ...
                   'logL_container_names (dimension %i)\n'],k);
    end

    % create a new model with the modified parameter values
    plot_model = choose_model(pobj,lambda,mu,state_par, ...
                              state_cov,meas_cov,pobj.use_fed_data);

    % evaluate the model and get the new logL
    if max(abs(eig(plot_model.state_par))) >= 0.999
        logL(i,Npoints+1) = nan;
    else
        in_sample_yield(plot_model,false);
        logL(i,Npoints+1) = abs(get_logL(plot_model));
    end
end

% logL along optimal value for the second of the dimensions of interest
k = 1;
switch container_names{k}
    case 'lambda'
        xopt(k) = load_struct.lambda(parameter_numbers(k));
        lambda(parameter_numbers(k)) = xopt(k);
    case 'mu'
        xopt(k) = load_struct.mu(parameter_numbers(k));
        mu(parameter_numbers(k)) = xopt(k);
    case 'state_par'
        xopt(k) = load_struct.state_par(parameter_numbers(k));
        state_par(parameter_numbers(k)) = xopt(k);
    case 'state_cov'
        xopt(k) = load_struct.state_cov(parameter_numbers(k));
        state_cov(parameter_numbers(k)) = xopt(k);
    case 'meas_cov'
        xopt(k) = load_struct.meas_cov(parameter_numbers(k));
        meas_cov(parameter_numbers(k)) = xopt(k);
    otherwise
        error(['Wrong name for container in ' ...
               'logL_container_names (dimension %i)\n'],k);
end

for j=1:Npoints
    % modify the second container
    k = 2;
    switch container_names{k}
        case 'lambda'
            lambda(parameter_numbers(k)) = axis_ticks{k}(j);
        case 'mu'
            mu(parameter_numbers(k)) = axis_ticks{k}(j);
        case 'state_par'
            state_par(parameter_numbers(k)) = axis_ticks{k}(j);
        case 'state_cov'
            state_cov(parameter_numbers(k)) = axis_ticks{k}(j);
        case 'meas_cov'
            meas_cov(parameter_numbers(k)) = axis_ticks{k}(j);
        otherwise
            error(['Wrong name for container in ' ...
                   'logL_container_names (dimension %i)\n'],k);
    end

    % create a new model with the modified parameter values
    plot_model = choose_model(pobj,lambda,mu,state_par, ...
                              state_cov,meas_cov,pobj.use_fed_data);

    % evaluate the model and get the new logL
    if max(abs(eig(plot_model.state_par))) >= 0.999
        logL(Npoints+1,j) = nan;
    else
        in_sample_yield(plot_model,false);
        logL(Npoints+1,j) = abs(get_logL(plot_model));
    end
end

%% make the plots

% curve plots
if xopt(1) >= min(parameter_range{1}) && xopt(1) <= max(parameter_range{1})
    Xopt = xopt(2);
else
    Xopt = nan;
end
plot_curve(axis_ticks{1},logL(1:Npoints,Npoints+1),Xopt, ...
           axis_label{1},container_names{1});

if xopt(1) >= min(parameter_range{1}) && xopt(1) <= max(parameter_range{1})
    Xopt = xopt(1);
else
    Xopt = nan;
end
plot_curve(axis_ticks{2},logL(Npoints+1,1:Npoints),Xopt, ...
           axis_label{2},container_names{2});

% surface plot
[Xmat Ymat] = ndgrid(axis_ticks{1},axis_ticks{2});
plot_surface(Xmat,Ymat,logL(1:Npoints,1:Npoints), ...
    axis_label{1},axis_label{2},[container_names{1} '_' container_names{2}]);

%% utility functions that make the surface and curve plots of logL

% surface plots
function plot_surface(Xmat,Ymat,Zmat,xLabel,yLabel,file_suffix)

	% change the logL scale
    Zmat = Zmat*1e-4;

    % specify the figures' width for the postscript device
    width = 20;

    % get the graphics handle
    fig_ptr = figure('Name','Log-likelihood surface','Visible',pobj.visible, ...
        'Units','centimeters','Position',[5,1,width,width*0.8], ...
        'PaperUnits','centimeters','PaperPosition',[1,1,width,width*0.8]);
    hold on;

    % specify the color map
    colormap(jet);

    % limit the plot within the given plotting region
    %regionOfInterest = (Xmat >= min(xRange)) & (Xmat <= max(xRange)) & ...
    %                   (Ymat >= min(yRange)) & (Ymat <= max(yRange));
    %Xmat(~regionOfInterest) = NaN;
    %Ymat(~regionOfInterest) = NaN;
    %Zmat(~regionOfInterest) = NaN;

    % create the surface plot and overplot the optimal point
    surf(Xmat,Ymat,Zmat);
    if xopt(1) >= min(parameter_range{1}) && ...
       xopt(1) <= max(parameter_range{1}) && ...
       xopt(2) >= min(parameter_range{2}) && ...
       xopt(2) <= max(parameter_range{2})
        plot3(xopt(1),xopt(2),logL_max*1e-4,'om','MarkerSize',15, ...
            'MarkerFaceColor','m');
    end

    % plot the boundary planes where applicable (dynamic uncorrelated models)
    if isdiag && strcmpi(pobj.model_name(1),'D') && max(max(Xmat)) >= 0.999
        % x-axis boundary
        patch([1,1,1,1], ...
              [max(max(Ymat)),min(min(Ymat)),min(min(Ymat)),max(max(Ymat))], ...
              [max(max(Zmat)),max(max(Zmat)),min(min(Zmat)),min(min(Zmat))], 'k')
    end
    if isdiag && strcmpi(pobj.model_name(1),'D') && max(max(Ymat)) >= 0.999
        % y-axis boundary
        patch([max(max(Xmat)),min(min(Xmat)),min(min(Xmat)),max(max(Xmat))], ...
              [1,1,1,1], ...
              [max(max(Zmat)),max(max(Zmat)),min(min(Zmat)),min(min(Zmat))], 'k')
    end
    hold off;

    % configure the plot
    view(3);
    set(gca,'FontSize',13,'LineWidth',3);
    xlabel(xLabel,'FontSize',13);
    ylabel(yLabel,'FontSize',13);
    zlabel('logL (*10^4)','FontSize',13);
    %axis([-Inf,Inf,-Inf,Inf,0.98*min(min(Zmat)),1.01*Zmax])
    %axis([-Inf,Inf,-Inf,Inf,min(min(Zmat)),Zmax])
    title(['Log-likelihood surface for the ' pobj.model_name ' model'], ...
           'FontSize',15);

    % export the figure if applicable
    if pobj.export_to_eps
        filename = ['logL_surface_' pobj.model_name '_' file_suffix '.eps'];
        print(fig_ptr,filename,'-depsc2');
    end

end

% line plots
function plot_curve(X,Y,Xopt,Xlabel,file_suffix)

    % specify the figures' width for the postscript device
    width = 20;

    % get the graphics handle
    fig_ptr = figure('Name','Log-likelihood curves','Visible',pobj.visible, ...
        'Units','centimeters','Position',[6,1,width,width*0.8], ...
        'PaperUnits','centimeters','PaperPosition',[1,1,width,width*0.8]);

    % plot the curve
    plot(X,Y*1e-4,'-k','LineWidth',3.5);

    % plot the optimal point
    plot(Xopt,logL_max*1e-4,'om','MarkerSize',10,'MarkerFaceColor','m');

    % configure the plot
    %set(gca,'FontSize',15,'LineWidth',2.5,'Box','on','YScale','log');
    set(gca,'FontSize',15,'LineWidth',2.5,'Box','on');
    xlabel(Xlabel,'FontSize',20);
    ylabel('logL (*10^4)','FontSize',20);
    title(['Log-likelihood curve for the ' pobj.model_name ' model'], ...
           'FontSize',22);

    % export the figure if applicable
    if pobj.export_to_eps
        filename = ['logL_curve_' pobj.model_name '_' file_suffix '.eps'];
        print(fig_ptr,filename,'-depsc2');
    end

end

end