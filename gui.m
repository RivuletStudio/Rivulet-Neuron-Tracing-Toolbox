function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 07-Dec-2015 15:49:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_OpeningFcn, ...
    'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(pathstr, 'util'));
addpath(genpath(fullfile(pathstr, 'lib')));

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectfilebtn.
function selectfilebtn_Callback(hObject, eventdata, handles)
% hObject    handle to selectfilebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.v3draw;*.tif;*.mat;*.nii'}, 'Select v3draw file');
filepath = fullfile(pathname, filename);
% hObject.Parent
% get data from panel1 whose property is v3dmatdir 
v3dmatdir = getappdata(hObject.Parent, 'v3dmatdir');

if v3dmatdir
    fprintf('Adding %s to path\n', v3dmatdir);
    addpath(v3dmatdir);
end

[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
%fprintf('I try to understand the the meaning of pathstr, pathstr: %s\n', pathstr);
addpath(fullfile(pathstr, 'util'));

% Basically if it is four dimensions, something must have went wrong.
% We try to correct it into three dimensions
if filename
    h = msgbox('Loading');    
    I = loadraw(filepath);
    if ndims(I) == 4 && size(I,4)>1
        I = I(:,:,:,1);
    end
else
    return
end

% Try to read the image in
if handles.thresholdslider.Value < 10 % To protect the rendering from too many noise points
    choice = questdlg('The segmentation threshold is very low. Are you sure to proceed? (May cause performance problem)', ...
             'Danger',...
             'Go Ahead',...
             'Oops...Try 10 then', 'Oops...Try 10 then');
    switch choice
        case 'Oops...Try 10 then'
            handles.thresholdslider.Value = 10;
            handles.thresholdtxt.String = '10';
        case 'Go ahead'
    end
end

% Assign threshold vaule to variable v
v = handles.thresholdslider.Value;

% If the Diffusion filter box is ticked, 
% then the image I will filtered by sigma value
% The box is 
if handles.filtercheck.Value
    % h2 is a message box displaying Filtering
    h2 = msgbox('Filtering');
    % result I is not binary 
    I = anisotropicfilter(I, str2num(handles.sigmaedit.String));
    % when the filtering process finished, the message box will be closed
    close(h2);
end

%         h = msgbox('classifying voxels');
%         clf = load('quad.mat');
%         cl = clf.obj;
%         [bI, cropregion] = binarizeimage('classification', I, cl, handles.delta_t.Value, handles.cropcheck.Value, handles.levelsetcheck.Value);
%         close(h)

% The levelset corresponding value is delta
% The levelset judge value is handles.levelsetcheck.Value
% The crop operation 
[bI, cropregion] = binarizeimage('threshold', I, v, handles.delta_t.Value, handles.cropcheck.Value, handles.levelsetcheck.Value);

% the cropregion is basically six vaules, x1 x2, y1 y2, z1 z2
if all(size(cropregion)) ~= 0 % The crop image returns [] if no cropped region is found
    I = I(cropregion(1, 1) : cropregion(1, 2), ...
          cropregion(2, 1) : cropregion(2, 2), ...
          cropregion(3, 1) : cropregion(3, 2));
else
    msgbox('No voxel to display. Please check the segmentation threshold.');
    % close the loading message box anayaway
    close(h);
    return
end

% The Original image or the filtered image is stored in
% selectfilebn.UserData.I 
hObject.UserData.I = I;
% The binarized image is stored in selectfilebn.UserData.bI  
hObject.UserData.bI = bI;
% Store the size of binarized information string in handles.volumesizetxt.String
% the following operations happens on filepath
handles.volumesizetxt.String = sprintf('Volume Size: %d, %d, %d', size(bI, 1), size(bI, 2), size(bI, 3));
% First findobj returns a handle
% Find objects with specified property values.
% 'Tag' == 'P1Name' filepath == 'P1value'
filepathtext = findobj('Tag', 'filepath');
% change File not load string to string of current file.  
filepathtext.String = filename;
% Store filepath in handles.UserData.inputpath
hObject.UserData.inputpath = filepath;

% It show the binarizied image surface
refresh_Render(handles);
if filename
    close(h)
end

function I = loadraw(filepath)
% Load raw image file from .v3draw, .tif, .nii, .mat format
[~, ~, ext] = fileparts(filepath);
if strcmp(ext, '.v3draw')
    if exist('load_v3d_raw_img_file')
        I = load_v3d_raw_img_file(filepath);
    else
        msgbox(sprintf('Please set the vaa3d_matlab_io_toolbox path first to read the *.v3draw file...Please refer to https://code.google.com/p/vaa3d/wiki/MatlabIO'));
    end
elseif strcmp(ext, '.tif')
    I = tifread(filepath);
elseif strcmp(ext, '.mat')
elseif strcmp(ext, '.nii')
else 
end

function autocropbtn_Callback(hObject, eventdata, handles)
if isfield(handles.selectfilebtn.UserData, 'bI')
    bI = imagecrop(handles.selectfilebtn.UserData.bI, 0.5);
    handles.volumesizetxt.String = sprintf('Volume Size: %d, %d, %d', size(bI, 1), size(bI, 2), size(bI, 3));
    handles.selectfilebtn.UserData.bI = bI;
    refresh_Render(handles);
end

% --- Executes on button press in classificationcheck.
function classificationcheck_Callback(hObject, eventdata, handles)
% hObject    handle to classificationcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of classificationcheck


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in dumpcheck.
function dumpcheck_Callback(hObject, eventdata, handles)
% hObject    handle to dumpcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dumpcheck



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3



function sigmaedit_Callback(hObject, eventdata, handles)
% hObject    handle to sigmaedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmaedit as text
%        str2double(get(hObject,'String')) returns contents of sigmaedit as a double


% --- Executes during object creation, after setting all properties.
function sigmaedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmaedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cropcheck.
function cropcheck_Callback(hObject, eventdata, handles)
% hObject    handle to cropcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cropcheck


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in levelsetcheck.
function levelsetcheck_Callback(hObject, eventdata, handles)
% hObject    handle to levelsetcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of levelsetcheck


% --- Executes on button press in filtercheck.
function filtercheck_Callback(hObject, eventdata, handles)
% hObject    handle to filtercheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filtercheck


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in v3dmatlabbtn.
function v3dmatlabbtn_Callback(hObject, eventdata, handles)
% hObject    handle to v3dmatlabbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirname = uigetdir;
% First findobj returns a handle
% Find objects with specified property values.
% 'Tag' == 'P1Name' v3dmatdir == 'P1value'
% These callback do two things :
% first one is to add path
% second one is to set panel1 propoerty v3dmatdir to dirname
filepathtext = findobj('Tag', 'v3dmatdir');
filepathtext.String = dirname;
setappdata(hObject.Parent, 'v3dmatdir', dirname);
addpath(dirname)


% --- Executes on slider movement.
function thresholdslider_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Value = round(hObject.Value);
handles.thresholdtxt.String = num2str(hObject.Value);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function thresholdslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thresholdedit_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdedit as text
%        str2double(get(hObject,'String')) returns contents of thresholdedit as a double


% --- Executes during object creation, after setting all properties.
function thresholdedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in segupdatebtn.
function segupdatebtn_Callback(hObject, eventdata, handles)
% hObject    handle to segupdatebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v = handles.thresholdslider.Value;
ud = handles.selectfilebtn.UserData;

if isfield(ud, 'I')
    h = msgbox('Updating...');
    I = handles.selectfilebtn.UserData.I;
    
    [bI, cropregion] = binarizeimage('threshold', I, v, handles.delta_t.Value, handles.cropcheck.Value, handles.levelsetcheck.Value);
    I = I(cropregion(1, 1) : cropregion(1, 2), ...
        cropregion(2, 1) : cropregion(2, 2), ...
        cropregion(3, 1) : cropregion(3, 2));
    handles.selectfilebtn.UserData.bI = bI;
    handles.selectfilebtn.UserData.I = I;
    handles.volumesizetxt.String = sprintf('Volume Size: %d, %d, %d', size(bI, 1), size(bI, 2), size(bI, 3));
    delete(h);
    refresh_Render(handles);
end

function delta_t_Callback(hObject, eventdata, handles)
function delta_t_CreateFcn(hObject, eventdata, handles)
function coverageedit_CreateFcn(hObject, eventdata, handles)
function coverageedit_Callback(hObject, eventdata, handles)
function gapedit_CreateFcn(hObject, eventdata, handles)
function plottracecheck_Callback(hObject, eventdata, handles)


function tracebtn_Callback(hObject, eventdata, handles)
if isfield(handles.selectfilebtn.UserData, 'bI')
    ax = handles.mainfig;
    cla(ax);
    axes(ax);
    showbox(handles.selectfilebtn.UserData.bI, 0.5);
    tic
    %[tree, meanconf] = trace(handles.selectfilebtn.UserData.bI, handles.plottracecheck.Value, str2num(handles.coverageedit.String), false, str2num(handles.gapedit.String), ax, handles.dumpcheck.Value, str2num(handles.connectedit.String), str2num(handles.branchlen.String), handles.selectfilebtn.UserData.I);
    if handles.somaflagtag.Value
        [tree, meanconf] = trace(handles.selectfilebtn.UserData.bI, handles.plottracecheck.Value, str2num(handles.coverageedit.String), false, str2num(handles.gapedit.String), ax, handles.dumpcheck.Value, str2num(handles.connectedit.String), str2num(handles.branchlen.String), handles.somaflagtag.Value, handles.selectfilebtn.UserData.somastruc);
    else 
        [tree, meanconf] = trace(handles.selectfilebtn.UserData.bI, handles.plottracecheck.Value, str2num(handles.coverageedit.String), false, str2num(handles.gapedit.String), ax, handles.dumpcheck.Value, str2num(handles.connectedit.String), str2num(handles.branchlen.String));
    end
    toc
    if handles.ignoreradiuscheck.Value
        tree(:, 6) = 1;
    end
    
    if handles.outputswccheck.Value
        if exist('save_v3d_raw_img_file')
            save_v3d_swc_file(tree, [handles.selectfilebtn.UserData.inputpath, '-rivulet.swc']);
            msgbox(sprintf('Mean confidence of the tracing: %.4f. The traced swc file has been output to %s', meanconf, [handles.selectfilebtn.UserData.inputpath, '-rivulet.swc']));
        else
            msgbox('Cannot find save_v3d_swc_file! Please check if vaa3d_matlabio_toolbox has been loaded...');
        end        
    end
    refresh_Render(handles);
else
    msgbox('Sorry, no segmented image found!');
end

% --- Executes on button press in ignoreradiuscheck.
function ignoreradiuscheck_Callback(hObject, eventdata, handles)
% hObject    handle to ignoreradiuscheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ignoreradiuscheck


% --- Executes on button press in outputswccheck.
function outputswccheck_Callback(hObject, eventdata, handles)
% hObject    handle to outputswccheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of outputswccheck


% --- Executes on button press in filterbtn.
function filterbtn_Callback(hObject, eventdata, handles)
% hObject    handle to filterbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.selectfilebtn.UserData, 'I')
    h = msgbox('Filtering...')
    I = handles.selectfilebtn.UserData.I;
    I = anisotropicfilter(I, str2num(handles.sigmaedit.String));
    handles.thresholdslider.Value = 0; % Set threshold slider to 0 after filtering
    handles.thresholdtxt.String = '0';
    [bI, cropregion] = binarizeimage('threshold', I, handles.thresholdslider.Value, handles.delta_t.Value, handles.cropcheck.Value, handles.levelsetcheck.Value);
    I = I(cropregion(1, 1) : cropregion(1, 2), ...
        cropregion(2, 1) : cropregion(2, 2), ...
        cropregion(3, 1) : cropregion(3, 2));
    handles.selectfilebtn.UserData.I = I;
    handles.selectfilebtn.UserData.bI = bI;
    handles.volumesizetxt.String = sprintf('Volume Size: %d, %d, %d', size(bI, 1), size(bI, 2), size(bI, 3));
    refresh_Render(handles);
