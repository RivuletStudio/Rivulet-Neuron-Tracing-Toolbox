function varargout = swccontrol(varargin)
% SWCCONTROL MATLAB code for swccontrol.fig
%      SWCCONTROL, by itself, creates a new SWCCONTROL or raises the existing
%      singleton*.
%
%      H = SWCCONTROL returns the handle to a new SWCCONTROL or the handle to
%      the existing singleton*.
%
%      SWCCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SWCCONTROL.M with the given input arguments.
%
%      SWCCONTROL('Property','Value',...) creates a new SWCCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before swccontrol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to swccontrol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help swccontrol

% Last Modified by GUIDE v2.5 10-Aug-2016 14:52:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @swccontrol_OpeningFcn, ...
                   'gui_OutputFcn',  @swccontrol_OutputFcn, ...
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


% --- Executes just before swccontrol is made visible.
function swccontrol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to swccontrol (see VARARGIN)

% Choose default command line output for swccontrol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes swccontrol wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Make a copy of the swc 
mainfig = findobj('Tag','mainfigure');
if ~isempty(mainfig)
    g1data = guidata(mainfig);

    if isfield(g1data.selectfilebtn.UserData, 'swc')
        g1data.selectfilebtn.UserData.original_swc = g1data.selectfilebtn.UserData.swc;
    end
end


% --- Outputs from this function are returned to the command line.
function varargout = swccontrol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in saveswcbt.
function saveswcbt_Callback(hObject, eventdata, handles)
% hObject    handle to saveswcbt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mainfig = findobj('Tag','mainfigure');
if ~isempty(mainfig)
    g1data = guidata(mainfig);
end

if isfield(g1data.selectfilebtn.UserData, 'inputpath')
    saveswc(g1data.selectfilebtn.UserData.swc, [g1data.selectfilebtn.UserData.inputpath, '-rivuletmodified.swc']);
else
    msgbox('This swc was loaded from the Matlab workspace.\n It would be easier to save it to a file using matlab console.')
end


function shiftswc(handles)
mainfig = findobj('Tag', 'mainfigure');

if ~isempty(mainfig)
    g1data = guidata(mainfig);
else
    return
end

if g1data.treecheck.Value
    if isfield(g1data.selectfilebtn.UserData, 'original_swc')
        tree = g1data.selectfilebtn.UserData.original_swc;
        tree(:, 3) = tree(:, 3) + handles.shiftswcx.Value;
        tree(:, 4) = tree(:, 4) + handles.shiftswcy.Value;
        tree(:, 5) = tree(:, 5) + handles.shiftswcz.Value;
        g1data.selectfilebtn.UserData.swc = tree;
    end
end

guidata(mainfig, g1data);
refresh_render(g1data)


% --- Executes on slider movement.
function shiftswcx_Callback(hObject, eventdata, handles)
% hObject    handle to shiftswcx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shiftswc(handles)


% --- Executes during object creation, after setting all properties.
function shiftswcx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftswcx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function shiftswcy_Callback(hObject, eventdata, handles)
% hObject    handle to shiftswcy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% shifty vairable is a single vaule
shiftswc(handles)


% --- Executes during object creation, after setting all properties.
function shiftswcy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftswcy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function shiftswcz_Callback(hObject, eventdata, handles)
% hObject    handle to shiftswcz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
shiftswc(handles)


% --- Executes during object creation, after setting all properties.
function shiftswcz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftswcz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function refresh_render(handles)
% Identical to the one in gui.m
ax = handles.mainfig;
[az, el] = view(ax);
cla(ax); % clear the single ax with ax
axes(ax); % makes the axis with handle ax current

if handles.treecheck.Value
    if isfield(handles.selectfilebtn.UserData, 'swc')
        tree = handles.selectfilebtn.UserData.swc;
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

view(az, el);
