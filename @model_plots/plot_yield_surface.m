function plot_yield_surface(pobj)
%  Purpose:
%
%    Plot the yield surfaces estimated by the models.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The plots of the yield surfaces for each of the models.
%
%  Author : Georgios Magkotsios
%  Version: January 2012
%

    % never select the OpenGL renderer (creates a bug with dates axes)
    opengl neverselect;

    % allocate the yield surface data
    yield = cell(1,pobj.models_number);

    % create an output directory if applicable and remove previous content
    if pobj.export_to_eps
        rm_stat = rmdir('yield_surfaces','s');
        mkdir yield_surfaces;
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
            pobj.forecast_dates = load_struct2.forecast_dates;
        else
            mat_path = [dirname1 '/' filename];
            load_struct = load(mat_path);
            yield{model_iter} = load_struct.yield_to_maturity;
        end
    end

    % read the maturities from a random model
    maturity = get_maturity(pobj.model_cell{1});

    % create the dates axis
    create_dates_axis(pobj);

    % plot the yield surfaces
    width = 20;
    for model_iter=1:pobj.models_number
        % set up the figure properties
        fig_ptr = figure('Name','Yield surface','Visible',pobj.visible, ...
               'Units','centimeters','Position',[8,3,width,width*0.8], ...
               'PaperUnits','centimeters', ...
               'PaperPosition',[0.5,0.5,width,width*0.8]);

        % specify the color map
        colormap(jet);

        % create the surface plot
        surf(maturity,pobj.dates_axis, ...
             yield{model_iter}(pobj.idx_lo:pobj.idx_hi,:));

        % get the model's name
        model_name = pobj.model_cell{model_iter}.model_name;

        % configure the plot
        set(gca,'FontSize',13,'LineWidth',3,'FontWeight','bold');
        %datetick('y','keepticks','keeplimits');
        datetick('y');
        xlabel('Time to maturity (years)','FontSize',13);
        ylabel('Issuance dates','FontSize',13);
        zlabel('Yield to maturity','FontSize',13);
        title(['Yield surface for the ' model_name ' model'], ...
               'FontSize',15,'FontWeight','bold');

        % export to eps and move the file in the output directory
        if pobj.export_to_eps
            filename = ['yield_surface_' pobj.file_prefix{model_iter} '.eps'];
            print(fig_ptr,filename,'-depsc2');
        	movefile(filename, 'yield_surfaces');
        end
    end

end
