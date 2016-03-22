function ezmex(in1,in2)
% EZMEX Easy to use MEX-function compiler
%
% EZMEX have several calling methods:
% 
% EZMEX will build the cmex function using command line arguments 
% specified in Makefile.m 
%
% EZMEX('-c') will compile the cmex function using compilation rules
% specified in Makefile.m
% 
% EZMEX('-a') will both compile and build the cmex function
%
% EZMEX('filename') will build the cmex function using command 
% line arguments specified in filename.m
%
% EZMEX('filename','-c') is similar to EZMEX('-c')
%
% EZMEX('filename','-a') is similar to EZMEX('-a')
% 
% Example of Makefile.m
% %-------------- begin ------------------------
% compile = 'pgstd.c fileio.c';
% if strcmp(computer,'PCWIN')
%    build   = 'multi.c pgstd.obj fileio.obj';
% else
%    build   = 'multi.c pgstd.o fileio.o';
% end
% %--------------- end -------------------------


ver = version;
%if (strcmp(ver(1),'6') ~= 1)
%    error('Only support version 6');
%end

if nargin == 0,
    makefile = 'MakefileV2simple';
    option = '-b'; % build only
elseif nargin == 2,
    makefile = in1;
    switch in2,
	case '-c',
	    option = '-c';
	case '-a',
	    option = '-a';
	case '-b',
	    option = '-b';
	otherwise
	    error(sprintf('Unrecognized switch ''%s''!', in2));
    end
elseif nargin == 1,
    makefile = 'Makefilemggvf';
    switch in1,
	case '-c',
	    option = '-c';
	case '-a',
	    option = '-a';
	case '-b',
	    option = '-b';
	otherwise
	    makefile = in1;
    end	
else	    
    error('Wrong inputs');
end

if exist(makefile) ~= 2,
    error(sprintf('Cannot find makefile ''%s.m''!', makefile));
end

eval(makefile);
switch option,
    case '-b'
	eval(['mex ' build]);
    case '-c'
	eval(['mex -c ' compile]);
    case '-a'
	eval(['mex -c ' compile]);
	eval(['mex ' build]);
end

