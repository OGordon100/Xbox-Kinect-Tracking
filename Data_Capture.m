%% Oliver Gordon & Lukas Rier Xbox Kinect Project

% Setup
clear all;
close all; 
imaqreset;

% Define variables
ctrast = 0;                                     % Contrast from -127:127
expsure = 0;                                    % Exposure from -11:-1
nframes = 100;                                  % Frames to capture

% Enforce lowest avaliable quality
sens_info = imaqhwinfo('winvideo');
qual_all = sens_info.DeviceInfo.SupportedFormats;
qual = char(qual_all(end));

% Create the video inputs
color_vid = videoinput('winvideo',1,qual);
depth_vid = videoinput('winvideo',2,qual);
triggerconfig([color_vid depth_vid],'manual');

% Apply contrast
colourinfo = getselectedsource(color_vid);
depthinfo = getselectedsource(depth_vid);
%colourinfo.Contrast = ctrast;
%depthinfo.Contrast = ctrast;


% depthsnapshots = uint16(zeros(480, 640, nframes));

%%

timer = zeros(1,nframes);

start([color_vid, depth_vid])
for loop = 1:nframes
tic
snapshot1 = getsnapshot(color_vid);
snapshot2 = getsnapshot(depth_vid);
%subplot(121)
%imshow(snapshot1)
%subplot(122)
%imagesc(snapshot2)
%axis image
%axis off
%drawnow
% pause(1/30);
timer(loop) = toc;
end
stop([color_vid,depth_vid])

% Calculate frames per second
disp(['Frames Per Second = ',num2str(1/mean(timer))]);