else
    msgbox('Sorry, no segmented image found!');
end


function connectedit_Callback(hObject, eventdata, handles)
% hObject    handle to connectedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of connectedit as text
%        str2double(get(hObject,'String')) returns contents of connectedit as a double


% --- Executes during object creation, after setting all properties.
function connectedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to connectedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savecropbtn.
function savecropbtn_Callback(hObject, eventdata, handles)
% hObject    handle to savecropbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% filepath = handles.selectfilebtn.UserData.inputpath;
% [filedir, filename, ~] = fileparts(filepath);
[fname, dir] = uiputfile('*.v3draw;*.tif');
if ~fname
    return;
end

[~, n, ext] = fileparts(fname);
ud = handles.selectfilebtn.UserData;
disp(ext)
if strcmp(ext, '.v3draw')
    if isfield(ud, 'I')
        save_v3d_raw_img_file(uint8(ud.I), fullfile(dir, fname));
    end
    
    if isfield(ud, 'bI')
        binarypath = fullfile(dir, [n '-binary' ext]);
        save_v3d_raw_img_file(uint8(ud.bI), binarypath);
        msgbox(sprintf('The cropped binary image has been saved to %s', binarypath));
    end
else
    msgbox('Sorry, the support has not been implemented yet...');
end


% --- Executes on button press in classifybtn.
function classifybtn_Callback(hObject, eventdata, handles)
% hObject    handle to classifybtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles.selectfilebtn.UserData, 'bI') && ...
        isfield(handles.selectfilebtn.UserData, 'I')
    h = msgbox('classifying voxels');
    I = handles.selectfilebtn.UserData.I;
    bI = handles.selectfilebtn.UserData.bI;
    I( bI == 0 ) = 0;
    I = imagecrop(I, 0);
    
    clf = load('quad.mat');
    cl = clf.obj;
    [bI, cropregion] = binarizeimage('classification', I, cl, handles.delta_t.Value, handles.cropcheck.Value, handles.levelsetcheck.Value);
    handles.selectfilebtn.UserData.bI = bI;
    handles.selectfilebtn.UserData.I = I;
    refresh_Render(handles);
    close(h)
