joints_num = 6;
positions_num = length(data);
sample_rate = 100;
fs = sample_rate;
t = 0:1/fs:(positions_num-1)/fs;

joints = struct('Name', {}, 'Positions', {});

joint_names = {'hip_left', 'hip_right', 'knee_left', 'knee_right', 'ankle_left', 'ankle_right'};
joint_positions = {data(:,1:3), data(:,4:6), data(:,7:9), data(:,10:12), data(:,13:15), data(:,16:18)};

for i = 1:joints_num
    joints(i).Name = joint_names{i};
    joints(i).Positions = joint_positions{i};
end

midpoint_vertical_angles = zeros(positions_num, 1);

for frame = 1:positions_num
    midpoint = [(joints(1).Positions(frame,1) + joints(2).Positions(frame,1))/2, ...
                (joints(1).Positions(frame,2) + joints(2).Positions(frame,2))/2];
    angle = atan2(midpoint(2), midpoint(1)) * (180 / pi);
    midpoint_vertical_angles(frame) = angle;
end

figure('Position', [100, 100, 1000, 800]);
view1 = 3;
view2 = [0, 90];
view3 = [0, 0];
axis equal;

for frame = 1:positions_num
    
    subplot(2, 2, 1);
    cla;
    hold on;
    axis([-1500 1500 0 1600 0 1200]);
    
    for i = 1:joints_num
        position = joints(i).Positions(frame, :);

        plot3(position(1), position(2), position(3), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'LineWidth', 1);
        if strcmp(joints(i).Name, 'hip_left') || strcmp(joints(i).Name, 'hip_right')
            text(position(1), position(2), position(3), joints(i).Name, 'FontSize', 10, 'Color', 'k');
        end
    end
    
    line([joints(1).Positions(frame,1), joints(2).Positions(frame,1)], ...
         [joints(1).Positions(frame,2), joints(2).Positions(frame,2)], ...
         [joints(1).Positions(frame,3), joints(2).Positions(frame,3)], ...
         'Color', 'r', 'LineWidth', 2);
    
    line([joints(1).Positions(frame,1), joints(3).Positions(frame,1), joints(5).Positions(frame,1)], ...
         [joints(1).Positions(frame,2), joints(3).Positions(frame,2), joints(5).Positions(frame,2)], ...
         [joints(1).Positions(frame,3), joints(3).Positions(frame,3), joints(5).Positions(frame,3)], ...
         'Color', 'b', 'LineWidth', 2);
     
    line([joints(2).Positions(frame,1), joints(4).Positions(frame,1), joints(6).Positions(frame,1)], ...
         [joints(2).Positions(frame,2), joints(4).Positions(frame,2), joints(6).Positions(frame,2)], ...
         [joints(2).Positions(frame,3), joints(4).Positions(frame,3), joints(6).Positions(frame,3)], ...
         'Color', 'b', 'LineWidth', 2);
    
    ankle_left_position = joints(5).Positions(frame, :);
    direction_left = ankle_left_position / norm(ankle_left_position);
    extended_position_left = ankle_left_position - 35 * direction_left;
    
    line([ankle_left_position(1), extended_position_left(1)], ...
         [ankle_left_position(2), extended_position_left(2)], ...
         [ankle_left_position(3), extended_position_left(3)], ...
         'Color', 'r', 'LineWidth', 2);
    
    ankle_right_position = joints(6).Positions(frame, :);
    direction_right = ankle_right_position / norm(ankle_right_position);
    extended_position_right = ankle_right_position - 35 * direction_right;
    
    line([ankle_right_position(1), extended_position_right(1)], ...
         [ankle_right_position(2), extended_position_right(2)], ...
         [ankle_right_position(3), extended_position_right(3)], ...
         'Color', 'r', 'LineWidth', 2);
    
    title('Walking Posture (3D View)');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    view(view1);
    
    subplot(2, 2, 2);
    cla;
    hold on;
    axis([-1500 1500 0 1600 0 1200]);
    
    for i = 1:joints_num
        position = joints(i).Positions(frame, :);

        plot3(position(1), position(2), position(3), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'LineWidth', 1);
        if strcmp(joints(i).Name, 'hip_left') || strcmp(joints(i).Name, 'hip_right')
            text(position(1), position(2), position(3), joints(i).Name, 'FontSize', 10, 'Color', 'k');
        end
    end
    
    line([joints(1).Positions(frame,1), joints(2).Positions(frame,1)], ...
         [joints(1).Positions(frame,2), joints(2).Positions(frame,2)], ...
         [joints(1).Positions(frame,3), joints(2).Positions(frame,3)], ...
         'Color', 'r', 'LineWidth', 2);
    
    line([joints(1).Positions(frame,1), joints(3).Positions(frame,1), joints(5).Positions(frame,1)], ...
         [joints(1).Positions(frame,2), joints(3).Positions(frame,2), joints(5).Positions(frame,2)], ...
         [joints(1).Positions(frame,3), joints(3).Positions(frame,3), joints(5).Positions(frame,3)], ...
         'Color', 'b', 'LineWidth', 2);
     
    line([joints(2).Positions(frame,1), joints(4).Positions(frame,1), joints(6).Positions(frame,1)], ...
         [joints(2).Positions(frame,2), joints(4).Positions(frame,2), joints(6).Positions(frame,2)], ...
         [joints(2).Positions(frame,3), joints(4).Positions(frame,3), joints(6).Positions(frame,3)], ...
         'Color', 'b', 'LineWidth', 2);
    
    ankle_left_position = joints(5).Positions(frame, :);
    direction_left = ankle_left_position / norm(ankle_left_position);
    extended_position_left = ankle_left_position - 35 * direction_left;
    
    line([ankle_left_position(1), extended_position_left(1)], ...
         [ankle_left_position(2), extended_position_left(2)], ...
         [ankle_left_position(3), extended_position_left(3)], ...
         'Color', 'r', 'LineWidth', 2);
    
    ankle_right_position = joints(6).Positions(frame, :);
    direction_right = ankle_right_position / norm(ankle_right_position);
    extended_position_right = ankle_right_position - 35 * direction_right;
    
    line([ankle_right_position(1), extended_position_right(1)], ...
         [ankle_right_position(2), extended_position_right(2)], ...
         [ankle_right_position(3), extended_position_right(3)], ...
         'Color', 'r', 'LineWidth', 2);
    
    title('Walking Posture (Front View)');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    view(view3);
    
    subplot(2, 2, 3);
    cla;
    hold on;
    hip_diff = joints(1).Positions(:,3) - joints(2).Positions(:,3);
    hip_diff_mean = mean(joints(1).Positions(:,3) - joints(2).Positions(:,3));
    plot(t, hip_diff, 'LineWidth', 1);
    plot([t(1), t(end)], [hip_diff_mean, hip_diff_mean], 'r--', 'LineWidth', 2);
    title('Difference in Height between Left and Right Hip');
    xlabel('Time (s)');
    ylabel('Hip Height Difference (mm)');
    grid on;
    legend('Hip Height Difference', ['Average: ', num2str(hip_diff_mean), ' mm'], 'Location', 'best');
    
    subplot(2, 2, 4);
    cla;
    hold on;
    midpoint_vertical_angle_mean = mean(midpoint_vertical_angles);
    plot(t, midpoint_vertical_angles, 'LineWidth', 1);
    plot([t(1), t(end)], [midpoint_vertical_angle_mean, midpoint_vertical_angle_mean], 'r--', 'LineWidth', 2);
    title('Vertical Direction Angles of Midpoint between Hips');
    xlabel('Time (s)');
    ylabel('Angle (degrees)');
    grid on;
    legend('Angle', ['Average: ', num2str(midpoint_vertical_angle_mean), ' degrees'], 'Location', 'best');
    
    pause(0.01);
end
