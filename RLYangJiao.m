function varargout = RLYangJiao(varargin)
% RLYangJiao MATLAB code for RLYangJiao.fig
%      RLYangJiao, by itself, creates a new RLYangJiao or raises the existing
%      singleton*.
%
%      H = RLYangJiao returns the handle to a new RLYangJiao or the handle to
%      the existing singleton*.
%
%      RLYangJiao('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RLYangJiao.M with the given input arguments.
%
%      RLYangJiao('Property','Value',...) creates a new RLYangJiao or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RLYangJiao_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RLYangJiao_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RLYangJiao

% Last Modified by GUIDE v2.5 07-Dec-2017 16:57:50

% Begin initialization code - DO NOT EDIT
% global gameselect;
% global alpha;
% global gamma;
Qloop=[];
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RLYangJiao_OpeningFcn, ...
                   'gui_OutputFcn',  @RLYangJiao_OutputFcn, ...
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


% --- Executes just before RLYangJiao is made visible.
function RLYangJiao_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RLYangJiao (see VARARGIN)

% Choose default command line output for RLYangJiao
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RLYangJiao wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RLYangJiao_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
%******the game selection menu******
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
gameselect= get(hObject,'Value');
save('data\gameselect.mat','gameselect' );% store the game selection for later use

% --- Executes during object creation, after setting all properties.
%******the game selection menu******
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% store the game selection for later use
gameselect = get(hObject,'Value');
save('data\gameselect.mat','gameselect' );

% --- Executes on slider movement.
%******the learning rate value******
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
 alpha = get(handles.slider1,'Value'); %obtain the value from the slider
 set(handles.text7,'String',num2str(alpha)); %reflect the value on the interface
 save('data\alpha.mat','alpha' ); %save the value for later use

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
handles = guidata(hObject);
 alpha = get(handles.slider1,'Value');
 set(handles.text7,'String',num2str(alpha));
 save('data\alpha.mat','alpha' );



% --- Executes on slider movement.
%******the discout factor value******
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
 gamma = get(handles.slider2,'Value');%obtain the value from the slider
 set(handles.text8,'String',num2str(gamma));%reflect the value on the interface
 save('data\gamma.mat','gamma' );%save the value for later use

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
handles = guidata(hObject);
 gamma = get(handles.slider2,'Value');
 set(handles.text8,'String',num2str(gamma));
 save('data\gamma.mat','gamma' );



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


% --- Executes on button press in pushbutton1.
%******the reset button, no function set now******
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
%******the start button******
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('data\gameselect.mat');%load all saved values
load('data\alpha.mat');
load('data\gamma.mat');
load('data\iteration.mat');
if gameselect==1 %if game1 is selected
    flappybird2(get(handles.slider1,'Value'), get(handles.slider2,'Value'), round(get(handles.slider3,'Value')),1); % run game1 training
    load('data\Qallflappybird.mat','Qall' );%load all Q matrix
    Qloop=length(Qall);%the length of Q matrix
    set(handles.text11,'String',strcat(num2str(round(iteration)),' iterations'));% display important imformation
    set(handles.text12,'String',strcat(num2str(Qloop),' learning loops'));
    set(handles.text13, 'Visible','off');
    load('data\Bestflappybird.mat','Best' );% display the best training score
    set(handles.text18,'String',num2str(Best));
    axes(handles.axes1);
    plot(1:Qloop,Qall(:,1:Qloop,1)); % display the learning curve
%  disp('yes');
elseif gameselect==2%if game1 is selected
    pong032(get(handles.slider1,'Value'), get(handles.slider2,'Value'), round(get(handles.slider3,'Value')),1);% run game1 training
    load('data\Qallpingpong.mat','Qall' );%load all Q matrix
    Qloop=length(Qall(1,1,1,1,:));%the length of Q matrix
    set(handles.text11,'String',strcat(num2str(round(iteration)),' iterations'));% display important imformation
    set(handles.text12,'String',strcat(num2str(Qloop),' learning loops'));   
    set(handles.text13, 'Visible','on');
    load('data\Bestpingpong.mat','Best' );% display the best training score
    set(handles.text18,'String',num2str(Best));
%     axes(handles.axes1);
%     plot(1:Qloop,Qall(5,:,1,1,1:Qloop));
% display('no');
end


% --- Executes on key press with focus on popupmenu1 and none of its controls.
function popupmenu1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
%******the training iteration value******
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
 iteration = get(handles.slider3,'Value');%obtain the value from the slider
 set(handles.text9,'String',num2str(round(iteration)));%reflect the value on the interface
 save('data\iteration.mat','iteration' );%save the value for later use



% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

 
 function text7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


% --- Executes on button press in pushbutton3.
%******the replay button******
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('data\gameselect.mat');
load('data\alpha.mat');
load('data\gamma.mat');
load('data\iteration.mat');
if gameselect==1
    flappybird2(get(handles.slider1,'Value'), get(handles.slider2,'Value'), round(get(handles.slider4,'Value')),2);%play game1 with stored Q matrix
    load('data\Bestflappybird.mat','Best' );
    set(handles.text20,'String',num2str(Best));%display best replay score
elseif gameselect==2
    pong032(get(handles.slider1,'Value'), get(handles.slider2,'Value'), round(get(handles.slider4,'Value')),2);%play game2 with stored Q matrix
   load('data\Bestpingpong.mat','Best' );
    set(handles.text20,'String',num2str(Best));%display best replay score
% display('no');
end


% --- Executes on slider movement.
%******the replay iteration value******
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
 replayiteration = get(handles.slider4,'Value');
 set(handles.text15,'String',num2str(round(replayiteration)));
 save('data\replayiteration.mat','replayiteration' );

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
