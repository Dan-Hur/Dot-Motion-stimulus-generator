% ================================= Opening / Closing function =====================================
function varargout = motion_stimulus_generator(varargin)
    % MOTION_STIMULUS_GENERATOR MATLAB code for motion_stimulus_generator.fig
%      MOTION_STIMULUS_GENERATOR, by itself, creates a new MOTION_STIMULUS_GENERATOR or raises the existing
%      singleton*.
%
%      H = MOTION_STIMULUS_GENERATOR returns the handle to a new MOTION_STIMULUS_GENERATOR or the handle to
%      the existing singleton*.
%
%      MOTION_STIMULUS_GENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTION_STIMULUS_GENERATOR.M with the given input arguments.
%
%      MOTION_STIMULUS_GENERATOR('Property','Value',...) creates a new MOTION_STIMULUS_GENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before motion_stimulus_generator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to motion_stimulus_generator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help motion_stimulus_generator

    % Last Modified by GUIDE v2.5 20-Jan-2021 13:53:20

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @motion_stimulus_generator_OpeningFcn, ...
                       'gui_OutputFcn',  @motion_stimulus_generator_OutputFcn, ...
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
end

function motion_stimulus_generator_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to motion_stimulus_generator (see VARARGIN)
    
    handles.output = hObject;
    
    global msg_db;
    
    % ================================ Button configuration ========================================
    
    handles.green_clr = [0.392, 0.831, 0.075];
    handles.red_clr = [1, 0, 0];
    handles.play_str = 'Play';
    handles.stop_str = 'Stop';
    handles.dot1_rot_dir_popupmenu.Enable = 'off';
    handles.dot1_dir_edit_txt.Enable = 'off';
    handles.dot2_rot_dir_popupmenu.Enable = 'off';
    handles.dot2_dir_edit_txt.Enable = 'off';
    
    % ============================== stim and dot configuration ====================================
    
    handles.stim = Motion_stimulus();                             % creates a motion stimulus object
    handles.h_stim_ax = handles.stim.plot_stim(handles.h_gui_ax); % plots the stimulus on the axes
    msg_db.dot1_arr = create_dot_arr(handles.stim, 10);           % creates the dot1 array
    msg_db.dot2_arr = create_dot_arr(handles.stim, 10);           % creates the dot2 array
    plot_dots(handles.h_stim_ax, msg_db.dot1_arr, 0);             % plots the dots from arr 1 on stim axes
    plot_dots(handles.h_stim_ax, msg_db.dot2_arr, 0);             % plots the dots from arr 2 on stim axes
    msg_db.n_dots1 = 10;            % saves the current number of dots in array 1
    msg_db.n_dots2 = 10;            % saves the current number of dots in array 2
    msg_db.change_n_dots1 = [0, 0]; % the change to be applied to the number of dots in the array 1
    msg_db.change_n_dots2 = [0, 0]; % the change to be applied to the number of dots in the array 2
    min_dot_size = 20;
    max_dot_size = 300;
    min_dot_spd = 1;
    max_dot_spd = 40;
    
    % next i set the sliders
    
    set(handles.dot1_size_slider, 'Min', min_dot_size, 'Max', max_dot_size, 'Value', min_dot_size...
        , 'SliderStep', [1/(max_dot_size - min_dot_size), 1/(max_dot_size - min_dot_size)]);
    
    set(handles.dot2_size_slider, 'Min', min_dot_size, 'Max', max_dot_size, 'Value', min_dot_size...
        , 'SliderStep', [1/(max_dot_size - min_dot_size), 1/(max_dot_size - min_dot_size)]);
    
    set(handles.dot1_spd_slider, 'Min', min_dot_spd, 'Max', max_dot_spd, 'Value', min_dot_spd...
        , 'SliderStep', [1/(max_dot_spd - min_dot_spd), 1/(max_dot_spd - min_dot_spd)]);
    
    set(handles.dot2_spd_slider, 'Min', min_dot_spd, 'Max', max_dot_spd, 'Value', min_dot_spd...
        , 'SliderStep', [1/(max_dot_spd - min_dot_spd), 1/(max_dot_spd - min_dot_spd)]);
    
    % ===================================== Listeners ==============================================
    
    handles.h_dot1_size_list = addlistener(handles.dot1_size_slider, 'Value', 'PostSet', ...
        @dot1_size_lis_Callback);
    
    handles.h_dot2_size_list = addlistener(handles.dot2_size_slider, 'Value', 'PostSet', ...
        @dot2_size_lis_Callback);
    
    handles.h_dot1_spd_list = addlistener(handles.dot1_spd_slider, 'Value', 'PostSet', ...
        @dot1_spd_lis_Callback);
    
    handles.h_dot2_spd_list = addlistener(handles.dot2_spd_slider, 'Value', 'PostSet', ...
        @dot2_spd_lis_Callback);
    
    % ====================================== Timers ================================================
    
    handles.h_play_tmr = timer('ExecutionMode', 'fixedSpacing', 'Period', 0.001, 'TimerFcn',...
        {@play_timer_Callback, hObject});
    
    % =================================== File managment ===========================================
    
    guidata(hObject, handles);
end

function varargout = motion_stimulus_generator_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

function h_gui_fig_CloseRequestFcn(hObject, eventdata, handles)
    
    global msg_db;
    
    stop(handles.h_play_tmr);
    delete(handles.h_play_tmr);
    clear msg_db;
    
    delete(hObject);
end

