clear all; close all; clc

PathRoot = 'v1.0_mini_us_radar_data';
Scene = 'scene-0553';
nSamples = 240;
FolderCalib = 'CALIBRATION';
mode = 'r';
fileType = '.csv';

HEADER_RADAR  = {'x','y','z','dyn_prop','id','rcs','vx','vy','vx_comp','vy_comp','is_quality_valid','ambig_state', ...
                 'x_rms','y_rms','invalid_state','pdh0','vx_rms','vy_rms'};
             
EXTRINSIC_CALIB_HEADERS  = {'SampleNo','Tx','Ty','Tz','Q11','Q12','Q21','Q22'};

Calibration_Radar = struct;
Calibration_Radar.R1 = double(csvread(strcat(PathRoot, '\', Scene, '\', FolderCalib, '\', 'RADAR_FRONT', '_calib',fileType),1,0));
Calibration_Radar.R2 = double(csvread(strcat(PathRoot, '\', Scene, '\', FolderCalib, '\', 'RADAR_FRONT_LEFT', '_calib',fileType),1,0));
Calibration_Radar.R3 = double(csvread(strcat(PathRoot, '\', Scene, '\', FolderCalib, '\', 'RADAR_BACK_LEFT', '_calib',fileType),1,0));
Calibration_Radar.R4 = double(csvread(strcat(PathRoot, '\', Scene, '\', FolderCalib, '\', 'RADAR_BACK_RIGHT', '_calib',fileType),1,0));
Calibration_Radar.R5 = double(csvread(strcat(PathRoot, '\', Scene, '\', FolderCalib, '\', 'RADAR_FRONT_RIGHT', '_calib',fileType),1,0));

% For plotting the data
PX_R1 = zeros(150, 240); PY_R1 = zeros(150, 240);
PX_R2 = zeros(150, 240); PY_R2 = zeros(150, 240);
PX_R3 = zeros(150, 240); PY_R3 = zeros(150, 240);
PX_R4 = zeros(150, 240); PY_R4 = zeros(150, 240);
PX_R5 = zeros(150, 240); PY_R5 = zeros(150, 240);

VX_R1 = zeros(150, 240); VY_R1 = zeros(150, 240);
VX_R2 = zeros(150, 240); VY_R2 = zeros(150, 240);
VX_R3 = zeros(150, 240); VY_R3 = zeros(150, 240);
VX_R4 = zeros(150, 240); VY_R4 = zeros(150, 240);
VX_R5 = zeros(150, 240); VY_R5 = zeros(150, 240);

RadarPointCloudList = {};
gifFileName = strcat('RadarPointCloudMovie_',Scene);
GIFsaveFolder = 'Visualize';
mkdir(GIFsaveFolder);

figure(1); plot(0,0);pause();
disp('make the plot window full size and press any key to continue');
for t = 1:nSamples
    RadarData = struct;
    RadarData.R1 = double(csvread(strcat(PathRoot, '\', Scene, '\', 'RADAR_FRONT', '\',num2str(t),fileType),1,0));
    RadarData.R2 = double(csvread(strcat(PathRoot, '\', Scene, '\', 'RADAR_FRONT_LEFT', '\',num2str(t),fileType),1,0));
    RadarData.R3 = double(csvread(strcat(PathRoot, '\', Scene, '\', 'RADAR_BACK_LEFT', '\',num2str(t),fileType),1,0));
    RadarData.R4 = double(csvread(strcat(PathRoot, '\', Scene, '\', 'RADAR_BACK_RIGHT', '\',num2str(t),fileType),1,0));
    RadarData.R5 = double(csvread(strcat(PathRoot, '\', Scene, '\', 'RADAR_FRONT_RIGHT', '\',num2str(t),fileType),1,0));
    
    TranslationVecR1 = (Calibration_Radar.R1(t,2:4))';
    TranslationVecR2 = (Calibration_Radar.R2(t,2:4))';
    TranslationVecR3 = (Calibration_Radar.R3(t,2:4))';
    TranslationVecR4 = (Calibration_Radar.R4(t,2:4))';
    TranslationVecR5 = (Calibration_Radar.R5(t,2:4))';
    
    QuarternionVecR1 = Calibration_Radar.R1(t,5:8);
    QuarternionVecR2 = Calibration_Radar.R2(t,5:8);
    QuarternionVecR3 = Calibration_Radar.R3(t,5:8);
    QuarternionVecR4 = Calibration_Radar.R4(t,5:8);
    QuarternionVecR5 = Calibration_Radar.R5(t,5:8);
    
    Rot_R1 = Convert_Quaternion_to_Eular(QuarternionVecR1);
    Rot_R2 = Convert_Quaternion_to_Eular(QuarternionVecR2);
    Rot_R3 = Convert_Quaternion_to_Eular(QuarternionVecR3);
    Rot_R4 = Convert_Quaternion_to_Eular(QuarternionVecR4);
    Rot_R5 = Convert_Quaternion_to_Eular(QuarternionVecR5);
    
    Radar1_Px_Py = Rot_R1 * (RadarData.R1(:,1:3))' + TranslationVecR1;
    Radar2_Px_Py = Rot_R2 * (RadarData.R2(:,1:3))' + TranslationVecR2;
    Radar3_Px_Py = Rot_R3 * (RadarData.R3(:,1:3))' + TranslationVecR3;
    Radar4_Px_Py = Rot_R4 * (RadarData.R4(:,1:3))' + TranslationVecR4;
    Radar5_Px_Py = Rot_R5 * (RadarData.R5(:,1:3))' + TranslationVecR5;
    
    Radar1_Vx_Vy = Rot_R1 * ([RadarData.R1(:,7:8), zeros(length(RadarData.R1(:,1)), 1)])';
    Radar2_Vx_Vy = Rot_R2 * ([RadarData.R2(:,7:8), zeros(length(RadarData.R2(:,1)), 1)])';
    Radar3_Vx_Vy = Rot_R3 * ([RadarData.R3(:,7:8), zeros(length(RadarData.R3(:,1)), 1)])';
    Radar4_Vx_Vy = Rot_R4 * ([RadarData.R4(:,7:8), zeros(length(RadarData.R4(:,1)), 1)])';
    Radar5_Vx_Vy = Rot_R5 * ([RadarData.R5(:,7:8), zeros(length(RadarData.R5(:,1)), 1)])';
    
    %figure(1); markerSize = 10; marker = '.';
    %plot(Radar1_Px_Py(1,:), Radar1_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    %plot(Radar2_Px_Py(1,:), Radar2_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    %plot(Radar3_Px_Py(1,:), Radar3_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    %plot(Radar4_Px_Py(1,:), Radar4_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    %plot(Radar5_Px_Py(1,:), Radar5_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    %xlabel('longitudinal range x (m)');ylabel('lateral range y (m)');
    %legend('RADAR FRONT','RADAR FRONT LEFT','RADAR BACK LEFT','RADAR BACK RIGHT','RADAR FRONT RIGHT','Location','northeast');
    %set(gca,'XLim',[-150 150]); set(gca,'YLim',[-150 150]); hold off;
    %pause();
    RadarPointCloudList = createListOfPlots(Scene,Radar1_Px_Py, Radar2_Px_Py, Radar3_Px_Py, Radar4_Px_Py, Radar5_Px_Py,RadarPointCloudList,t);

    PX_R1(1:1:length(Radar1_Px_Py(1,:)),t) = Radar1_Px_Py(1,:)'; PY_R1(1:1:length(Radar1_Px_Py(2,:)),t) = Radar1_Px_Py(2,:)';
    PX_R2(1:1:length(Radar2_Px_Py(1,:)),t) = Radar2_Px_Py(1,:)'; PY_R2(1:1:length(Radar2_Px_Py(2,:)),t) = Radar2_Px_Py(2,:)';
    PX_R3(1:1:length(Radar3_Px_Py(1,:)),t) = Radar3_Px_Py(1,:)'; PY_R3(1:1:length(Radar3_Px_Py(2,:)),t) = Radar3_Px_Py(2,:)';
    PX_R4(1:1:length(Radar4_Px_Py(1,:)),t) = Radar4_Px_Py(1,:)'; PY_R4(1:1:length(Radar4_Px_Py(2,:)),t) = Radar4_Px_Py(2,:)';
    PX_R5(1:1:length(Radar5_Px_Py(1,:)),t) = Radar5_Px_Py(1,:)'; PY_R5(1:1:length(Radar5_Px_Py(2,:)),t) = Radar5_Px_Py(2,:)';
    
    VX_R1(1:1:length(Radar1_Vx_Vy(1,:)),t) = Radar1_Vx_Vy(1,:)'; VY_R1(1:1:length(Radar1_Vx_Vy(2,:)),t) = Radar1_Vx_Vy(2,:)';
    VX_R2(1:1:length(Radar2_Vx_Vy(1,:)),t) = Radar2_Vx_Vy(1,:)'; VY_R2(1:1:length(Radar2_Vx_Vy(2,:)),t) = Radar2_Vx_Vy(2,:)';
    VX_R3(1:1:length(Radar3_Vx_Vy(1,:)),t) = Radar3_Vx_Vy(1,:)'; VY_R3(1:1:length(Radar3_Vx_Vy(2,:)),t) = Radar3_Vx_Vy(2,:)';
    VX_R4(1:1:length(Radar4_Vx_Vy(1,:)),t) = Radar4_Vx_Vy(1,:)'; VY_R4(1:1:length(Radar4_Vx_Vy(2,:)),t) = Radar4_Vx_Vy(2,:)';
    VX_R5(1:1:length(Radar5_Vx_Vy(1,:)),t) = Radar5_Vx_Vy(1,:)'; VY_R5(1:1:length(Radar5_Vx_Vy(2,:)),t) = Radar5_Vx_Vy(2,:)';
    
    disp(t);
end
saveAsGIFImage(RadarPointCloudList, gifFileName, GIFsaveFolder, nSamples);

Vel_R1 = sqrt(VX_R1.*VX_R1 + VY_R1.*VY_R1);
Vel_R2 = sqrt(VX_R2.*VX_R2 + VY_R2.*VY_R2);
Vel_R3 = sqrt(VX_R3.*VX_R3 + VY_R3.*VY_R3);
Vel_R4 = sqrt(VX_R4.*VX_R4 + VY_R4.*VY_R4);
Vel_R5 = sqrt(VX_R5.*VX_R5 + VY_R5.*VY_R5);

% ==============================================================================================================================================================
function Rot = Convert_Quaternion_to_Eular(Q)
     
    % First row of the rotation matrix
    r00 = 2 * (Q(1) * Q(1) + Q(2) * Q(2)) - 1;
    r01 = 2 * (Q(2) * Q(3) - Q(1) * Q(4));
    r02 = 2 * (Q(2) * Q(4) + Q(1) * Q(3));
     
    % Second row of the rotation matrix
    r10 = 2 * (Q(2) * Q(3) + Q(1) * Q(4));
    r11 = 2 * (Q(1) * Q(1) + Q(3) * Q(3)) - 1;
    r12 = 2 * (Q(3) * Q(4) - Q(1) * Q(2));
     
    % Third row of the rotation matrix
    r20 = 2 * (Q(2) * Q(4) - Q(1) * Q(3));
    r21 = 2 * (Q(3) * Q(4) + Q(1) * Q(2));
    r22 = 2 * (Q(1) * Q(1) + Q(4) * Q(4)) - 1;
     
    % 3x3 rotation matrix
    Rot = [r00, r01, r02; ...
           r10, r11, r12; ...
           r20, r21, r22];
                            
end
% ==============================================================================================================================================================
function imgList = createListOfPlots(SceneName,Radar1_Px_Py, Radar2_Px_Py, Radar3_Px_Py, Radar4_Px_Py, Radar5_Px_Py,imgList,t)
    h = figure(1);
    markerSize = 10; marker = '.';
    plot(Radar1_Px_Py(1,:), Radar1_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    plot(Radar2_Px_Py(1,:), Radar2_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    plot(Radar3_Px_Py(1,:), Radar3_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    plot(Radar4_Px_Py(1,:), Radar4_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    plot(Radar5_Px_Py(1,:), Radar5_Px_Py(2,:),marker,'markersize', markerSize); axis equal;hold on;
    grid on;
    radarCaptureFrequency = 13; %13hz
    delayTime = 1/radarCaptureFrequency;
    title(strcat(SceneName,': ',' Measurements from 5 Radars at',[' ' num2str(sprintf('%.2f', delayTime*(t-1)))], ' sec' ), 'FontSize', 15);
    %title('Measurements from 5 Radars');
    xlabel('longitudinal range x (m)');ylabel('lateral range y (m)');
    legend('RADAR FRONT','RADAR FRONT LEFT','RADAR BACK LEFT','RADAR BACK RIGHT','RADAR FRONT RIGHT','Location','northeast');
    set(gca,'XLim',[-150 150]); set(gca,'YLim',[-150 150]); hold off;
    frame = getframe(h);
    imgList{t} = frame2im(frame);
    disp(t);
end
% ==============================================================================================================================================================
function saveAsGIFImage(imgList, GIFname, pathGIFsave, T)
    imageOut = strcat(pathGIFsave, '\', strcat(GIFname, '.gif'));
    start = 3;
    radarCaptureFrequency = 13; %13hz
    delayTime = 1/radarCaptureFrequency;
    for idx = start:T
        [A,map] = rgb2ind(imgList{idx},256);
        if idx == start
           imwrite(A,map,imageOut,'gif','LoopCount',Inf,'DelayTime',delayTime);
        else
           imwrite(A,map,imageOut,'gif','WriteMode','append','DelayTime',delayTime);
        end
    end
end
% ==============================================================================================================================================================

