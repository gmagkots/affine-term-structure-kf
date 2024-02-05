function shade_forecasting_dates(pobj)
%  Purpose:
%
%    Shade the background area on plots with date values on the x-axis
%    that indicate forecasting dates.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The patch of the shaded background area.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % get the y-axis limits
    y_range = ylim;

    % shade the forecasting dates if applicable
    if pobj.include_forecasts
        X = [pobj.dates_axis(pobj.idx_in), ...
             pobj.dates_axis(pobj.idx_in), ...
             pobj.dates_axis(end), pobj.dates_axis(end)];
        patch(X,[y_range(1),y_range(2),y_range(2),y_range(1)],'w', ...
              'EdgeAlpha',0,'EdgeColor','none', ...
              'FaceColor',[255 255 0]/255);
    end

end
