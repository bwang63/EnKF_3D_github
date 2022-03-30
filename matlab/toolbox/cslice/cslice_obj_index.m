function index = cslice_obj_index()
% CSLICE_OBJ_INDEX:  Determines cell index of current cslice object.
%
% Not to be called from command line.


%
% If a callback was invoked, use gcbf to get the index.
% Otherwise use gcf.
if ( ~isempty(gcbf) )
    current_figure = gcbf;
else
    current_figure = gcf;
end

figure_tag = get ( current_figure, 'tag' );

%
% The index is dependent upon the figure tag being of the
% form 'cslice figure %d'.
[dud,rest] = strtok(figure_tag);
[dud,rest] = strtok(rest);
[index,rest] = strtok(rest);
index = str2num(index);

return;

