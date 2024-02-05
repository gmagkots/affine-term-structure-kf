function plot_yield_curve(pobj)
%  Purpose:
%
%    Plot the yield curves estimated by the models
%
%  Input:
%
%    None.
%
%  Output:
%
%    The plot(s) of the yield to maturity curves for the models.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % allocate a few cell arrays
    yield            = cell(1,pobj.models_number);
    yield_covariance = cell(1,pobj.models_number);
    legend_arr       = cell(1,pobj.models_number+1);

    % create an output directory if applicable and remove previous content
    if pobj.export_to_eps
        rm_stat = rmdir('yield_curves','s');
        mkdir yield_curves;
    end

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

    % read the yield surface data
    for model_iter=1:pobj.models_number
        filename = [pobj.file_prefix{model_iter} '_yield_surface.mat'];
        if pobj.include_forecasts
            mat_path1 = [dirname1 '/' filename];
            mat_path2 = [dirname2 '/' filename];
            load_struct1 = load(mat_path1);
            load_struct2 = load(mat_path2);
            yield{model_iter} = [load_struct1.yield_to_maturity; ...
                                 load_struct2.yield_forecast];
            yield_covariance{model_iter} = ...
                cat(3,load_struct1.yield_covariance, ...
                      load_struct2.yield_covariance);
            pobj.forecast_dates = load_struct2.forecast_dates;
        else
            mat_path = [dirname1 '/' filename];
            load_struct = load(mat_path);
            yield{model_iter} = load_struct.yield_to_maturity;
            yield_covariance{model_iter} = load_struct.yield_covariance;
        end
    end

    % read the maturities and the data points from a random model, and fill
    % in with NaN the latter container for cases of forecasted yields
    maturity    = get_maturity(pobj.model_cell{1});
    data_points = [get_meas_data(pobj.model_cell{1}); ...
                   nan(length(pobj.forecast_dates),16)];

    % create the dates axis
    create_dates_axis(pobj);

    % define the line specifications and allocate the legend array cell
    line_style = {' -k' ' -r' ' -g' ' -b' ' -c' ' -m' ' -k+' ...
                  '--k' '--r' '--g' '--b' '--c' '--m' '--k+'...
                  '-.k' '-.r' '-.g' '-.b' '-.c' '-.m' '-.k+'};

    % create the frames
    frame  = 0;
    for j = pobj.idx_lo:pobj.idx_hi
        % correct the file name
        frame = frame + 1;
        if (frame >= 1 && frame < 10)
            frame_str = ['000' num2str(frame)];
        elseif (frame >= 10 && frame < 100)
            frame_str = ['00' num2str(frame)];
        elseif (frame >= 100 && frame < 1000)
            frame_str = ['0' num2str(frame)];
        elseif (frame >= 1000 && frame < 10000)
            frame_str = num2str(frame);
        else
            error(['Frames are more than 10000.' ...
                   'Modify code in plot_yield_curve.m.\n']);
        end
        filename = ['yield_curves_' frame_str '.eps'];

        % generate a single frame
        frame_plot(j);
    end

    function frame_plot(date_idx)
    %  Purpose:
    %
    %    Plot a single frame of the yield curves for the given issuance
    %    date and list of models.
    %
    %  Input:
    %
    %    The issuance date index that corresponds to a row (date) in the
    %    model yield matrix.
    %
    %  Output:
    %
    %    The yield curve plot, either rendered on the screen or exported to
    %    eps format for animation.
    %
    %  Author : Georgios Magkotsios
    %  Version: January 2012
    %

        % set up the figure properties
        width   = 25;
        fig_ptr = figure('Name','Yield curves','Visible',pobj.visible, ...
                         'PaperUnits','centimeters', ...
                         'PaperPosition',[0.5,0.5,width,width*0.8]);

        % plot the data points
        plot(maturity,data_points(date_idx,:),'dk','LineWidth',4);
        legend_arr{1} = 'data';
        hold on;

        % plot the yield to maturity curves
        for i=1:pobj.models_number
            plot(maturity,yield{i}(date_idx,:), ...
                 line_style{i},'LineWidth',3.5);
            legend_arr{i+1} = pobj.model_cell{i}.model_name;
        end

        % place the legend
        legend(legend_arr,'Location',pobj.legend_location);

        % plot the yield to maturity variance curves
        if pobj.include_variances
            for i=1:pobj.models_number
                curve_up = yield{i}(date_idx,:) + ...
                    sqrt(diag(yield_covariance{i}(:,:,date_idx)))';
                curve_dn = yield{i}(date_idx,:) - ...
                    sqrt(diag(yield_covariance{i}(:,:,date_idx)))';
                plot(maturity,curve_up,line_style{i+7} ,'LineWidth',3.5);
                plot(maturity,curve_dn,line_style{i+14},'LineWidth',3.5);
            end
        end

        % release the current graphics window
        hold off;

        % configure the plot
        set(gca,'FontSize',15,'LineWidth',2.5,'Box','on','XLim',[-0.5 32]);
        %set(gca,'YLim', ...
        % [0.95*min(min(data_points(pobj.idx_lo:pobj.idx_hi,:))) ...
        %  1.05*max(max(data_points(pobj.idx_lo:pobj.idx_hi,:)))] );
        xlabel('Time to maturity (years)','FontSize',20);
        ylabel('Yield to maturity','FontSize',20);
        title(['Yield curves (' ...
               datestr(pobj.dates_axis(date_idx-(pobj.idx_lo-1)), ...
               'mmm, yyyy') ')'],'FontSize',22);

        % export to eps and move the file in the output directory
        if pobj.export_to_eps
            print(fig_ptr,filename,'-depsc2');
        	movefile(filename, 'plot_yield_curves');
        end

    end

end