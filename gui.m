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
if exist(fullfile(pathstr, 'config.mat'), 'file')
    load(fullfile(pathstr, 'config.mat'), 'v3dmatpath');
    addpath(v3dmatpath);
end

handles.reversecolour.UserData.black = 1;

reloadworkspacebtn_Callback(hObject, eventdata, handles)
% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function I = hessianfilter(I, handles)
h = msgbox('Filtering...');
I = handles.selectfilebtn.UserData.I;
sigma_max = str2num(handles.sigmaedit.String);
lsigma = [0.3:0.2:sigma_max];
fprintf('Filtering image with size: %d, %d, %d\n', size(I,1), size(I, 2), size(I, 3));
I = anisotropicfilter(I, lsigma);
% Update the thresholding bar
maxp = max(I(:));
minp = min(I(:));
set(handles.thresholdslider,'Max',maxp,'Min',minp);
handles.thresholdslider.Value = graythresh(I) * maxp;
handles.thresholdtxt.String = num2str(handles.thresholdslider.Value);
[bI, ~] = binarizeimage('threshold', I, handles.thresholdslider.Value,...
    handles.delta_t.Value, handles.cropcheck.Value,...
    handles.levelsetcheck.Value);
handles.selectfilebtn.UserData.I = I;
handles.selectfilebtn.UserData.bI = bI;
handles.volumesizetxt.String = sprintf('Volume Size: %d, %d, %d', size(bI, 1), size(bI, 2), size(bI, 3));

refresh_render(handles);
close(h);


function autothreshold(I, handles)
maxp = max(I(:));
minp = min(I(:));
t = graythresh(I);
handles.thresholdslider.Value = t * maxp;
set(handles.thresholdslider,'Max',maxp,'Min',minp);
handles.thresholdtxt.String = num2str(handles.thresholdslider.Value);


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
if isfield(hObject.UserData, 'default')
    disp(hObject.UserData.default)
end
if ~isfield(hObject.UserData, 'default') || ~ischar(hObject.UserData.default)
    hObject.UserData.default = '.';
end

[filename, pathname] = uigetfile({'*.v3draw;*.tif;*.mat;*.nii'},...
    'Select Input File', hObject.UserData.default);
if pathname ~= 0
    hObject.UserData.default = pathname;
end
filepath = fullfile(pathname, filename);

% get data from panel1 whose property is v3dmatdir
% v3dmatdir = getappdata(hObject.Parent, 'v3dmatdir');
%
% if v3dmatdir
%     fprintf('Adding %s to path\n', v3dmatdir);
%     addpath(v3dmatdir);
% end

