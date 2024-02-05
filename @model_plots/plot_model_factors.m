function plot_model_factors(pobj,model_factors)
%  Purpose:
%
%    Plot the model factors from the estimated state vectors
%
%  Input:
%
%    The cell of model factors to plot.
%
%  Output:
%
%    The plot of the models' factors.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % never select the OpenGL renderer (creates a bug with dates axes)
    opengl neverselect;

    % allocate a few cell arrays
    state_array = cell(1,pobj.models_number);
    hamilton_covariance = cell(1,pobj.models_number);

    % choose the output directory to read the files from
    if pobj.use_fed_data
        dirname1 = 'output_fed_in_sample';
        dirname2 = 'output_fed_out_of_sample';
    else
        dirname1 = 'output_fama_bliss_in_sample';
        dirname2 = 'output_fama_bliss_out_of_sample';
    end
    if ~exist(dirname1,'dir')
        error(['Directory "' dirname1 '" not found.\n']);
    end
    if pobj.include_forecasts && ~exist(dirname2,'dir')
        error(['Directory "' dirname2 '" not found.\n']);
    end

    % read the model factor data
    for model_iter=1:pobj.models_number
        filename = [pobj.file_prefix{model_iter} '_state_variables.mat'];
        if pobj.include_forecasts
            mat_path1 = [dirname1 '/' filename];
            mat_path2 = [dirname2 '/' filename];
            load_struct1 = load(mat_path1);
            load_struct2 = load(mat_path2);
            state_array{model_iter} = cat(1,load_struct1.state_array, ...
                                            load_struct2.state_forecast);
            hamilton_covariance{model_iter} = ...
                cat(3,load_struct1.hamilton_cov,load_struct2.state_forecast_cov);
            pobj.forecast_dates = load_struct2.forecast_dates;
        else
            mat_path = [dirname1 '/' filename];
            load_struct = load(mat_path);
            state_array{model_iter} = load_struct.state_array;
            hamilton_covariance{model_iter} = load_struct.hamilton_cov;
        end
    end

    % define the number of factors per model
    Nfactor = length(model_factors);

    % identify the factors to be plotted
    idx = zeros(pobj.models_number,Nfactor);
    decrease_dimension = 0;
    for i=1:pobj.models_number
        state_vec_dim = size(state_array{i},2);
        for j=1:Nfactor
            switch model_factors{j}
                case 'level'
                    idx(i,j) = 1;
                case 'slope'
                    idx(i,j) = 2;
                case 'slope2'
                    if state_vec_dim < 5
                        idx(i,j) = 0;
                        decrease_dimension = decrease_dimension +1;
                    elseif state_vec_dim == 5
                        idx(i,j) = 3;
                    end
                case 'curvature'
                    if state_vec_dim < 5
                        idx(i,j) = 3;
                    elseif state_vec_dim == 5
                        idx(i,j) = 4;
                    end
                case 'curvature2'
                    if state_vec_dim == 5
                        idx(i,j) = 5;
                    elseif state_vec_dim == 4
                        idx(i,j) = 4;
                    else
                        idx(i,j) = 0;
                        decrease_dimension = decrease_dimension +1;
                    end
                otherwise
                    error(['Model factor ' model_factors{j} ...
                           ' is not acceptable.\n']);
            end
        end
    end

    % create the dates axis
    create_dates_axis(pobj);

    % define the line specifications and allocate the legend array cell
    line_style = {' -k' ' -r' ' -g' ' -b' ' -c' ' -m' ...
                  '--k' '--r' '--g' '--b' '--c' '--m' ...
                  '-.k' '-.r' '-.g' '-.b' '-.c' '-.m'};
	legend_arr = cell(1,pobj.models_number*Nfactor - decrease_dimension);

    % make the plot
    width   = 20;
    fig_ptr = figure('Name','Model factors','Visible',pobj.visible, ...
        'Units','centimeters','Position',[5,1,width,width*0.8], ...
        'PaperUnits','centimeters','PaperPosition',[1,1,width,width*0.8]);
    set(gcf,'renderer','zbuffer');

    % hold the current graphics window open
    hold on;

    % plot the model factor curves
    k = 0;
    for i=1:pobj.models_number
        for j=1:Nfactor
            if idx(i,j) ~= 0
                k = k + 1;
                plot(pobj.dates_axis, ...
                     state_array{i}(pobj.idx_lo:pobj.idx_hi,idx(i,j)), ...
                     line_style{k},'LineWidth',3);
                legend_arr{k} = [pobj.model_cell{i}.model_name ' ' ...
                                 model_factors{j} ' factor'];
            end
        end
    end

    % place the legend
    legend(legend_arr,'Location',pobj.legend_location);

    % plot the model factor variance curves
    if pobj.include_variances
        k = 0;
        for i=1:pobj.models_number
            for j=1:Nfactor
                if idx(i,j) ~= 0
                    k = k + 1;
                    curve_up = state_array{i}(pobj.idx_lo:pobj.idx_hi,idx(i,j)) + ...
                        sqrt(squeeze(hamilton_covariance{i} ...
                             (idx(i,j),idx(i,j),pobj.idx_lo:pobj.idx_hi)));
                    curve_dn = state_array{i}(pobj.idx_lo:pobj.idx_hi,idx(i,j)) -  ...
                        sqrt(squeeze(hamilton_covariance{i} ...
                             (idx(i,j),idx(i,j),pobj.idx_lo:pobj.idx_hi)));
                    plot(pobj.dates_axis,curve_up,line_style{k+6} ,'LineWidth',3);
                    plot(pobj.dates_axis,curve_dn,line_style{k+12},'LineWidth',3);
                end
            end
        end
    end

    % release the current graphics window
    hold off;

    % configure the plot
    set(gca,'FontSize',12,'LineWidth',2,'Box','on');
    %datetick('x','keepticks','keeplimits');
    datetick('x');
    xlabel('Time (years)','FontSize',18);
    ylabel('Model factor','FontSize',18,'FontWeight','bold');
    title('Model factor time series','FontSize',20);

    % shade the forecasting dates and recession periods if applicable
    shade_forecasting_dates(pobj);
    shade_recession_periods(pobj);

    % export to eps
    if pobj.export_to_eps
        print(fig_ptr,'model_factors.eps','-depsc2');
    end

end
