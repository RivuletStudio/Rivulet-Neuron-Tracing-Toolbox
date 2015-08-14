function unix_style_string = unix_format(dos_style_string);

unix_style_string = dos_style_string;
unix_style_string = strrep(unix_style_string, '\', '/');
unix_style_string = strrep(unix_style_string, 'C:', '/c');
unix_style_string = strrep(unix_style_string, 'D:', '/d');
unix_style_string = strrep(unix_style_string, 'E:', '/e');
unix_style_string = strrep(unix_style_string, 'F:', '/f');
unix_style_string = strrep(unix_style_string, 'G:', '/g');
if length(strfind(dos_style_string, ' ')) ~= 0
    unix_style_string = strrep(unix_style_string, ' ', '\ ');
    %     warning('!!!: Directory names in Unix commands should not contain spaces; currently %s', dos_style_string);
end
end