else
    msgbox('Sorry, no segmented image found!');
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadswcbtn.
function loadswcbtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadswcbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.swc', 'Select swc file');
filepath = fullfile(pathname, filename);
handles.selectfilebtn.UserData.swc = load_v3d_swc_file(filepath);
refresh_Render(handles);

function refresh_Render(handles)
% shift vairable is a single vaule 
% the shift vaule make swc recontruction and binaryied image do not overlap
% each other
shift = handles.shiftslider.Value * 20;
h = msgbox('Rendering');
ax = handles.mainfig;
% clear the single ax with ax
cla(ax);
% makes the axis with handle ax current
axes(ax);

if handles.treecheck.Value
    %  isfield(S,FIELD) returns true if the string FIELD is the name of a
    %  field in the structure array S.
    if isfield(handles.selectfilebtn.UserData, 'swc')
        tree = handles.selectfilebtn.UserData.swc;
        if shift > 0
            fprintf('shift with %f\n', shift);
            tree(:, 3:5) = tree(:, 3:5) + shift;
        end
        % show the swc based reconstructure
        showswc(tree, false);
    end
end

% If the image tick box is ticked, new bI will be updated. 
if handles.imagecheck.Value
    if isfield(handles.selectfilebtn.UserData, 'bI')
        showbox(handles.selectfilebtn.UserData.bI, 0.5, true);
    end
