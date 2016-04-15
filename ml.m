function varargout = ml(varargin)
% ML MATLAB code for ml.fig
%      ML, by itself, creates a new ML or raises the existing
%      singleton*.
%
%      H = ML returns the handle to a new ML or the handle to
%      the existing singleton*.
%
%      ML('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ML.M with the given input arguments.
%
%      ML('Property','Value',...) creates a new ML or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ml_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ml_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ml

% Last Modified by GUIDE v2.5 15-Apr-2016 15:39:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ml_OpeningFcn, ...
                   'gui_OutputFcn',  @ml_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ml is made visible.
function ml_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ml (see VARARGIN)

% Choose default command line output for ml
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ml wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ml_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in lrnfilterbtn.
function lrnfilterbtn_Callback(hObject, eventdata, handles)
% hObject    handle to lrnfilterbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get_convlrn_config();
p.dataset_filelist = handles.h5list.String;
convolutional_filter_learning(0, p);


function h5list_Callback(hObject, eventdata, handles)
% hObject    handle to h5list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h5list as text
%        str2double(get(hObject,'String')) returns contents of h5list as a double


% --- Executes during object creation, after setting all properties.
function h5list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h5list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recon.
function recon_Callback(hObject, eventdata, handles)
% hObject    handle to recon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Only works with 2D now
maingui = findobj('Tag', 'maingui');
if ~isempty(maingui)
    mainhandles = guidata(maingui);
else
    ME = MException('MyComponent:noSuchVariable', ...
        'Main GUi not found','');
    throw(ME)
end

p.img = mainhandles.selectfilebtn.UserData.I;
p.ISTA_steps_no = 10;
p.gd_step_size_fm = 5e-5;
p.lambda_l1 = 2e-2;
p.filters_txt = handles.filterpath.String;

mainhandles.selectfilebtn.UserData.I = reconimg(p);
% figure(), imagesc(handles.selectfilebtn.UserData.I)
mainhandles.selectfilebtn.UserData.bI = mainhandles.selectfilebtn.UserData.I > mainhandles.thresholdslider.Value;
refresh_render(handles);


function filterpath_Callback(hObject, eventdata, handles)
% hObject    handle to filterpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterpath as text
%        str2double(get(hObject,'String')) returns contents of filterpath as a double


% --- Executes during object creation, after setting all properties.
function filterpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rotatecheck.
function rotatecheck_Callback(hObject, eventdata, handles)
% hObject    handle to rotatecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotatecheck



function bgdist_Callback(hObject, eventdata, handles)
% hObject    handle to bgdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bgdist as text
%        str2double(get(hObject,'String')) returns contents of bgdist as a double


% --- Executes during object creation, after setting all properties.
function bgdist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bgdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dtalpha_Callback(hObject, eventdata, handles)
% hObject    handle to dtalpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dtalpha as text
%        str2double(get(hObject,'String')) returns contents of dtalpha as a double


% --- Executes during object creation, after setting all properties.
function dtalpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dtalpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in extractpatches.
function extractpatches_Callback(hObject, eventdata, handles)
% hObject    handle to extractpatches (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maingui = findobj('Tag', 'maingui');
if ~isempty(maingui)
    mainhandles = guidata(maingui);
else
    ME = MException('MyComponent:noSuchVariable', ...
        'Main GUi not found','');
    throw(ME)
end

p.is2d = handles.is2dextract.Value;
p.scales = str2num(handles.extractradii.String); % Convert string with numbers and spaces to double array 
p.patchradius = str2num(handles.patchradius.String);
p.pixelthreshold = mainhandles.thresholdslider.Value;
p.nsample = str2num(handles.nsample.String);
p.dtradii = str2num(handles.dtradii.String);
p.bgdist = str2num(handles.bgdist.String);
p.rotate = handles.rotatecheck.Value;
p.dtalpha = str2num(handles.dtalpha.String);

if handles.save2h5.Value
    [file, fpath] = uiputfile('*.h5', 'Save the extracted patches as'); 
    fh5 = fullfile(fpath, file);
end

if handles.folderextract.Value
    % Assume there is a pair of image and swc file in each subfolder of the provided path
    dir2load = uigetdir(pwd, 'Select Folder to Extract');
    allpatches = [];
    allgt = [];
    % Folder extraction will skip coord, since coord is not useful here anyway
   
    d = dir(dir2load);
    isdirflag = [d.isdir];
    dirname = {d.name};
    for i = 1:numel(dirname) 
        fprintf('In %s\n', dirname{i});

        if ~isdirflag(i)
            continue
        end

        I = [];
        swc = [];

        files = dir(fullfile(dir2load, dirname{i}));
        filenames = {files.name};

        for j = 1:numel(filenames) 
            f = filenames{j};
            [~,~,ext] = fileparts(f);
            if strcmp(ext, '.v3draw') % Now only supports v3draw
                I = load_v3d_raw_img_file(fullfile(dir2load, dirname{i}, f));
                continue
            end

            if strcmp(ext, '.swc')
                swc = loadswc(fullfile(dir2load, dirname{i}, f));                 
            end

        end

        % Only extract this folder when v3draw and swc are both found
        if isempty(I) || isempty(swc)
            continue
        end

        [p.I, cropregion] = imagecrop(I, p.pixelthreshold);
        swc(:, 3) = swc(:, 3) - cropregion(1,1) + 1;
        swc(:, 4) = swc(:, 4) - cropregion(2,1) + 1;
        cropedswc = [];

        for j = 1 : size(swc, 1)
            if swc(j, 3) >= 1 && ...
                swc(j, 4) >= 1 && ...
                swc(j, 3) < (cropregion(1,2) - cropregion(1,1)) && ...
                swc(j, 4) < (cropregion(2,2) - cropregion(2,1)) 

                cropedswc = [cropedswc; swc(j, :)];
            end
        end 

        p.swc = cropedswc;
        [patches, gt, ~, ~] = extractpatches(p); % Perform patch extraction
        allpatches = cat(ndims(allpatches), allpatches, patches);
        allgt = cat(ndims(allgt), allgt, gt);
        fprintf('====== %d Patches Extracted (%d/%d) ======\n', size(allgt, 2), i, numel(dirname));
    end

    npatch = size(allgt, 2)
    fprintf('Final shuffle %d patches...\n', npatch);
    permidx = randperm(npatch);
    allpatches = allpatches(:, :, :, permidx);
    allgt = allgt(:, permidx);

    % Save the extraction result to a hdf5 file
    if handles.save2h5.Value 
        if ~isempty(allpatches) && ~isempty(allgt)
            batchsize = 64;

            if exist(fh5, 'file') == 2
                delete(fh5);
            end

            patchsize = p.patchradius * 2  + 1;
            h5create(fh5, '/data' , [patchsize, patchsize, 1, Inf], 'ChunkSize', [patchsize, patchsize, 1, batchsize], 'DataType', 'single');
            h5create(fh5, '/label' , [1, Inf], 'ChunkSize', [1, 64], 'DataType', 'single');
            h5write(fh5, '/data', single(allpatches), [1, 1, 1, 1], size(allpatches));
            h5write(fh5, '/label', single(allgt), [1, 1], size(allgt));
        else
            disp('NO VALID FILE FOUND. PLS DOUBLE CHECK!');
        end
    else % Export the extracted data to workspace only
        vars2save = {'patches', 'gt'};
        for i = 1 : numel(vars2save)
            field = vars2save{i};
            eval(sprintf('assignin (''base'', ''%s'', %s);', field, field));
        end
    end

else
    if isfield(mainhandles.selectfilebtn.UserData, 'swc')
        p.I = mainhandles.selectfilebtn.UserData.I;
    else
        throw(MException('MyComponent:noSuchVariable', 'No image loaded in buffer'));
    end

    if isfield(mainhandles.selectfilebtn.UserData, 'swc')
        p.swc = mainhandles.selectfilebtn.UserData.swc;
    else
        throw(MException('MyComponent:noSuchVariable', ...
                'No swc loaded in buffer'));
    end

    [patches, gt, coord, padimgsz] = extractpatches(p); % Perform patch extraction

    % Save the extraction result to a hdf5 file
    if handles.save2h5.Value
        batchsize = 64;

        if exist(fh5, 'file') == 2
            delete(fh5);
        end

        patchsize = p.patchradius * 2  + 1;
        h5create(fh5, '/data' , [patchsize, patchsize, 1, Inf], 'ChunkSize', [patchsize, patchsize, 1, batchsize], 'DataType', 'single');
        h5create(fh5, '/label' , [1, Inf], 'ChunkSize', [1, 64], 'DataType', 'single');
        h5create(fh5, '/coord' , [2, Inf], 'ChunkSize', [2, 64], 'DataType', 'single');
        h5create(fh5, '/imagesize' , [1, 3], 'ChunkSize', [1, 3], 'DataType', 'uint16');
        h5write(fh5, '/imagesize', uint16(padimgsz), [1, 1], size(padimgsz));
        h5write(fh5, '/data', single(patches), [1, 1, 1, 1], size(patches));
        h5write(fh5, '/label', single(gt), [1, 1], size(gt));
        h5write(fh5, '/coord', single(coord), [1, 1], size(coord));

    else % Export the extracted data to workspace only
        vars2save = {'patches', 'gt', 'coord', 'padimgsz'};
        for i = 1 : numel(vars2save)
            field = vars2save{i};
            % eval(sprintf('%s = mainhandles.selectfilebtn.UserData.%s;', field, field));
            eval(sprintf('assignin (''base'', ''%s'', %s);', field, field));
        end
    end
end

disp('*** Done ***');



function nsample_Callback(hObject, eventdata, handles)
% hObject    handle to nsample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsample as text
%        str2double(get(hObject,'String')) returns contents of nsample as a double


% --- Executes during object creation, after setting all properties.
function nsample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in is2dextract.
function is2dextract_Callback(hObject, eventdata, handles)
% hObject    handle to is2dextract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of is2dextract



function extractradii_Callback(hObject, eventdata, handles)
% hObject    handle to extractradii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of extractradii as text
%        str2double(get(hObject,'String')) returns contents of extractradii as a double


% --- Executes during object creation, after setting all properties.
function extractradii_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extractradii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function patchradius_Callback(hObject, eventdata, handles)
% hObject    handle to patchradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of patchradius as text
%        str2double(get(hObject,'String')) returns contents of patchradius as a double


% --- Executes during object creation, after setting all properties.
function patchradius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to patchradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pixelthreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pixelthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixelthreshold as text
%        str2double(get(hObject,'String')) returns contents of pixelthreshold as a double


% --- Executes during object creation, after setting all properties.
function pixelthreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixelthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in folderextract.
function folderextract_Callback(hObject, eventdata, handles)
% hObject    handle to folderextract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of folderextract


% --- Executes on button press in save2h5.
function save2h5_Callback(hObject, eventdata, handles)
% hObject    handle to save2h5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save2h5



function dtradii_Callback(hObject, eventdata, handles)
% hObject    handle to dtradii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dtradii as text
%        str2double(get(hObject,'String')) returns contents of dtradii as a double


% --- Executes during object creation, after setting all properties.
function dtradii_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dtradii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
