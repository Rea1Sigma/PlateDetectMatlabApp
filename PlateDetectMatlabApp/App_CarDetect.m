function varargout = App_CarDetect(varargin)
% APP_CARDETECT MATLAB code for App_CarDetect.fig
%      APP_CARDETECT, by itself, creates a new APP_CARDETECT or raises the existing
%      singleton*.
%
%      H = APP_CARDETECT returns the handle to a new APP_CARDETECT or the handle to
%      the existing singleton*.
%
%      APP_CARDETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APP_CARDETECT.M with the given input arguments.
%
%      APP_CARDETECT('Property','Value',...) creates a new APP_CARDETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before App_CarDetect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to App_CarDetect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help App_CarDetect

% Last Modified by GUIDE v2.5 03-May-2024 13:42:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @App_CarDetect_OpeningFcn, ...
                   'gui_OutputFcn',  @App_CarDetect_OutputFcn, ...
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


% --- Executes just before App_CarDetect is made visible.
function App_CarDetect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to App_CarDetect (see VARARGIN)

% Choose default command line output for App_CarDetect
handles.output = hObject;
    handles.Char_Net = load('Char_1.mat');
    handles.Number_Net = load('Number_1.mat');
    handles.Char_Net = handles.Char_Net.net;
    handles.Number_Net = handles.Number_Net.net;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes App_CarDetect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = App_CarDetect_OutputFcn(hObject, eventdata, handles) 
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
   % 打开文件选择对话框让用户选择一张图片
    [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Supported Image Files (*.jpg, *.png, *.bmp)'}, 'Select an image file');
    if isequal(file,0)
       disp('User selected Cancel');
    else
       % 拼接完整的文件路径
       fullPath = fullfile(path, file);
       % 读取图片
       Origin_Image = imread(fullPath);
       % 显示原始图片
       axes(handles.axes1);                                                 %%在axes1处显示
%        imshow(Origin_Image);
       imshow(Origin_Image, 'Parent', handles.axes1, 'InitialMagnification', 'fit'); % 显示图像
       handles.Origin_Image = Origin_Image;
    end
    guidata(hObject,handles);                                               % 记录对handles结构体中的数据变更

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %% 转换为灰度图像
    Origin_Image = handles.Origin_Image;
    Gray_Image=rgb2gray(handles.Origin_Image);
    %% 进行灰度变换
    Gray_Image = imadjust(Gray_Image,[0.3,0.7],[]);
    %% 中值滤波
    % Fluent_Image=Gray_Image;
    Fluent_Image=medfilt2(Gray_Image);
    %% 边缘检测
    % 此处使用roberts算子，还有sobel、canny、prewitt等多种算子
    Image_Edge=edge(Fluent_Image,'roberts',0.1,'both');
    %% 消除无效边缘线
    se_Clean=[1;1;1];
    Image_Edge_Clean=imerode(Image_Edge,se_Clean);
    %% 填补轮廓缝隙
    se_Full=strel('rectangle',[18,18]);
    Image_Edge_Full=imclose(Image_Edge_Clean,se_Full);
    %% 消除无效连接区域
    Image_Edge_Final=bwareaopen(Image_Edge_Full,128);
    %% 筛选符合车牌标准的连通区域
    Image_Through= filterLicensePlates(Image_Edge_Final);
    %% 取得车牌图像
    [filtered_image, plate_images] = filterAndExtractLicensePlates(Origin_Image, Image_Through);
    Image_OriginPlate = plate_images{1,1};
    axes(handles.axes2);                                                
    imshow(Image_OriginPlate, 'Parent', handles.axes2, 'InitialMagnification', 'fit'); % 显示图像
    %% 判断车牌颜色
    Blue = 0;
    Green = 0;
    Yellow = 0;
    [Blue,Green,Yellow] = Judge_Color(Image_OriginPlate);
    %% 调整分辨率
    % 设置放大倍数，例如放大到原来的2倍
    scale_factor = 4;
    % 使用双三次插值方法放大图像
    Image_ClearPlate = imresize(Image_OriginPlate, scale_factor, 'bicubic');
    % 使用双三次插值方法放大图像
    Image_ClearPlate = imresize(Image_ClearPlate, scale_factor, 'bicubic');
    % 对其进行锐化处理
    sharpenedImg = imsharpen(Image_ClearPlate);
    % 使用双三次插值方法放大图像
    Image_ClearPlate = imresize(sharpenedImg , scale_factor, 'bicubic');
    axes(handles.axes3);                                                
    imshow(Image_ClearPlate, 'Parent', handles.axes3, 'InitialMagnification', 'fit'); % 显示图像
    %% 将车牌转换为灰度图像
    Gray_Image=rgb2gray(Image_ClearPlate);
    axes(handles.axes4);                                                
    imshow(Gray_Image, 'Parent', handles.axes4, 'InitialMagnification', 'fit'); % 显示图像
    %% 调整车牌的角度
    Angle = Re_Correct(Gray_Image);
    Image_Angle_Plate = imrotate(Gray_Image,Angle,'bilinear','crop');
    axes(handles.axes8);                                                
    imshow(Image_Angle_Plate, 'Parent', handles.axes8, 'InitialMagnification', 'fit'); % 显示图像
    %% 将车牌转换为二值图像
    Image_Binary = imbinarize(Image_Angle_Plate,graythresh(Image_Angle_Plate));
    if Blue==0 && Green == 1
        Image_Binary=~Image_Binary;
    end
    axes(handles.axes9);                                                
    imshow(Image_Binary, 'Parent', handles.axes9, 'InitialMagnification', 'fit'); % 显示图像
    %% 对车牌中值滤波
    Fluent_Image=medfilt2(Image_Binary);
    axes(handles.axes10);                                                
    imshow(Fluent_Image, 'Parent', handles.axes10, 'InitialMagnification', 'fit'); % 显示图像
    %% 膨胀和腐蚀
    Image_CleanPlate = bwmorph(Fluent_Image,'open',5);
    Image_CleanPlate = bwmorph(Image_CleanPlate,'hbreak',inf);                  %移除联通的像素
    Image_CleanPlate = bwmorph(Image_CleanPlate,'spur',inf);                    %移除孤立的像素
    Image_CleanPlate = bwmorph(Image_CleanPlate,'open',5);              
    % 希望目标车牌信息为白底黑字
    Image_CleanPlate = ~Image_CleanPlate;
    axes(handles.axes11);                                                
    imshow(Image_CleanPlate, 'Parent', handles.axes11, 'InitialMagnification', 'fit'); % 显示图像
    %% 投影切割出主要车牌区域
    Image_ProjectionPlate = Projection_Cut(Image_CleanPlate);
    Image_ProjectionPlate = ~Image_ProjectionPlate;
    axes(handles.axes12);                                                
    imshow(Image_ProjectionPlate, 'Parent', handles.axes12, 'InitialMagnification', 'fit'); % 显示图像
    %% 二次清除小对象
    Clear_threshold = 1024*4;
    Image_ClearPlate = bwareaopen(Image_ProjectionPlate,Clear_threshold);
    axes(handles.axes13);                                                
    imshow(Image_ClearPlate, 'Parent', handles.axes13, 'InitialMagnification', 'fit'); % 显示图像
    %% 字符区域切割
    % 转换为白底黑字
    Final_Image = ~Image_ClearPlate;
    newHeight = 896; 
    newWidth = 4736;
    Final_Image = imresize(Final_Image, [newHeight newWidth], 'bilinear');
    % 进行垂直投影切割
    [Char_Image,Char_Position,ProjectionImage] = GetCharFrom_Plate(Final_Image);
    fields = fieldnames(Char_Image);  % 获取结构体X的所有字段名称
    numFields = length(fields);
    Char_Net = handles.Char_Net;
    Number_Net = handles.Number_Net;
    String_Ans=[];
    PlatePicCount = 0;
    OriginAxes='handles.axes';
    for i=1:numFields
        
        fieldName = fields{i};
        Char_Image.(fieldName) = imresize(Char_Image.(fieldName),[1100,700],'bilinear');
        Image_Show = Char_Image.(fieldName);
        
        testImage = imresize(Char_Image.(fieldName),[28,28],'bilinear');
        testImage = ~testImage;
        imwrite(testImage,'Temp_AABBCCDD_NeverMind.jpg');
        testImage = imread('Temp_AABBCCDD_NeverMind.jpg');
        
        if PlatePicCount==0
            WrongImage = imread('WrongType_Char1.jpg');
            Judgement = Judge_ifWrongPic(WrongImage,testImage);
            if Judgement == 1
                continue;
            end
            
            WrongImage = imread('WrongType_Char2.jpg');
            Judgement = Judge_ifWrongPic(WrongImage,testImage);
            if Judgement == 1
                continue;
            end
        end
         % 构建当前轴的名称
        axesName = sprintf('handles.axes%d', PlatePicCount + 14);  % 13 + 1 = 14, 13 + 5 = 18
        % 动态获取当前轴的句柄
        hAxes = eval(axesName);
        % 在当前轴上显示图像
        axes(hAxes); % 设置当前axes
        imshow(Image_Show, 'Parent', hAxes, 'InitialMagnification', 'fit'); % 显示图像
        if PlatePicCount==0
            predictedLabel = classify(Char_Net, testImage);
        else
            predictedLabel = classify(Number_Net, testImage);
        end
       
%         imshow(testImage', 'Parent', hAxes);
        axis(hAxes, 'image'); % 适配图像和axes尺寸
        axis(hAxes, 'off');  % 关闭轴线和标签
       
        PlatePicCount=PlatePicCount+1;
        String_Ans = [String_Ans,predictedLabel];
        if (PlatePicCount == 2)
            String_Ans = [String_Ans,'·'];
        end
        if Green == 1 && Blue == 0
            if Yellow == 0
                if (PlatePicCount >= 8)
                    set(handles.axes21, 'Visible', 'on');
                    axis(handles.axes21, 'image'); % 适配图像和axes尺寸
                    axis(handles.axes21, 'off');  % 关闭轴线和标签
                    StringCellArray = cellstr(String_Ans);
                    CombinedString = strjoin(StringCellArray, '');
                    set(handles.text11, 'String', CombinedString);
                    break;
                end
            end
            if Yellow == 1
                if (PlatePicCount >= 7)
                    cla(handles.axes21, 'reset');
                    set(handles.axes21, 'Visible', 'off');
                    StringCellArray = cellstr(String_Ans);
                    CombinedString = strjoin(StringCellArray, '');
                    set(handles.text11, 'String', CombinedString);
                    break;
                end
            end
        end
        
        if Green == 0 && Blue == 1
            if (PlatePicCount >= 7)
                cla(handles.axes21, 'reset');
                set(handles.axes21, 'Visible', 'off');
                StringCellArray = cellstr(String_Ans);
                CombinedString = strjoin(StringCellArray, '');
                set(handles.text11, 'String', CombinedString);
                break;
            end
        end
        
    end
    
guidata(hObject, handles);