[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
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

autothreshold(I, handles);

% Assign threshold vaule to variable v
v = handles.thresholdslider.Value;

% If the Diffusion filter box is ticked,
% then the image I will filtered by sigma values smaller than the one in the editbox
if handles.filtercheck.Value
    I = hessianfilter(I, handles);
end

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
refresh_render(handles);
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
    f = load(filepath);
    fields = fieldnames(f);
    if numel(fields) > 0
        I = f.(fields{1});
    end
elseif strcmp(ext, '.nii')
else
end

function autocropbtn_Callback(hObject, eventdata, handles)
if isfield(handles.selectfilebtn.UserData, 'bI')
    bI = imagecrop(handles.selectfilebtn.UserData.bI, 0.5);
    handles.volumesizetxt.String = sprintf('Volume Size: %d, %d, %d', size(bI, 1), size(bI, 2), size(bI, 3));
    handles.selectfilebtn.UserData.bI = bI;
    handles.selectfilebtn.UserData.I = imagecrop(handles.selectfilebtn.UserData.I, handles.thresholdslider.Value);
    refresh_render(handles);
end


function classificationcheck_Callback(hObject, eventdata, handles)
function radiobutton2_Callback(hObject, eventdata, handles)
function edit1_Callback(hObject, eventdata, handles)

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
function dumpcheck_Callback(hObject, eventdata, handles)
function edit2_Callback(hObject, eventdata, handles)
function checkbox3_Callback(hObject, eventdata, handles)
function sigmaedit_Callback(hObject, eventdata, handles)
function pushbutton4_Callback(hObject, eventdata, handles)
function edit4_Callback(hObject, eventdata, handles)
function edit2_CreateFcn(hObject, eventdata, handles)
function cropcheck_Callback(hObject, eventdata, handles)
function pushbutton2_Callback(hObject, eventdata, handles)
function pushbutton3_Callback(hObject, eventdata, handles)
function levelsetcheck_Callback(hObject, eventdata, handles)
function filtercheck_Callback(hObject, eventdata, handles)
function pushbutton5_Callback(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sigmaedit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function v3dmatlabbtn_Callback(hObject, eventdata, handles)
% hObject    handle to v3dmatlabbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v3dmatpath = uigetdir;
% First findobj returns a handle
% Find objects with specified property values.
% 'Tag' == 'P1Name' v3dmatdir == 'P1value'
% These callback do two things :
% first one is to add path
% second one is to set panel1 propoerty v3dmatdir to dirname
filepathtext = findobj('Tag', 'v3dmatdir');
filepathtext.String = v3dmatpath;
setappdata(hObject.Parent, 'v3dmatdir', v3dmatpath);
addpath(v3dmatpath)
[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
save(fullfile(pathstr, 'config.mat'), 'v3dmatpath');


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
    refresh_render(handles);
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
%     cla(ax);
    axes(ax);
%     showbox(handles.selectfilebtn.UserData.bI, 0.5, handles.lightcheck.Value);
    tic
    %[tree, meanconf] = trace(handles.selectfilebtn.UserData.bI, handles.plottracecheck.Value, str2num(handles.coverageedit.String), false, str2num(handles.gapedit.String), ax, handles.dumpcheck.Value, str2num(handles.connectedit.String), str2num(handles.branchlen.String), handles.selectfilebtn.UserData.I);
    if handles.somaflagtag.Value
        if ~isfield(handles.selectfilebtn.UserData, 'soma')
            msgbox('To use soma mask, please Click Craw in the Soma Detection panel at first...')
            return
        end
        [tree, meanconf] = trace(handles.selectfilebtn.UserData.bI, handles.plottracecheck.Value, str2num(handles.coverageedit.String), false, str2num(handles.gapedit.String), ax, handles.dumpcheck.Value, str2num(handles.connectedit.String), str2num(handles.branchlen.String), handles.somaflagtag.Value, handles.selectfilebtn.UserData.soma, handles.washawaytag.Value, handles.dtimagetag.Value, handles.selectfilebtn.UserData.I);
    else
        [tree, meanconf] = trace(handles.selectfilebtn.UserData.bI, handles.plottracecheck.Value, str2num(handles.coverageedit.String), false, str2num(handles.gapedit.String), ax, handles.dumpcheck.Value, str2num(handles.connectedit.String), str2num(handles.branchlen.String), false, false, handles.washawaytag.Value, handles.dtimagetag.Value, handles.selectfilebtn.UserData.I);
    end
    toc
    if handles.ignoreradiuscheck.Value
        tree(:, 6) = 1;
    end
    
        if handles.outputswccheck.Value
            saveswc(tree, [handles.selectfilebtn.UserData.inputpath, '-rivulet.swc']);
        end
    end
%     t = tree(:,4);
%     tree(:, 4) = tree(:, 3);
%     tree(:, 3) = t;
    
    if handles.treecheck.Value
        showswc(tree);
    end
    handles.selectfilebtn.UserData.swc = tree;
    refresh_render(handles);
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
    hessianfilter(handles.selectfilebtn.UserData.I, handles);
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
    refresh_render(handles);
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
if ~isfield(hObject.UserData, 'default')
    hObject.UserData.default = '.';
end
[filename, pathname] = uigetfile('*.swc', 'Select swc file', hObject.UserData.default);
if pathname ~= 0
    hObject.UserData.default = pathname;
end
filepath = fullfile(pathname, filename);
handles.selectfilebtn.UserData.swc = loadswc(filepath);
refresh_render(handles);

function refresh_render(handles)
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
%             fprintf('shift with %f\n', shift);
            tree(:, 3:5) = tree(:, 3:5) + shift;
        end
        % show the swc based reconstructure
        showswc(tree, false);
    end
end

% If the image tick box is ticked, new bI will be updated.
if handles.imagecheck.Value
    if isfield(handles.selectfilebtn.UserData, 'I')
        showbox(handles.selectfilebtn.UserData.I,...
                handles.thresholdslider.Value,...
                ~handles.lightcheck.Value, true,...
                handles.reversecolour.UserData.black);
    end
end

close(h);


% --- Executes on button press in imagecheck.
function imagecheck_Callback(hObject, eventdata, handles)
% hObject    handle to imagecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of imagecheck
refresh_render(handles);

% --- Executes on button press in treecheck.
function treecheck_Callback(hObject, eventdata, handles)
% hObject    handle to treecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of treecheck
refresh_render(handles);

% --- Executes on slider movement.
function shiftslider_Callback(hObject, eventdata, handles)
% hObject    handle to shiftslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
refresh_render(handles);

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
    somaloc = somalocationdt(handles.selectfilebtn.UserData.I, handles.thresholdslider.Value);
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
handles.selectfilebtn.UserData.soma = somagrowth(handles.swiftcheck.Value, str2num(handles.swiftinivthres.String), handles.thresholdslider.Value, handles.somaplotcheck.Value, ax, handles.selectfilebtn.UserData.I, center, sqrvalue, smoothvalue, lambda1value, lambda2value, stepnvalue);
toc
fprintf('Saving the soma mask into v3draw\n');
somamask = handles.selectfilebtn.UserData.soma.I;
somamask = somamask * 30;
somamask = uint8(somamask);
% save([handles.selectfilebtn.UserData.inputpath, '-rivuletsomamask.mat'], 'somamask');


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


% --- Executes on button press in somamasknivtag.
function somamasknivtag_Callback(hObject, eventdata, handles)
% hObject    handle to somamasknivtag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of somamasknivtag



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


% --- Executes on button press in washawaytag.
function washawaytag_Callback(hObject, eventdata, handles)
% hObject    handle to washawaytag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of washawaytag


% --- Executes on button press in dtimagetag.
function dtimagetag_Callback(hObject, eventdata, handles)
% hObject    handle to dtimagetag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dtimagetag


% --- Executes on selection change in workspacelist.
function workspacelist_Callback(hObject, eventdata, handles)
% hObject    handle to workspacelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns workspacelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from workspacelist
contents = cellstr(get(hObject,'String'));
varname = contents{get(hObject,'Value')};
I = evalin('base', varname);
try
    if ndims(I) == 3 % 3D image
        fprintf('Trying to load %s as 3D image\n', varname);
        autothreshold(I, handles);

        [bI, ~] = binarizeimage('threshold', I,...
            handles.thresholdslider.Value,...
            handles.delta_t.Value, handles.cropcheck.Value,...
            handles.levelsetcheck.Value);
        handles.selectfilebtn.UserData.I = I;
        handles.selectfilebtn.UserData.bI = bI;
        refresh_render(handles);
    elseif ndims(I) == 2 && size(I, 2) == 7 % swc
        fprintf('Trying to load %s as swc tree\n', varname);
        handles.selectfilebtn.UserData.swc = I;
        refresh_render(handles);
    end
catch exception
    fprintf('Cannot read variable %s\n', varname);
    disp(exception);
    return
end


% --- Executes during object creation, after setting all properties.
function workspacelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to workspacelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reloadworkspacebtn.
function reloadworkspacebtn_Callback(hObject, eventdata, handles)
% hObject    handle to reloadworkspacebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vlist = evalin('base', 'who');
set(handles.workspacelist, 'String', vlist, 'Value', 1);

% --- Executes on key press with focus on reloadworkspacebtn and none of its controls.
function reloadworkspacebtn_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to reloadworkspacebtn (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveallbtn.
function saveallbtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveallbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vars2save = fields(handles.selectfilebtn.UserData);
for i = 1 : numel(vars2save)
    field = vars2save{i};
    eval(sprintf('%s = handles.selectfilebtn.UserData.%s;', field, field));
    eval(sprintf('assignin (''base'', ''%s'', %s);', field, field));
end

% --- Executes on key press with focus on saveallbtn and none of its controls.
function saveallbtn_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to saveallbtn (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in implaybtn.
function implaybtn_Callback(hObject, eventdata, handles)
% hObject    handle to implaybtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.selectfilebtn.UserData, 'I')
    implay(handles.selectfilebtn.UserData.I);
end


% --- Executes on button press in resamplebtn.
function resamplebtn_Callback(hObject, eventdata, handles)
% hObject    handle to resamplebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scale = str2num(handles.resamplescaleedit.String);

if isfield(handles.selectfilebtn.UserData, 'I')

    I = rescale3D(handles.selectfilebtn.UserData.I, scale);
    maxp = max(I(:));
    minp = min(I(:));
    set(handles.thresholdslider,'Max',maxp,'Min',minp);
    handles.thresholdslider.Value = graythresh(I) * maxp;
    handles.thresholdtxt.String = num2str(handles.thresholdslider.Value);
    [bI, ~] = binarizeimage('threshold', I, handles.thresholdslider.Value,...
        handles.delta_t.Value, handles.cropcheck.Value,...
        handles.levelsetcheck.Value);
    handles.selectfilebtn.UserData.I = I;
    handles.selectfilebtn.UserData.bI = bI;
    handles.volumesizetxt.String = sprintf('Volume Size: %d, %d, %d', size(bI, 1), size(bI, 2), size(bI, 3));

    refresh_render(handles);
end

if isfield(handles.selectfilebtn.UserData, 'swc')
    handles.selectfilebtn.UserData.swc(:,3:5) = handles.selectfilebtn.UserData.swc(:, 3:5) * scale;
end

function resamplescaleedit_Callback(hObject, eventdata, handles)
% hObject    handle to resamplescaleedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resamplescaleedit as text
%        str2double(get(hObject,'String')) returns contents of resamplescaleedit as a double


% --- Executes during object creation, after setting all properties.
function resamplescaleedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resamplescaleedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in lightcheck.
function lightcheck_Callback(hObject, eventdata, handles)
% hObject    handle to lightcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lightcheck
refresh_render(handles);


% --- Executes on button press in dilatesoma.
function dilatesoma_Callback(hObject, eventdata, handles)
% hObject    handle to dilatesoma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.selectfilebtn.UserData, 'soma')
    hold on    
    handles.selectfilebtn.UserData.soma.I = imdilate(handles.selectfilebtn.UserData.soma.I, ones(3,3,3));
    [y, x, z] = ind2sub(size(handles.selectfilebtn.UserData.soma.I), ...
                        find(handles.selectfilebtn.UserData.soma.I));
    plot3(x, y, z, 'b.');
    axis equal
	drawnow
    hold off
end


% --- Executes on button press in erodesoma.
function erodesoma_Callback(hObject, eventdata, handles)
% hObject    handle to erodesoma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.selectfilebtn.UserData, 'soma')
    hold on
    [y, x, z] = ind2sub(size(handles.selectfilebtn.UserData.soma.I), ...
                        find(handles.selectfilebtn.UserData.soma.I));
    plot3(x, y, z, 'r.');
    axis equal
    handles.selectfilebtn.UserData.soma.I = imerode(handles.selectfilebtn.UserData.soma.I, ones(3,3,3));
    [y, x, z] = ind2sub(size(handles.selectfilebtn.UserData.soma.I), ...
                        find(handles.selectfilebtn.UserData.soma.I));
    plot3(x, y, z, 'b.');
    axis equal
	drawnow
    hold off
end


% --- Executes on button press in showsoma.
function showsoma_Callback(hObject, eventdata, handles)
% hObject    handle to showsoma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.selectfilebtn.UserData, 'soma')
    hold on
    [y, x, z] = ind2sub(size(handles.selectfilebtn.UserData.soma.I), ...
                        find(handles.selectfilebtn.UserData.soma.I));
    plot3(x, y, z, 'b.');
    axis equal
end


% --- Executes on button press in reversecolour.
function reversecolour_Callback(hObject, eventdata, handles)
% hObject    handle to reversecolour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.reversecolour.UserData.black = ~handles.reversecolour.UserData.black;

refresh_render(handles);