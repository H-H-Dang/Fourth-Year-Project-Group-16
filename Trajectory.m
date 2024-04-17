N = 1668;
Fs = 125;
Fc = 0.01;
G = 9.81;
dt = 1/Fs;
decim = 1;
threshold = 1;
OrientationFormat = 'Rotation matrix';
% AcceNoise = 5.0909e-12 * Fs;
% Accebias_X = 3.725922779922781;
% Accebias_Y = -7.342023166023176;
% Accebias_Z = 1.026424061776062e+03;
% GyroNoise = 6.8539e-8 * Fs;
Gyrobias_X = 0.299544401544402;
Gyrobias_Y = 1.065891891891891;
Gyrobias_Z = 0.034972972972973;

LeftKneeAcc = [data(:,1).*0.001.*9.81 data(:,2).*0.001.*9.81 data(:,3).*0.001.*9.81];
LeftKneeAnv = [(data(:,4)-Gyrobias_X).*pi./180 (data(:,5)-Gyrobias_Y).*pi./180 (data(:,6)-Gyrobias_Z).*pi./180];
LeftKneeMag = [data(:,7) data(:,8) data(:,9)];

LeftKneeAcc_processed = LeftKneeAcc;
LeftKneeAnv_processed = LeftKneeAnv;
LeftKneeMag_processed = LeftKneeMag;

for j = 1:3
    Q1_acc = quantile(LeftKneeAcc(:,j), 0.25);
    Q3_acc = quantile(LeftKneeAcc(:,j), 0.75);
    IQR_acc = Q3_acc - Q1_acc;

    lower_bound_acc = Q1_acc - 1.5 * IQR_acc;
    upper_bound_acc = Q3_acc + 1.5 * IQR_acc;

    outlier_idx_acc = LeftKneeAcc(:,j) < lower_bound_acc | LeftKneeAcc(:,j) > upper_bound_acc;
    LeftKneeAcc_processed(outlier_idx_acc, j) = 0;

    Q1_anv = quantile(LeftKneeAnv(:,j), 0.25);
    Q3_anv = quantile(LeftKneeAnv(:,j), 0.75);
    IQR_anv = Q3_anv - Q1_anv;

    lower_bound_anv = Q1_anv - 1.5 * IQR_anv;
    upper_bound_anv = Q3_anv + 1.5 * IQR_anv;

    outlier_idx_anv = LeftKneeAnv(:,j) < lower_bound_anv | LeftKneeAnv(:,j) > upper_bound_anv;
    LeftKneeAnv_processed(outlier_idx_anv, j) = 0;
end

FUSE = imufilter('SampleRate', Fs, 'DecimationFactor', decim, 'OrientationFormat', OrientationFormat);
[rotm, Anv] = FUSE(LeftKneeAcc_processed, LeftKneeAnv_processed);

acceleration_geo = zeros(N, 3);
velocity = zeros(N, 3);
position = zeros(N, 3);
[B, A] = butter(2, Fc/(Fs/2), 'high');

for i = 1:N
    acceleration_geo(i, :) = (rotm(:,:,i) * LeftKneeAcc(i, :)')' - [0, 0, G];
    if i == 1
        velocity(i, :) = [0, 0, 0];
    else
        velocity(i, :) = velocity(i-1, :) + acceleration_geo(i, :) * dt;
    end
end

velocity_filtered = filtfilt(B, A, velocity);
for k = 1:N
    if k == 1
        position(k, :) = [0, 0, 0];
    else
        position(k, :) = position(k-1, :) + velocity_filtered(k, :) * dt;
    end
end

eul = rotm2eul(rotm);

figure(1)
time = (0:decim:N-1) / Fs;
plot(time,eul)
title('The orientation of the sensor versus time')
legend('Z-axis', 'Y-axis', 'X-axis')
xlabel('Time (s)')
ylabel('Rotation (degrees)')

figure(2)
plot3(position(:,1),position(:,2),position(:,3))
xlabel('North (m)')
ylabel('East (m)')
zlabel('Down (m)')
title('The trajectory of the sensor')
grid on
x_max = max(position(:,1));
hold on;
quiver3(0, 0, 0, x_max, 0, 0, 'LineWidth', 1.5, 'Color', 'r', 'MaxHeadSize', 1, 'AutoScale', 'on')
hold off;