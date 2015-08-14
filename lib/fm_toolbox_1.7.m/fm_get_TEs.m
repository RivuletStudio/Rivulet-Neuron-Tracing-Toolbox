function data = fm_get_TEs(data)

echoes_to_use = data.echoes_to_use;
n_echoes_to_use = data.n_echoes_to_use;
root_dir = data.root_dir;
readfile_dirs = data.readfile_dirs;
file_code = data.file_code;

TEs = zeros(n_echoes_to_use,1);

switch file_code
    case {'SE','SCSE'}
        for j=1:n_echoes_to_use
            i=echoes_to_use(j);
            header_file = fullfile(root_dir, char(readfile_dirs(i)), 'text_header.txt');
            if exist(header_file)==2
                TEs(j) = str2double(search_text_header_func(header_file, sprintf('alTE[0]')));
            else
                error(['Could not find ' header_file]);
            end
        end
    case {'SESPM','SCSESPM'}
        for j=1:n_echoes_to_use
            i=echoes_to_use(j);
            header_file = fullfile(root_dir, char(readfile_dirs(2*i-1)), 'text_header.txt');
            if exist(header_file)==2
                TEs(j) = str2double(search_text_header_func(header_file, sprintf('alTE[0]')));
            else
                error(['Could not find ' header_file]);
            end
        end
    otherwise
        if iscell(readfile_dirs) == 1
            header_file = fullfile(root_dir, char(readfile_dirs(1)), 'text_header.txt');
        else
            header_file = fullfile(root_dir, readfile_dirs, 'text_header.txt');
        end
        if exist(header_file)==2
            for j=1:n_echoes_to_use
                i=echoes_to_use(j);
                TEs(j) = str2num(search_text_header_func(header_file, sprintf('alTE[%s]', num2str(i-1))));
            end
        else
            error(['Could not find ' header_file]);
        end
end

data.TEs = TEs;