% ======================================== Callbacks ===============================================

function play_button_Callback(hObject, eventdata, handles)
    % hObject    handle to play_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.h_play_tmr.Running == "on"
        stop(handles.h_play_tmr);
        hObject.ForegroundColor = handles.green_clr;
        hObject.String = handles.play_str;
        return
    end
    
    hObject.ForegroundColor = handles.red_clr;
    hObject.String = handles.stop_str;
    start(handles.h_play_tmr);
end

function play_timer_Callback(h_timer, eventdata, hObject)
    
    handles = guidata(hObject);
    one_ani_loop(handles, hObject, 0);
    
end

% ====================== Dot 1 =================================

function dot1_num_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_num_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    global msg_db;
    num_str = hObject.String;            % gets the user defined string
    arr_len = msg_db.n_dots1;            % gets the array length
    num_val = check_num_format(num_str); % checks the number guven by the user
    
    if num_val == -1 % if the value is not formatted well, cancel
        hObject.String = num2str(arr_len);
        return
    end
    
    num_diff = calc_dot_diff(num_val, arr_len); % creates a formatted matrix, indicating the needed change in the current array
    msg_db.change_n_dots1 = num_diff;           % saves the matrix to the database

end

function dot1_pattern_popupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_pattern_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    str = hObject.String;
    val = hObject.Value;
    usr_choice = str{val};
    
    if usr_choice == "rand"
        handles.dot1_rot_dir_popupmenu.Enable = 'off';
        handles.dot1_dir_edit_txt.Enable = 'off';
    elseif usr_choice == "trans"
        handles.dot1_rot_dir_popupmenu.Enable = 'off';
        handles.dot1_dir_edit_txt.Enable = 'on';
    elseif usr_choice == "rotate"
        handles.dot1_rot_dir_popupmenu.Enable = 'on';
        handles.dot1_dir_edit_txt.Enable = 'off';
    end
    
end

