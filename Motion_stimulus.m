classdef Motion_stimulus < handle
    % a class that creates a stimulus for moving dots
    
    properties
        
        units = 'centimeters'; % for use in h_ax.Units
        size;                  % the size of the axes themselves in cm (Position - width and height)
        radius = 50;           % the radius of the stimulus itself, sets the axes data points (X/Y Lim)
        color = [0, 0, 0];     % color of the axes
        boundary = 5;
        x_axis = [1, 0];
        h_stim_ax;             % a handle to a plotted stimulus axis
        
    end
    
    methods
        
        function h_stim_ax = plot_stim(stim, h_ax)
            % creates a figure and axes for the stimulus. if axes were
            % given, modifies them accordingly
            %
            % Inputs:
            %    stim - a Motion stimulus object
            %    h_ax (Optional) - a handle to an axes object
            %
            % Outputs:
            %    h_stim_ax - a handle to the stimulus axes
            
            if nargin == 2
                h_stim_ax = h_ax;
            else
                h_stim_fig = figure('name', 'Stimulus');
                h_stim_ax = axes(h_stim_fig);
            end
            
            h_stim_ax.XLim = [-stim.radius, stim.radius];
            h_stim_ax.YLim = [-stim.radius, stim.radius];
            h_stim_ax.XColor = 'none';
            h_stim_ax.YColor = 'none';
            h_stim_ax.Color = stim.color;
            stim.h_stim_ax = h_stim_ax;
           
        end
        
        function out_bool = is_dot_in_bound(stim, dot)
            % checks if the dot reached the boundary of the stimulus
            %
            % Inputs: 
            %    stim - a Motion stimulus object
            %    dot - a dot object
            %
            % Outputs:
            %     out_bool - a bollean, 1 indicates that the dot reaced the boundary, 0 otherwise
            
            dot_vec = sqrt((dot.location(1) ^ 2) + (dot.location(2) ^ 2));
            out_bool = (dot_vec > (stim.radius - stim.boundary)); 
            
        end
        
        function val_loc = check_bound_reach(stim, dot)
            % checks if the boundary was reached. if so returns a new valid
            % location (on opposing side of the stim) for the dot to proceed, otherwise returns -1.
            %
            % Inputs: 
            %    stim - a Motion stimulus object
            %    dot - a dot object
            %
            % Outputs:
            %     val_loc - a valid location for the dot to proceed after reaching the boundary.
            %               if the dot didn't reach the boundary returns -1
            
            out_bool = stim.is_dot_in_bound(dot);
            
            if out_bool == 1 % if the dot reached the boundary
                
                dot_angle = stim.calc_angle(stim.x_axis, dot.location); % the angle between [1, 0] and the dot
                dot_dir = dot.direction;                                % the motion direction of the dot
                
                if dot.motion_pattern == "rotate" ||  stim.is_ort(dot_angle, dot_dir) % if the dot rotates or if it's direction is orthogonal to it's angle
                    
                    val_loc = stim.generate_rnd_loc();                             % generates a random location
                else
                    new_ang = wrapTo360(180 + dot_dir + dot_dir - dot_angle); % this will get the angle to the opposing side of the stim
                    new_x = (stim.radius - stim.boundary) * cosd(new_ang);    % new x component 
                    new_y = (stim.radius - stim.boundary) * sind(new_ang);    % new x component
                    val_loc = [new_x, new_y];
                end
                
            else % if the dot did not reach the boundary
                val_loc = -1;
            end
        end
        
        function rnd_loc = generate_rnd_loc(stim)
            % generates a random valid location for a dot 
            %
            % Inputs:
            %    stim - a Motion stimulus object
            %
            % Outputs:
            %    rand_loc - a random location [x, y]
            
            r = randi([stim.boundary, stim.radius]);
            deg = randi([0, 360]);
           
            x = r * cosd(deg);
            y = r * sind(deg);
           
            rnd_loc = [x, y];
        end
        
        function out_bool = is_ort(stim, dot_angle, dot_dir)
            % checks if the dot angle is orthogonal to it's vector angle.
            % returns 1 if it is, 0 otherwise
            %
            % Inputs:
            %    stim - a Motion stimulus object 
            %    dot_angle - the angle of the vector of the dot position
            %    dot_dir - the motion direction of the dot
            %
            % outputs:
            %    out_bool - 1 if the vectors are orthogonal, 0 otherwise
            
            between_ang = wrapTo360(dot_angle - dot_dir);
            
            if between_ang == 90 || between_ang == 270
                out_bool = 1;
            else
                out_bool = 0;
            end
        end
        
        function loc_mat = rand_start(stim, n)
           % this fuction will generate a matrix of locations, in the form
           % of n * 2, the rows being an [x, y] coordinate.
           % each location mus be in a valid location in respect to the
           % arena and the other locations
           %
           % Input:
           %     stim - an Motion stimulus object
           %     n  - number of locations to be created
           % Output:
           %     loc_mat a matrix of valid random location
           
           loc_mat = zeros(n, 2);
           
           for i = 1:n
               loc = stim.generate_rnd_loc();       % generates a random location in the correct range
               
               while ismember(loc, loc_mat, 'rows') % make sure the generated location wasn't generated before
                   loc = stim.generate_rnd_loc();
               end
               
               loc_mat(i, 1:2) = loc;               % inserts the location to the matrix

           end 
        end
        
        function set_stim_radius(stim, radius, was_plotted)
            % this function will set the radius of the stimulus to the one
            % given
            %
            % Inputs:
            %    stim - a Motio stimulus object
            %    radius - the wanted radius for the stimulus
            %    was_plotted - 1/0 indicating if the axes are already
            %                  plotted
            %
            % Outputs:
            %    none
            
            stim.radius = radius;
            
            if was_plotted == 1 % if the stim was plotted, change it's radius on the plotted axes
                stim.h_stim_ax.XLim = [-stim.radius, stim.radius];
                stim.h_stim_ax.YLim = [-stim.radius, stim.radius];
            end
        end
        
        function set_stim_color(stim, r_clr, g_clr, b_clr, was_plotted)
            % this function will set the color of the stimulus to the one
            % given by r_clr g_clr and b_clr
            %
            % Inputs:
            %    stim - a Motio stimulus object
            %    r_clr, g_clr, b_clr - the wanted colors for the stimulus
            %    was_plotted - 1/0 indicating if the axes are already
            %                  plotted
            %
            % Outputs:
            %    none
            
            stim.color = [r_clr, g_clr, b_clr];
            
            if was_plotted == 1 % if the stim was plotted, change it's color on the plotted axes
                stim.h_stim_ax.Color = stim.color;
            end
        end
        
    end
    
    methods (Static)
        
        function deg = calc_angle(v1, v2)
           % Function calc_angle() calculates the angle that has to be added to
           % v1 in order to rotate it to the direction of v2. Example: [1 0]
           % has to be rotated 45 deg clockwise to point towards [1 1]
           % (according to the inverted Y axis, as produced by MATLAB imaging functions)
           %
           % Inputs: 
           %    v1 - 1x2 matrix with [x, y] values of the first vector.
           %    v2 - 1x2 matrix with [x, y] values of the second vector.
           %
           % Output:
           %    deg - The angle from v1 to v2. Format: scalar, range [0 360)
           %
           % Usage:
           %    >> ang = calc_angle([1, 0], [1, 1]); % Returns [45]

            [ang1, ~] = cart2pol(v1(1), v1(2));
            [ang2, ~] = cart2pol(v2(1), v2(2));
            deg = wrapTo360(rad2deg(ang2 - ang1));
        end
       
    end
    
end