end


close(h);

% --- Executes on button press in imagecheck.
function imagecheck_Callback(hObject, eventdata, handles)
% hObject    handle to imagecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of imagecheck
refresh_Render(handles);

% --- Executes on button press in treecheck.
function treecheck_Callback(hObject, eventdata, handles)
% hObject    handle to treecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of treecheck
refresh_Render(handles);

% --- Executes on slider movement.
function shiftslider_Callback(hObject, eventdata, handles)
% hObject    handle to shiftslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
refresh_Render(handles);

% --- Executes during object creation, after setting all properties.
function shiftslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6


% --- Executes on button press in clearbtn.
function clearbtn_Callback(hObject, eventdata, handles)
% hObject    handle to clearbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ax = handles.mainfig;
cla(ax);
handles.selectfilebtn.UserData = [];


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10
function gapedit_Callback(hObject, eventdata, handles)



function branchlen_Callback(hObject, eventdata, handles)
% hObject    handle to branchlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of branchlen as text
%        str2double(get(hObject,'String')) returns contents of branchlen as a double


% --- Executes during object creation, after setting all properties.
function branchlen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to branchlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xloc_Callback(hObject, eventdata, handles)
% hObject    handle to xloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xloc as text
%        str2double(get(hObject,'String')) returns contents of xloc as a double


