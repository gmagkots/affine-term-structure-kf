function shade_recession_periods(pobj)
%  Purpose:
%
%    Shade the background areas on plots with date values on the x-axis
%    that indicate recession periods.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The patch of the shaded background areas.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % get the x- and y-axis limits
    x_range = xlim;
    y_range = ylim;

    % shade the recession periods if applicable
    [peak,trough] = get_recession_periods(pobj);
    for i=1:length(peak)
        if peak(i) > x_range(2) || trough(i) < x_range(1)
            % out of range, skip shading
            continue
        elseif peak(i) >= x_range(1) && trough(i) <= x_range(2)
            % within the plot limits
            X = [peak(i),peak(i),trough(i),trough(i)];
        elseif peak(i) < x_range(1) && trough(i) <= x_range(2)
            % left boundary
            X = [x_range(1),x_range(1),trough(i),trough(i)];
        elseif peak(i) >= x_range(1) && trough(i) > x_range(2)
            % right boundary
            X = [peak(i),peak(i),x_range(2),x_range(2)];
        end
        patch(X,[y_range(1),y_range(2),y_range(2),y_range(1)],'w', ...
              'EdgeAlpha',0,'EdgeColor','none', ...
              'FaceColor',[105 105 105]/255);
    end

end