function dot1_dir_edit_txt_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_dir_edit_txt (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    deg_str = hObject.String;
    deg_val = check_deg_dir(deg_str);
    
    if deg_val == -1
        hObject.String = '0';
        return
    end
    
end

function dot1_rot_dir_popupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_rot_dir_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % this does nothing ¯\_(ツ)_/¯
    
end

function dot1_r_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_r_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    usr_str = hObject.String;
    rgb_val = check_rgb_format(usr_str);
    
    if rgb_val == -1 % checks for a bad input
        hObject.String = 1;
        return
    end
    
end

function dot1_g_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_g_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    usr_str = hObject.String;
    rgb_val = check_rgb_format(usr_str);
    
    if rgb_val == -1 % checks for a bad input
        hObject.String = 1;
        return
    end
    
end

function dot1_b_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_b_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    usr_str = hObject.String;
    rgb_val = check_rgb_format(usr_str);
    
    if rgb_val == -1 % checks for a bad input
        hObject.String = 1;
        return
    end
    
end

function dot1_set_button_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_set_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    global msg_db;
    
    arr_len = msg_db.n_dots1;        % gets the length of the array
    num_mod = msg_db.change_n_dots1; % gets the wanted change in dots
    stim = handles.stim;             % gets the stimulus
    msg_db.n_dots1 = modify_dot1_arr(num_mod, stim, arr_len); % changes the array and length based on user input
    handles.dot1_num_static_text.String = msg_db.n_dots1;     % changes the text in the GUI to indicate current num of dots
    msg_db.change_n_dots1 = [0, 0];                           % resets the operation to be done on dot num
    size_fact = 50 / str2double(handles.axes_rad_edit_text.String); % a scaling factor for rotational motion based on stim radius
    
    [pat_str, dot_dir, rot_ppm_str, r_clr, g_clr, b_clr, ...
        dot_size, dot_spd] = get_dot_param(handles, 1); 
    
    for dot = msg_db.dot1_arr % sets the parameters fot dot1 array
        dot.set_mot_pat(pat_str{1});
        if pat_str{1} == "rand" % sets a random direction for the random dots
            dot_dir = randi([0, 360]);
        end
        dot.set_dir(dot_dir);
        dot.rot_dir = rot_ppm_str{1};
        dot.set_dot_color([r_clr, g_clr, b_clr])
        dot.set_dot_size(dot_size);
        dot.set_spd(dot_spd, size_fact);
    end
end

function dot1_size_slider_Callback(hObject, eventdata, handles)
    % this function will plot the change in dot size after setting the
    % slider, if the loop isn't running
    
    % this does nothing ¯\_(ツ)_/¯
end

function dot1_size_lis_Callback(~, eventdata)
    % this function will be executed to change i real time the size of the
    % dots
    
    global msg_db;
    handles = guidata(eventdata.AffectedObject);
    dot_size = handles.dot1_size_slider.Value;
    dot_size = round(dot_size, 1);
    handles.dot1_size_text.String = num2str(dot_size);
    
    for dot = msg_db.dot1_arr
        dot.set_dot_size(dot_size);
    end
    
end

function dot1_spd_slider_Callback(hObject, eventdata, handles)
    % hObject    handle to dot1_spd_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % this does nothing ¯\_(ツ)_/¯
end

function dot1_spd_lis_Callback(~, eventdata)
    % this function will change the dot speed in real time
    
    global msg_db;
    handles = guidata(eventdata.AffectedObject);
    dot_spd = handles.dot1_spd_slider.Value;
    dot_spd = round(dot_spd, 1);
    handles.dot1_spd_text.String = num2str(dot_spd);
    
    for dot = msg_db.dot1_arr
        dot.set_spd(dot_spd);
    end
    
end

% ====================== Dot 2 =================================

function dot2_num_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_num_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    global msg_db;
    num_str = hObject.String;            % gets the user defined string
    arr_len = msg_db.n_dots2;            % gets the array length
    num_val = check_num_format(num_str); % checks the number guven by the user
    
    if num_val == -1 % if the value is not formatted well, cancel
        hObject.String = num2str(arr_len);
        return
    end
    
    num_diff = calc_dot_diff(num_val, arr_len); % creates a formatted matrix, indicating the needed change in the current array
    msg_db.change_n_dots2 = num_diff;           % saves the matrix to the database
end

function dot2_pattern_popupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_pattern_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    str = hObject.String;
    val = hObject.Value;
    usr_choice = str{val};
    
    if usr_choice == "rand"
        handles.dot2_rot_dir_popupmenu.Enable = 'off';
        handles.dot2_dir_edit_txt.Enable = 'off';
    elseif usr_choice == "trans"
        handles.dot2_rot_dir_popupmenu.Enable = 'off';
        handles.dot2_dir_edit_txt.Enable = 'on';
    elseif usr_choice == "rotate"
        handles.dot2_rot_dir_popupmenu.Enable = 'on';
        handles.dot2_dir_edit_txt.Enable = 'off';
    end
    
end

function dot2_dir_edit_txt_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_dir_edit_txt (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    deg_str = hObject.String;
    deg_val = check_deg_dir(deg_str);
    
    if deg_val == -1
        hObject.String = '0';
        return
    end
    
end

function dot2_rot_dir_popupmenu_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_rot_dir_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % this also does nothing ¯\_(ツ)_/¯
end

function dot2_r_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_r_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    usr_str = hObject.String;
    rgb_val = check_rgb_format(usr_str);
    
    if rgb_val == -1 % checks for a bad input
        hObject.String = 1;
        return
    end
    
end

function dot2_g_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_g_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    usr_str = hObject.String;
    rgb_val = check_rgb_format(usr_str);
    
    if rgb_val == -1 % checks for a bad input
        hObject.String = 1;
        return
    end
    
end

function dot2_b_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_b_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    usr_str = hObject.String;
    rgb_val = check_rgb_format(usr_str);
    
    if rgb_val == -1 % checks for a bad input
        hObject.String = 1;
        return
    end
    
end

function dot2_set_button_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_set_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    global msg_db;
    
    arr_len = msg_db.n_dots2;        % gets the length of the array
    num_mod = msg_db.change_n_dots2; % gets the wanted change in dots
    stim = handles.stim;             % gets the stimulus
    msg_db.n_dots2 = modify_dot2_arr(num_mod, stim, arr_len); % changes the array and length based on user input
    handles.dot1_num_static_text.String = msg_db.n_dots2;     % changes the text in the GUI to indicate current num of dots
    msg_db.change_n_dots2 = [0, 0]; % resets the operation to be done on dot num  
    
    [pat_str, dot_dir, rot_ppm_str, r_clr, g_clr, b_clr,...
        dot_size, dot_spd] = get_dot_param(handles, 2);
    
    for dot = msg_db.dot2_arr % sets the parameters fot dot1 array
        dot.set_mot_pat(pat_str{1});
        if pat_str{1} == "rand"  % sets a random direction for the random dots
            dot_dir = randi([0, 360]);
        end
        dot.set_dir(dot_dir);
        dot.rot_dir = rot_ppm_str{1};
        dot.set_dot_color([r_clr, g_clr, b_clr])
        dot.set_dot_size(dot_size);
        dot.set_spd(dot_spd);
    end
    
end

function dot2_size_slider_Callback(hObject, eventdata, handles)
    % this function will plot the change in dot size after setting the
    % slider, if the loop isn't running

    % this does nothing ¯\_(ツ)_/¯
    
end

function dot2_size_lis_Callback(~, eventdata)
    % this function will be executed to change i real time the size of the
    % dots
    
    global msg_db;
    handles = guidata(eventdata.AffectedObject);
    dot_size = handles.dot2_size_slider.Value;
    dot_size = round(dot_size, 1);
    handles.dot2_size_text.String = num2str(dot_size);
    
    for dot = msg_db.dot2_arr
        dot.set_dot_size(dot_size);
    end
    
end

function dot2_spd_slider_Callback(hObject, eventdata, handles)
    % hObject    handle to dot2_spd_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % this does nothing ¯\_(ツ)_/¯
end

function dot2_spd_lis_Callback(~, eventdata)
    
    global msg_db;
    handles = guidata(eventdata.AffectedObject);
    dot_spd = handles.dot2_spd_slider.Value;
    dot_spd = round(dot_spd, 1);
    handles.dot2_spd_text.String = num2str(dot_spd);
    
    for dot = msg_db.dot2_arr
        dot.set_spd(dot_spd);
    end
    
end

% ====================== Axes =================================

function axes_rad_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to axes_rad_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    num_str = hObject.String;
    num_val = check_num_format(num_str, 1);
    
    if num_val == -1
        hObject.String = 50;
        return
    end
end

function axes_r_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to axes_r_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    rgb_str = hObject.String;
    rgb_val = check_rgb_format(rgb_str);
    
    if rgb_val == -1
        hObject.String = 0;
        return
    end

end

function axes_g_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to axes_g_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    rgb_str = hObject.String;
    rgb_val = check_rgb_format(rgb_str);
    
    if rgb_val == -1
        hObject.String = 0;
        return
    end
end

function axes_b_edit_text_Callback(hObject, eventdata, handles)
    % hObject    handle to axes_b_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    rgb_str = hObject.String;
    rgb_val = check_rgb_format(rgb_str);
    
    if rgb_val == -1
        hObject.String = 0;
        return
    end
end

function set_axes_button_Callback(hObject, eventdata, handles)
    % hObject    handle to set_axes_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    radius = str2double(handles.axes_rad_edit_text.String);
    r_clr = str2double(handles.axes_r_edit_text.String);
    g_clr = str2double(handles.axes_g_edit_text.String);
    b_clr = str2double(handles.axes_b_edit_text.String);
    
    handles.stim.set_stim_radius(radius, 1);
    handles.stim.set_stim_color(r_clr, g_clr, b_clr, 1);
end

% ====================== Video and Save/Load =================================

function export_vid_button_Callback(hObject, eventdata, handles)
    % hObject    handle to export_vid_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    global msg_db;
    file_ext = ".mp4";
    check_msg = msgbox('Make sure the dot parameters are correct.', 'Parameter Check');
    waitfor(check_msg); % does not continue execution until the msgbox is closed
    
    [did_fail, full_path, num_of_vids, vid_len, vid_size, vid_fps] = check_vid_param();
    
    if did_fail == 1 % cancels execution if the parameters are incorrect
        return
    end
    
    if handles.h_play_tmr.Running == "on" % checks if the animation loop is running
        play_button_Callback(handles.play_button, eventdata, handles); % stops animation loop
    end
    
    handles.play_button.Enable = 'off';     % disables the play button
    handles.dot1_set_button.Enable = 'off'; % disables changes in parameters
    handles.dot2_set_button.Enable = 'off';
    handles.set_axes_button.Enable = 'off';
    [stim, h_fig, h_stim_ax] = create_vid_stim(vid_size, handles); % creates a new figure and stimulus
    
    for dot = msg_db.dot1_arr 
        dot.was_plotted = 0;        % allows for re-plotting
        dot.plot_dot(h_stim_ax, 1); % plots the dots on the new axis
    end
    
    for dot = msg_db.dot2_arr
        dot.was_plotted = 0;        % allows for re-plotting
        dot.plot_dot(h_stim_ax, 1); % plots the dots on the new axis
    end
    
    num_of_frames = round(vid_len * vid_fps);
    set(h_fig, 'InvertHardcopy', 'off'); % allows for pring to work properly
    
    for i = 1:num_of_vids % goes over the total num of wanted vids
        
        iter_num = num2str(i);
        final_name = append(full_path{1}, "_", iter_num, file_ext); % creates a different name for each file
        randomize_loc_dir(stim);                                    % randomizes dot locations and directions
        h_vid_file = VideoWriter(final_name, 'MPEG-4');             % creates the video file, and next configures it
        h_vid_file.Quality = 100;
        h_vid_file.FrameRate = vid_fps;
        open(h_vid_file);
        
        for j = 1:num_of_frames % saves the wanted amount of frames in the file
            one_ani_loop(handles, hObject, 1, stim)
            stim_img = print(h_fig, '-RGBImage', '-r120');
            writeVideo(h_vid_file, stim_img);
        end
        
        close(h_vid_file);
    end
    
    handles.play_button.Enable = 'on';     % enables the play button again
    handles.dot1_set_button.Enable = 'on'; % enables changes in parameters
    handles.dot2_set_button.Enable = 'on';
    handles.set_axes_button.Enable = 'on';
    delete_h_dot2() % deletes the handle to the current axis for all dots
    delete(h_fig);  % deletes the figure
end

% ========================================== CreateFcn =============================================
% ====================== Dot 1 =================================

function dot1_num_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_num_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function dot1_pattern_popupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_pattern_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot1_dir_edit_txt_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_dir_edit_txt (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function dot1_rot_dir_popupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_rot_dir_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function dot1_r_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_r_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot1_g_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_g_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot1_b_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_b_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot1_size_slider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_size_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
end

function dot1_spd_slider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot1_spd_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% ====================== Dot 2 =================================

function dot2_num_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_num_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

end

function dot2_pattern_popupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_pattern_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot2_dir_edit_txt_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_dir_edit_txt (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot2_rot_dir_popupmenu_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_rot_dir_popupmenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot2_r_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_r_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

end

function dot2_g_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_g_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot2_b_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_b_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function dot2_size_slider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_size_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
end

function dot2_spd_slider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dot2_spd_slider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% ====================== Axes =================================

function axes_rad_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to axes_rad_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function axes_r_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to axes_r_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function axes_g_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to axes_g_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

function axes_b_edit_text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to axes_b_edit_text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

% ============================================ debug ===============================================

% ======================================= helper functions =========================================

function dot_arr = create_dot_arr(stim, n_dots, dot_arr)
    % this function will create an array of Dot objects
    %
    % Inputs:
    %    stim - a Motion stimulus object
    %    n_dots - number of dots in the array
    %    old_arr (Optional) - an array of dots, to which this func will
    %    append n_dots
    %
    % outputs:
    %    dot_arr - an array of dots
    
    if nargin ~= 3
        dot_arr = Dot.empty();
    end
    
    for i = 1:n_dots
        loc = stim.generate_rnd_loc();
        dot_arr(end+1) = Dot(loc);
    end
    
end

function randomize_dot_locs(stim, dot_arr)
    % this function will randomize the location for all dots in the array
    %
    % Inputs:
    %    stim - a Motion stimulus object
    %    dot_arr - an array of dot objects
    %
    % Outputs:
    %    none
    
    for dot = dot_arr
        loc = stim.generate_rnd_loc();
        dot.location = loc;
    end
end

function plot_dots(h_ax, dot_arr, sec_ax_bool)
    % this function will plot all dots in the array on a given axis.
    %
    % Inputs:
    %    h_ax - handle to an axis object
    %    dot arr - an array of Dot objects
    %    sec_ax_bool - a boolean (0/1) indicating if the plotting
    %                  is to be done on a different axis
    %
    % outputs:
    %    none
    
    for dot = dot_arr
       dot.plot_dot(h_ax, sec_ax_bool);
    end
end

function one_ani_loop(handles, hObject, sec_ax_bool, stim)
    % this function will simulate one iteration of stimulus animation, for
    % all dots (both arrays)
    %
    % Input:
    %    handles - handles object
    %    hObject - current graphical object
    %    sec_ax_bool - a boolean (0/1) indicating if the plotting
    %                  is to be done on a different axis
    %    stim (Optional) - a different stimulus to plot on
    %
    % Output:
    %    none
    
    global msg_db;
    
    dot_arr1 = msg_db.dot1_arr;
    dot_arr2 = msg_db.dot2_arr;
    
    if nargin < 4 % checks if a different stimulus was not given
        cur_stim = handles.stim;
        h_ax = handles.h_stim_ax;
    else
        h_ax = stim.h_stim_ax;
        cur_stim = stim;
    end
    
    for dot = dot_arr1
        dot.update_dot(cur_stim)
        dot.plot_dot(h_ax, sec_ax_bool);
    end
    
    for dot= dot_arr2
        dot.update_dot(cur_stim)
        dot.plot_dot(h_ax, sec_ax_bool);
    end
    
    drawnow();
end

function num_diff = calc_dot_diff(n_dots, arr_len)
    % this functionwill calculate the difference between the curren dot
    % array length, and the given dot amount, and will save the result in msg_db.
    % the result format will be a matrix of 1x2, where the first value will
    % be either -1, 0 or 1, and the second will be the difference between
    % n_dots and the length of the dot array. ex - [{-1/0/1}, n]
    %
    % Inputs:
    %    n_dots - the wanted number of dots for the array
    %    arr_len - length of the dot array
    %
    % Outputs:
    %    diff_out = a 1x2 matrix of the form [{-1/0/1}, n]. -1 if
    %               n_dots < arr_len, 0 if n_dots == arr_len and 1 if n_dots > arr_len.

    if n_dots == arr_len
        num_diff = [0, 0];
        
    elseif n_dots > arr_len
        dot_diff = n_dots - arr_len;
        num_diff = [1, dot_diff];
        
    elseif n_dots < arr_len
        dot_diff = arr_len - n_dots;
        num_diff = [-1, dot_diff];
    end
end

function num_val = check_num_format(num_str, is_rad)
    % this function will check if the input is an acceptable number of
    % dots, meaning a positive number between 0 and 500 (can be changed).
    % also checks axes radius string format. the max for them is 200.
    %
    % Inputs:
    %    num_str - a string (given by user) for format check
    %    is_rad - can be anything, indicates that the radius string is
    %             being checked
    %
    % Outputs:
    %    num_val - if formatted correctly, returns the num_str converted to double.
    %              returns -1 otherwise.
    
    num_val = str2double(num_str);
    
    if nargin == 1 % checks if a radius string was given to apply change to max value
        max = 500;
        over_max_str = "Don't make too many dots!";
        over_max_title = 'Dot overload';
    elseif nargin == 2
        max = 200;
        over_max_str = "Don't make the axes too big!";
        over_max_title = 'Big axes size';
    end
    
    if isnan(num_val) % makes sure a number was written
        bad_num_msg = msgbox('Please use numbers only!', 'Bad Input', 'warn');
        num_val = -1;
        return
    elseif num_val < 0 % makes sure the number is positive (or 0)
        neg_num_msg = msgbox("Can't make less dots than 0!", "Don't be negative", 'warn');
        num_val = -1;
        return
    elseif num_val > max % just in case, ok to remove if the computer is strong
        hi_num_msg = msgbox(over_max_str, over_max_title, 'warn');
        num_val = -1;
        return
    end
end

function deg_val = check_deg_dir(deg_str)
    % this function will check if the input is an acceptable degree,
    % meaning it is a positive number between 0 and 360.
    %
    % Inputs:
    %    deg_str - a string (given by user) for format check
    %
    % Outputs:
    %    deg_val - if formatted correctly, returns the deg_str converted to double.
    %              returns -1 otherwise.
    
    deg_val = str2double(deg_str);
    
    if isnan(deg_val)
        bad_num_msg = msgbox('Please use numbers only!', 'Bad Input', 'warn');
        deg_val = -1;
        return
    elseif deg_val < 0 || deg_val > 360
        out_rng_msg = msgbox('Please use numbers between 0 and 360', 'Out of range', 'warn');
        deg_val = -1;
        return
    end
    
end

function rgb_val = check_rgb_format(rgb_str)
    % this function will check if the input is suitable for scatter RGB format,
    % neaning it is a number between 0 and 1.
    %
    % Inputs:
    %    rgb_str - a string (given by user) for format check
    %
    % Outputs:
    %    rgb_val - if formatted correctly, returns the rgb_str converted to double
    %              returns -1 otherwise
    
    rgb_val = str2double(rgb_str);
    
    if isnan(rgb_val)
        bad_num_msg = msgbox('Please use numbers only!', 'Bad Input', 'warn');
        rgb_val = -1;
        return
    elseif rgb_val < 0 || rgb_val > 1
        out_rng_msg = msgbox('Please use numbers between 0 and 1', 'Out of range', 'warn');
        rgb_val = -1;
        return
    end
end

function new_n_dots = modify_dot1_arr(num_mod, stim, arr_len)
    % this function will recieve a dot array and modify it based on the second argument 
    % which will be matrix representing the manipulation of the form
    % [{-1/0/1}, n]. -1 means substracting elements from the array, 0 means
    % leaving th array as it is, and 1 means adding elements. n is the
    % number of elements.
    %
    % Inputs:
    %    dot_arr - an array of Dot objects
    %    num_mod - a matrix representing the manipulation ([{-1/0/1}, n])
    %    stim - a motion stimulus object
    %    len_arr - length of the dot array
    %
    % Outputs:
    %    none
    
    global msg_db;
    
    operation = num_mod(1);
    n_change = num_mod(2);
    
    if operation == 0 % checks what operation was given, executes it, 0 - do nothing.
        new_n_dots = arr_len;
        return

    elseif operation == -1 % -1 - removes n_change dots
        indx_reduct = arr_len - n_change + 1; % gets the index from which to start deleting dots
        for i = indx_reduct:arr_len
            delete(msg_db.dot1_arr(i).h_dot);
            delete(msg_db.dot1_arr(i));
            clear msg_db.dot1_arr(i);
        end
        
        msg_db.dot1_arr(indx_reduct:end) = [];
        new_n_dots = arr_len - n_change;
        
    elseif operation == 1  % 1 - adds n_change dots
        
        for i = 1:n_change
            rnd_loc = stim.generate_rnd_loc();
            msg_db.dot1_arr(end + 1) = Dot(rnd_loc);
        end
        new_n_dots = arr_len + n_change;
    end
    
end

function new_n_dots = modify_dot2_arr(num_mod, stim, arr_len)
    % this function will recieve a dot array and modify it based on the second argument 
    % which will be matrix representing the manipulation of the form
    % [{-1/0/1}, n]. -1 means substracting elements from the array, 0 means
    % leaving th array as it is, and 1 means adding elements. n is the
    % number of elements.
    %
    % Inputs:
    %    dot_arr - an array of Dot objects
    %    num_mod - a matrix representing the manipulation ([{-1/0/1}, n])
    %    stim - a motion stimulus object
    %    len_arr - length of the dot array
    %
    % Outputs:
    %    none
    
    global msg_db;
    
    operation = num_mod(1);
    n_change = num_mod(2);
    
    if operation == 0 % checks what operation was given, executes it, 0 - do nothing.
        new_n_dots = arr_len;
        return

    elseif operation == -1 % -1 - removes n_change dots
        indx_reduct = arr_len - n_change + 1; % gets the index from which to start deleting dots
        for i = indx_reduct:arr_len
            delete(msg_db.dot2_arr(i).h_dot);
            delete(msg_db.dot2_arr(i));
            clear msg_db.dot2_arr(i);
        end
        
        msg_db.dot2_arr(indx_reduct:end) = [];
        new_n_dots = arr_len - n_change;
        
    elseif operation == 1  % 1 - adds n_change dots
        
        for i = 1:n_change
            rnd_loc = stim.generate_rnd_loc();
            msg_db.dot2_arr(end + 1) = Dot(rnd_loc);
        end
        new_n_dots = arr_len + n_change;
    end
    
end

function [pat_str, dot_dir, rot_ppm_str, r_clr, g_clr, b_clr,...
    dot_size, dot_spd] = get_dot_param(handles, array_num)
    % this function will get all needed parameter of the dot
    % array(indicated by array_num)
    %
    % Inputs:
    %     handles - structure with handles and user data
    %     array_num - the number of the wanted array parameters- 1/2
    %
    % Outputs:
    %    pat_str - the pattern string for the relevant array
    %    pat_idx - the pattern index for the relevant array string
    %    dot_dir - the direction for the relevant array
    %    rot_ppm_str - the rotational direction string for the relevant array
    %    rot_ppm_idx - the rotational direction index for the relevant array string
    %    [r_clr, g_clr, b_clr] - the colors for the relevant array (given
    %                            separately)
    %    dot_size - the size of the dot
    %    dot_spd - the speed of the dot
    
    if array_num == 1
        pat_full_str = handles.dot1_pattern_popupmenu.String;
        pat_idx = handles.dot1_pattern_popupmenu.Value;         
        pat_str = pat_full_str(pat_idx);                        % gets the pattern for the dot
        dot_dir = handles.dot1_dir_edit_txt.String;             % gets the translational direction string
        rot_ppm_full_str = handles.dot1_rot_dir_popupmenu.String;
        rot_ppm_idx = handles.dot1_rot_dir_popupmenu.Value;     
        rot_ppm_str = rot_ppm_full_str(rot_ppm_idx);            % gets the rorational direction
        r_clr = handles.dot1_r_edit_text.String;                % this an the two below get color strings
        g_clr = handles.dot1_g_edit_text.String;
        b_clr = handles.dot1_b_edit_text.String; 
        [dot_dir, r_clr, g_clr, b_clr] = double_check_vars(dot_dir, r_clr, g_clr, b_clr);
        dot_size = handles.dot1_size_slider.Value;
        dot_spd = handles.dot1_spd_slider.Value;
        
    elseif array_num == 2
        pat_full_str = handles.dot2_pattern_popupmenu.String;
        pat_idx = handles.dot2_pattern_popupmenu.Value;         
        pat_str = pat_full_str(pat_idx);                        % gets the pattern for the dot
        dot_dir = handles.dot2_dir_edit_txt.String;             % gets the translational direction string
        rot_ppm_full_str = handles.dot2_rot_dir_popupmenu.String;
        rot_ppm_idx = handles.dot2_rot_dir_popupmenu.Value;     
        rot_ppm_str = rot_ppm_full_str(rot_ppm_idx);            % gets the rorational direction
        r_clr = handles.dot2_r_edit_text.String;                % this and the two below get color strings
        g_clr = handles.dot2_g_edit_text.String;
        b_clr = handles.dot2_b_edit_text.String;    
        [dot_dir, r_clr, g_clr, b_clr] = double_check_vars(dot_dir, r_clr, g_clr, b_clr);
        dot_size = handles.dot2_size_slider.Value;
        dot_spd = handles.dot2_spd_slider.Value;
        
    end
end

function [dot_dir, r_clr, g_clr, b_clr] = double_check_vars(dot_dir, r_clr, g_clr, b_clr)
    % checks for given variables, if they are formatted correctly
    %
    % Inputs
    %     handles - structure with handles and user data
    %
    % Outputs:
    %    dot_dir - the direction for the relevant array
    %    [r_clr, g_clr, b_clr] - the colors for the relevant array (given
    %                            separately)   
    
    r_val = check_rgb_format(r_clr);
    g_val = check_rgb_format(g_clr);
    b_val = check_rgb_format(b_clr);
    dir_val = check_deg_dir(dot_dir);
    
    % next i check if any text separately is formatted incorrectly and
    % change it to a valid format
    
    if dir_val == -1
        dir_val = 0;
    end
    
    if r_val == -1 
        r_val = 1;
    end
    
    if g_val == -1
        g_val = 1;
    end
    
    if b_val == -1
        b_val = 1;
    end
    
    % next I set all the outputs to the correct value
    
    dot_dir = dir_val;
    r_clr = r_val;
    g_clr = g_val;
    b_clr = b_val;
    
end

function name_out = check_file_name(f_name)
    % this function will check the format of a file name
    %
    % Inputs:
    %    f_name - a name for a file without extensions (in a cell)
    %
    % Outputs:
    %    name_out - returns -1 if the name was formated incorrectly,
    %               returns 1 otherwise
    
    bad_chars = '<>:"/\|*.?!';
    
    if isempty(f_name) || isempty(f_name{1}) % checks if the user input was canceled 
        name_out = -1;
        cancel_file_msg = msgbox('Process canceled', 'Process Canceled', 'warn');
        return
    end
    
    f_name_str = f_name{1};
    bad_char_check = ismember(bad_chars, f_name_str); % returns a vector of 0/1, based on presence of bad chars
        
    if any(bad_char_check) % checks if any of the bad chars are in the name,
        name_out = -1;
        bad_char_msg = msgbox('Bad characters entered! aborting.', 'Bad Name', 'error');
        
    else
        name_out = 1;
    end
end

function num_val = check_vids(n_vids, n_type)
    % this function will check the format of numbers of videos and video lengths. 
    %
    % Inputs:
    %    n_vids - the number of vids chosen (in a cell), or length for the
    %             video
    %    n_type - 1 indicates number of videos, 0 indicates video length, 2
    %             indicates video size
    %
    % Outputs:
    %    num_va - returns -1 if the input was bad, otherwise returns the
    %             number of vids as double
    
    if n_type == 1
        bad_n_vid_msg = 'Too many videos! aborting.';
        max_n = 50;
    elseif n_type == 0
        bad_n_vid_msg = 'The video is too long! aborting.';
        max_n = 60;
    elseif n_type == 2
        bad_n_vid_msg = 'The video is too big! aborting.';
        max_n = 20;
    end
    
    if isempty(n_vids) || isempty(n_vids{1}) % checks if the user input was canceled 
        num_val = -1;
        cancel_file_msg = msgbox('Process canceled', 'Process Canceled', 'warn');
        return
    end
    
    num_vids = str2double(n_vids{1});
    
    if isnan(num_vids) % if the number given is bad / contains bad chars, this will catch it
        num_val = -1;
        bad_char_msg = msgbox('Bad characters entered! aborting.', 'Bad Name', 'error');
        
    elseif num_vids < 0
        num_val = -1;
        neg_num_msg = msgbox("This value can't be negative, aborting.", 'Negative Values', 'error');
        
    elseif num_vids > max_n % just in case, restricts the num of videos
        num_val = -1;
        bad_max_n_msg = msgbox(bad_n_vid_msg, 'Video Overload', 'error');
    
    else
        num_val = num_vids;
    end
end

function [did_fail, full_path, num_of_vids, vid_len, vid_size, vid_fps] = check_vid_param()
    % this function will check all parameter needed to create the videos
    %
    % Inputs:
    %    none
    %
    % Outputs:
    %    did_fail - checks if any of the tests failed, returns 1 if any did
    %    full_path - path(if exists) + name of the file (no extensions)
    %    num_of_vids - number of videos to make
    %    vid_len - length of the video in seconds
    %    vid_fps - the frames per second for the vid
    
    file_name = inputdlg('Choose file name (no extension):', 'File Name', 1, {'dot_motion_vid'});
    name_out = check_file_name(file_name); % checks if the file name is ok
    
    if name_out == -1 % cancles the execution if the name is bad
        did_fail = 1;
        [full_path, num_of_vids, vid_len, vid_size, vid_fps] = deal(0 ,0 ,0 ,0, 0);
        return
    end
    
    file_path = inputdlg('Choose file path (default is the current folder):', 'File path', 1);
    
    if isempty(file_path) % checks if a path was given
        path_exist = -1;
    else
        path_exist = exist(file_path{1}, 'dir'); % checks if the folder exists
    end
    
    if path_exist ~= 7 % if the pathway was bad, names the full file based on name alone, o.w creates thw full path
        full_path = file_name;
        def_dir_msg = msgbox('Videos will be saved in current (default) folder', 'No Path');
        waitfor(def_dir_msg);
    else
        full_path = fullfile(file_path, file_name);
    end
    
    n_vids = inputdlg('Choose number of videos to export:', 'Num of vids', 1, {'1'});
    num_of_vids = check_vids(n_vids, 1);   % checks if the numbre of vids is ok
    
    if num_of_vids == -1 % cancels if the num of vids was bad
        did_fail = 1;
        [full_path, num_of_vids, vid_len, vid_size, vid_fps] = deal(0 ,0 ,0 ,0, 0);
        return
    end
    
    vid_len_choice = inputdlg('Choose the length of the exported videos (in seconds):',...
        'Video length', 1, {'0.5'});
    vid_len = check_vids(vid_len_choice, 0); % checks for video length
    
    if vid_len == -1 % cancels if video length was bad
        did_fail = 1;
        [full_path, num_of_vids, vid_len, vid_size, vid_fps] = deal(0 ,0 ,0 ,0, 0);
        return
    end
    
    vid_size_choice = inputdlg('Choose the size of the exported videos (in cm):',...
        'Video Size', 1, {'10'});
    vid_size = check_vids(vid_size_choice, 2);
    
    if vid_size == -1 % cancels if video length was bad
        did_fail = 1;
        [full_path, num_of_vids, vid_len, vid_size, vid_fps] = deal(0 ,0 ,0 ,0, 0);
        return
    end
    
    fps_choice = questdlg('How many frames per second?', 'Choose FPS',...
        '60 fps', '30 fps', '60 fps');
    
    switch fps_choice % checks what fps was given
        case '60 fps'
            vid_fps = 60;
        case '30 fps'
            vid_fps = 30;
        otherwise     % if the process was closed, cancels execution
            [full_path, num_of_vids, vid_len, vid_size, vid_fps] = deal(0 ,0 ,0 ,0, 0);
            cancel_fps_msg = msgbox('Process canceled', 'Process Canceled', 'warn');
            waitfor(cancel_fps_msg);
            did_fail = 1;
            return 
    end
    
    did_fail = 0;

end

function [stim, h_fig, h_stim_ax] = create_vid_stim(vid_size, handles)
    % this function will create the figure and axes for the video createion
    %
    % Inputs:
    %    vid_size - size of the wanted figure in cm
    %
    % Outputs:
    %    stim - a Motion stimulus object
    %    h_stim_ax - axes to new stimulus
    
    stim = Motion_stimulus;
    h_fig = figure('Units', 'centimeters');
    h_fig.Position(3) = vid_size;
    h_fig.Position(4) = vid_size;
    h_ax = axes(h_fig);
    set(h_ax, 'Units', 'centimeters');
    fig_pos = h_fig.Position;
    set(h_ax, 'Position', [0, 0 , fig_pos(3), fig_pos(4)]); % makes the axes fill all of the figure
    stim.radius = str2double(handles.axes_rad_edit_text.String);
    r_clr = str2double(handles.axes_r_edit_text.String);
    g_clr = str2double(handles.axes_g_edit_text.String);
    b_clr = str2double(handles.axes_b_edit_text.String);
    stim.color = [r_clr, g_clr, b_clr];
    h_stim_ax = stim.plot_stim(h_ax);
    
    
end

function randomize_loc_dir(stim)
    % this function will randomize the location of all dots, and if their
    % pattern is 'rand' , randomizes theis direction as well
    %
    % Inputs:
    %    stim - a stimulus on which to plot
    %
    % Outputs:
    %    none
    
    global msg_db;
    
    for dot = msg_db.dot1_arr 
        loc = stim.generate_rnd_loc();
        dot.location = loc;
        if dot.motion_pattern == "rand"
            dot.direction = randi([0, 360]);
        end    
    end
    
    for dot = msg_db.dot2_arr 
        loc = stim.generate_rnd_loc();
        dot.location = loc;
        if dot.motion_pattern == "rand"
            dot.direction = randi([0, 360]);
        end    
    end
    
end

function delete_h_dot2()
    % this function will delete the handle to the plotted dot on the second
    % axis
    %
    % Inputs & Outputs:
    %    none
    
    global msg_db;
    
    for dot = msg_db.dot1_arr 
        delete(dot.h_dot2);
    end
    
    for dot = msg_db.dot2_arr 
        delete(dot.h_dot2);
    end
        
end
% ==================================================================================================