% --- Executes during object creation, after setting all properties.
function xloc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yloc_Callback(hObject, eventdata, handles)
% hObject    handle to yloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yloc as text
%        str2double(get(hObject,'String')) returns contents of yloc as a double


% --- Executes during object creation, after setting all properties.
function yloc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zloc_Callback(hObject, eventdata, handles)
% hObject    handle to zloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zloc as text
%        str2double(get(hObject,'String')) returns contents of zloc as a double


% --- Executes during object creation, after setting all properties.
function zloc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sqradiustag_Callback(hObject, eventdata, handles)
% hObject    handle to sqradiustag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sqradiustag as text
%        str2double(get(hObject,'String')) returns contents of sqradiustag as a double


% --- Executes during object creation, after setting all properties.
function sqradiustag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sqradiustag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smoothtag_Callback(hObject, eventdata, handles)
% hObject    handle to smoothtag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothtag as text
%        str2double(get(hObject,'String')) returns contents of smoothtag as a double


% --- Executes during object creation, after setting all properties.
function smoothtag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothtag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lambda2tag_Callback(hObject, eventdata, handles)
% hObject    handle to lambda2tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambda2tag as text
%        str2double(get(hObject,'String')) returns contents of lambda2tag as a double


% --- Executes during object creation, after setting all properties.
function lambda2tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda2tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lambda1tag_Callback(hObject, eventdata, handles)
% hObject    handle to lambda1tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lambda1tag as text
%        str2double(get(hObject,'String')) returns contents of lambda1tag as a double


