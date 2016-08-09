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

% Last Modified by GUIDE v2.5 09-Aug-2016 17:18:08

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


% --- Outputs from this function are returned to the command line.
function varargout = swccontrol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% refresh_swc_render(handles)global shiftx
firsth = findobj('Tag','mainfigure');
if ~isempty(firsth)
    g1data = guidata(firsth);
end
% shiftx vairable is a single vaule
shiftx = handles.shiftswcx.Value;
% shifty vairable is a single vaule
shifty = handles.shiftswcy.Value;
% shiftz vairable is a single vaule
shiftz = handles.shiftswcz.Value;
% resampxvalue is a single value
resampxvalue = str2num(handles.swcsampx.String);
% resampyvalue is a single value
resampyvalue = str2num(handles.swcsampy.String);
% resampzvalue is a single value
resampzvalue = str2num(handles.swcsampz.String);
messagerh = msgbox('Rendering');
ax = g1data.mainfig;
% clear the single ax with ax
cla(ax);
% makes the axis with handle ax current
axes(ax);
if g1data.treecheck.Value
    %  isfield(S,FIELD) returns true if the string FIELD is the name of a
    %  field in the structure array S.
    if isfield(g1data.selectfilebtn.UserData, 'swc')
        tree = g1data.selectfilebtn.UserData.swc;
        if resampxvalue ~= 0
            fprintf('Please print the current value of x: %f\n', resampxvalue);
            tree(:, 3) = tree(:, 3) / resampxvalue;
        end
        if resampyvalue ~= 0
            tree(:, 4) = tree(:, 4) / resampyvalue;
        end        
        if resampzvalue ~= 0
            tree(:, 5) = tree(:, 5) / resampzvalue;
        end
        if shiftx ~= 0
            tree(:, 3) = tree(:, 3) + shiftx;
        end
        if shifty ~= 0
            tree(:, 4) = tree(:, 4) + shifty;
        end
        if shiftz ~= 0
            tree(:, 5) = tree(:, 5) + shiftz;
        end
        % show the swc based reconstructure
        showswc(tree, false);
    end
end
% If the image tick box is ticked, new bI will be updated.
if g1data.imagecheck.Value
    if isfield(g1data.selectfilebtn.UserData, 'I')
        showbox(g1data.selectfilebtn.UserData.I,...
                g1data.thresholdslider.Value,...
                ~g1data.lightcheck.Value, true,...
                g1data.reversecolour.UserData.black);
    end
end
close(messagerh)



% --- Executes on slider movement.
function shiftswcx_Callback(hObject, eventdata, handles)
% hObject    handle to shiftswcx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function shiftswcz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftswcz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function swcsampx_Callback(hObject, eventdata, handles)
% hObject    handle to swcsampx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swcsampx as text
%        str2double(get(hObject,'String')) returns contents of swcsampx as a double


% --- Executes during object creation, after setting all properties.
function swcsampx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swcsampx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function swcsampy_Callback(hObject, eventdata, handles)
% hObject    handle to swcsampy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swcsampy as text
%        str2double(get(hObject,'String')) returns contents of swcsampy as a double


% --- Executes during object creation, after setting all properties.
function swcsampy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swcsampy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function swcsampz_Callback(hObject, eventdata, handles)
% hObject    handle to swcsampz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swcsampz as text
%        str2double(get(hObject,'String')) returns contents of swcsampz as a double


% --- Executes during object creation, after setting all properties.
function swcsampz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swcsampz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
