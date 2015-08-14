%   search_all_header_function
%   Simon Robinson. 29.09.2008
%   use to find strings and establish the value of variables in the text
%   header 
%   scan_parameter_value = search_all_header_func(filename, searchstring)
%   N.B. - searches all of the text header, including DICOM header parameters
%   - to search just the text section use search_text_header_function

function scan_parameter_value = search_all_header_func(filename, searchstring)

scan_parameter_value = 0;

fp_headerfile=fopen(filename, 'r');

if fp_headerfile == -1
   error('Could not find file %s', filename); 
end

while feof(fp_headerfile) == 0
    feof(fp_headerfile);
    tline = fgetl(fp_headerfile);
    %identify the beginning of the text header
    %disp(tline);
    matches = findstr(tline, searchstring);
    num_matches = length(matches);
    if num_matches > 0
        line_size=size(tline);
        line_length=line_size(2);
        %   parameters in the DICOM text header are separated by their
        %   descriptors by an "="
        if length(findstr(tline,' = ')) ~= 0
            param_begin=findstr(' = ', tline)+3;
        elseif length(findstr(tline,': ')) ~= 0
            param_begin=findstr(': ', tline)+2;
        else
            param_begin=line_length;
        end
        %pass back the parameter and end the search
        try
        scan_parameter_value=deblank(tline(param_begin:line_length));
        catch
            disp('');
        end
        fclose(fp_headerfile);
        break;
    end
end

if scan_parameter_value == 0
    scan_parameter_value = '-1';
end