% --- Executes during object creation, after setting all properties.
function lambda1tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lambda1tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in crawlbtn.
function crawlbtn_Callback(hObject, eventdata, handles)
% hObject    handle to crawlbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    tic
    sqrvalue  = str2num(handles.sqradiustag.String);
    smoothvalue = str2num(handles.smoothtag.String);
    stepnvalue = str2num(handles.stepnum.String);
    lambda1value = str2num(handles.lambda1tag.String);
    lambda2value = str2num(handles.lambda2tag.String);
    fprintf('smooth: %d radius: %d step: %d\n', smoothvalue, sqrvalue, stepnvalue);
    fprintf('lambda1: %d lambda2: %4.0d\n', lambda1value, lambda2value);
    
    ax = handles.mainfig;
    cla(ax);
    axes(ax);
    if isfield(handles.selectfilebtn.UserData, 'bI')
        showbox(handles.selectfilebtn.UserData.bI, 0.5);
    end
    if (handles.autosomacheck.Value&handles.dtcheck.Value)
        somaloc = somalocationdt(handles.selectfilebtn.UserData.I, str2num(handles.dtthres.String));
        xlocvalue = somaloc.x;
        ylocvalue = somaloc.y;
        zlocvalue = somaloc.z;
        fprintf('xloc: %d yloc: %d zloc: %d\n', xlocvalue, ylocvalue, zlocvalue);
    elseif (handles.autosomacheck.Value&handles.drcheck.Value)
        sdbands  = str2num(handles.sdonebands.String);
        sdmsize  = str2num(handles.sdonemsize.String);
        sddrthres  = str2num(handles.sdonedrthres.String);
        sdneuthres  = str2num(handles.sdoneneuthres.String);
        sdsomathres  = str2num(handles.sdonesomathres.String);
        somaloc = somalocation(handles.selectfilebtn.UserData.I, sdbands, sdmsize, sddrthres, sdsomathres, sdneuthres);
        xlocvalue = somaloc.x;
        ylocvalue = somaloc.y;
        zlocvalue = somaloc.z;
        fprintf('xloc: %d yloc: %d zloc: %d\n', xlocvalue, ylocvalue, zlocvalue);
    elseif (~handles.autosomacheck.Value)
        xlocvalue = str2num(handles.xloc.String);               
        ylocvalue = str2num(handles.yloc.String);               
        zlocvalue = str2num(handles.zloc.String);               
        fprintf('xloc: %d yloc: %d zloc: %d\n', xlocvalue, ylocvalue, zlocvalue);
    end   
    center(1) = xlocvalue;
    center(2) = ylocvalue;
    center(3) = zlocvalue;    
    handles.selectfilebtn.UserData.somastruc = somagrowth(handles.swiftcheck.Value, str2num(handles.swiftinivthres.String), handles.thresholdslider.Value, handles.somaplotcheck.Value, ax, handles.selectfilebtn.UserData.I, center, sqrvalue, smoothvalue, lambda1value, lambda2value, stepnvalue);
    toc
    fprintf('Saving the soma mask into v3draw\n');
    somaI = handles.selectfilebtn.UserData.somastruc.I;
    somaI = somaI * 30;
    somaI = uint8(somaI);
    save_v3d_raw_img_file(somaI, [handles.selectfilebtn.UserData.inputpath, '-rivuletsomamask.v3draw']);
    clear somaI;
  

    




function stepnum_Callback(hObject, eventdata, handles)
% hObject    handle to stepnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepnum as text
%        str2double(get(hObject,'String')) returns contents of stepnum as a double


% --- Executes during object creation, after setting all properties.
function stepnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in somaplotcheck.
function somaplotcheck_Callback(hObject, eventdata, handles)
% hObject    handle to somaplotcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of somaplotcheck


% --- Executes on button press in autosomacheck.
function autosomacheck_Callback(hObject, eventdata, handles)
% hObject    handle to autosomacheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autosomacheck



function sdonenbands_Callback(hObject, eventdata, handles)
% hObject    handle to sdonenbands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdonenbands as text
%        str2double(get(hObject,'String')) returns contents of sdonenbands as a double


% --- Executes during object creation, after setting all properties.
function sdonenbands_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdonenbands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sdonemsize_Callback(hObject, eventdata, handles)
% hObject    handle to sdonemsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdonemsize as text
%        str2double(get(hObject,'String')) returns contents of sdonemsize as a double


% --- Executes during object creation, after setting all properties.
function sdonemsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdonemsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sdonedrthres_Callback(hObject, eventdata, handles)
% hObject    handle to sdonedrthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdonedrthres as text
%        str2double(get(hObject,'String')) returns contents of sdonedrthres as a double


% --- Executes during object creation, after setting all properties.
function sdonedrthres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdonedrthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sdoneneuthres_Callback(hObject, eventdata, handles)
% hObject    handle to sdoneneuthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdoneneuthres as text
%        str2double(get(hObject,'String')) returns contents of sdoneneuthres as a double


