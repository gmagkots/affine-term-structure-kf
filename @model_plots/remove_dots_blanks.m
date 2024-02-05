function remove_dots_blanks(pobj)
%  Purpose:
%
%    Remove dots and replace blanks with underscores from the model names
%    (used as file name prefixes).
%
%  Input:
%
%    None.
%
%  Output:
%
%    A cell of strings containing the modified model names (not returned,
%    but saved as a class property).
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

% begin the loop over the model names
for model_iter=1:pobj.models_number
    % create a temporary copy of the model name
    str = get_model_name(pobj.model_cell{model_iter});

    % find the indices of blanks and dots in the model name
    blk_idx = str == ' ';
    dot_idx = str == '.';

    % replace the blank space with underscores and remove dots from the
    % model name
    str(blk_idx) = '_';
    str(dot_idx) = '';

    % save the modified string
    pobj.file_prefix{model_iter} = str;
end

end