% --- Executes during object creation, after setting all properties.
function sdoneneuthres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdoneneuthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sdonesomathres_Callback(hObject, eventdata, handles)
% hObject    handle to sdonesomathres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdonesomathres as text
%        str2double(get(hObject,'String')) returns contents of sdonesomathres as a double


% --- Executes during object creation, after setting all properties.
function sdonesomathres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdonesomathres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in drcheck.
function drcheck_Callback(hObject, eventdata, handles)
% hObject    handle to drcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of drcheck



function dtthres_Callback(hObject, eventdata, handles)
% hObject    handle to dtthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dtthres as text
%        str2double(get(hObject,'String')) returns contents of dtthres as a double


% --- Executes during object creation, after setting all properties.
function dtthres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dtthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dtcheck.
function dtcheck_Callback(hObject, eventdata, handles)
% hObject    handle to dtcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dtcheck


% --- Executes on button press in somainivtag.
function somainivtag_Callback(hObject, eventdata, handles)
% hObject    handle to somainivtag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of somainivtag



function swiftinivthres_Callback(hObject, eventdata, handles)
% hObject    handle to swiftinivthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swiftinivthres as text
%        str2double(get(hObject,'String')) returns contents of swiftinivthres as a double


% --- Executes during object creation, after setting all properties.
function swiftinivthres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swiftinivthres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in swiftcheck.
function swiftcheck_Callback(hObject, eventdata, handles)
% hObject    handle to swiftcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of swiftcheck


% --- Executes on button press in stubborncheck.
function stubborncheck_Callback(hObject, eventdata, handles)
% hObject    handle to stubborncheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stubborncheck



function stsomathres_Callback(hObject, eventdata, handles)
% hObject    handle to stsomathres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stsomathres as text
%        str2double(get(hObject,'String')) returns contents of stsomathres as a double


% --- Executes during object creation, after setting all properties.
function stsomathres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stsomathres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function studrthre_Callback(hObject, eventdata, handles)
% hObject    handle to studrthre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of studrthre as text
%        str2double(get(hObject,'String')) returns contents of studrthre as a double


% --- Executes during object creation, after setting all properties.
function studrthre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to studrthre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stubandsxy_Callback(hObject, eventdata, handles)
% hObject    handle to stubandsxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stubandsxy as text
%        str2double(get(hObject,'String')) returns contents of stubandsxy as a double


% --- Executes during object creation, after setting all properties.
function stubandsxy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stubandsxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stunbandszy_Callback(hObject, eventdata, handles)
% hObject    handle to stunbandszy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stunbandszy as text
%        str2double(get(hObject,'String')) returns contents of stunbandszy as a double


% --- Executes during object creation, after setting all properties.
function stunbandszy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stunbandszy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stunbandszx_Callback(hObject, eventdata, handles)
% hObject    handle to stunbandszx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stunbandszx as text
%        str2double(get(hObject,'String')) returns contents of stunbandszx as a double


% --- Executes during object creation, after setting all properties.
function stunbandszx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stunbandszx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit36_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stumsizezx_Callback(hObject, eventdata, handles)
% hObject    handle to stumsizezx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stumsizezx as text
%        str2double(get(hObject,'String')) returns contents of stumsizezx as a double


% --- Executes during object creation, after setting all properties.
function stumsizezx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stumsizezx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in somaflagtag.
function somaflagtag_Callback(hObject, eventdata, handles)
% hObject    handle to somaflagtag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of somaflagtag


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over togglebutton3.
function togglebutton3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in somaexperttag.
function somaexperttag_Callback(hObject, eventdata, handles)
% hObject    handle to somaexperttag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.somaexperttag.Value == 1
    set(handles.somaexpertpanel,'visible','on')
else
    set(handles.somaexpertpanel,'visible','off')
end


% Hint: get(hObject,'Value') returns toggle state of somaexperttag


% --- Executes on button press in checkbox26.
function checkbox26_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox26
