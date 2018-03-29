%clearvars
%close all

%% Setup

% Define variables
obj_radius_x = 90;                      % x radius of demo object (mm)
obj_radius_y = 110;                     % y radius of demo object (mm)
z_pos = 50;                             % z Start posit of object (mm)
xrad = 640;                             % Resolution in x
yrad = 480;                             % Resolution in y
zrad = 100;                             % Distance of depth sensor
nframes = 500;                          % Number of frames

%% Make Test Shape

% Increase space of axis in order to map to mm
xmult = 2;
ymult = 2;
xrad = xrad*xmult;
yrad = yrad*ymult;

% Create 2D circle/ellipse in 3D space
x=-xrad/2:xrad/2;
y=-yrad/2:yrad/2;
[X,Y]=meshgrid(x,y);
sqr = sqrt(X.^2+Y.^2);
Z=NaN.*ones(length(y),length(x));
%Z(sqr<=obj_radius) = z_pos;                                   % circle
Z(X.^2 ./ obj_radius_x^2 + Y.^2./obj_radius_y^2 <= 1) = z_pos; % ellipse

% Original displacement plot
rotimage = surf(Z,X,Y);
view([-130 15])
axis square
xlim([-100, 900])
ylim([-xrad/2,xrad/2])
set(gca,'Ydir','reverse')
zlim([-yrad/2,yrad/2])
xlabel('z (mm)')
ylabel('x (mm)')
zlabel('y (mm)')

% Define original video plot
color_size = size(color_vid_g);
color_im = uint8(zeros(color_size(1),color_size(2),3));
colormap('gray')

% Create blank movie to display at very end
mov_data(nframes) = struct('cdata',[],'colormap',[]); 

% Define translations and rotations
rng(1234) ; %1:nframes
%x_trans = 0.*ones(1,nframes);%round((xrad/2+xrad/2).*rand(nframes,1) - xrad/2);
%y_trans = 0.*ones(1,nframes);%round((yrad/2+yrad/2).*rand(nframes,1) - yrad/2);
%z_trans = 1:nframes;%0.*ones(1,nframes);%round((100).*rand(nframes,1));
%x_rot = 0.*ones(1,nframes);%round((360).*rand(nframes,1));
%y_rot = 0.*ones(1,nframes);%round((360).*rand(nframes,1));
%z_rot = 0.*ones(1,nframes);%round((360).*rand(nframes,1));
all_vects_pixel=all_vects;


%% Show output!
fig1 = figure();
%fig1.Visible='off';
for view_loop = 1:nframes
   
    % Plot video
    subplot(1,2,1)
    color_im(:,:,1) = color_vid_g(:,:,view_loop);
    color_im(:,:,2) = color_vid_g(:,:,view_loop);
    color_im(:,:,3) = color_vid_g(:,:,view_loop);
    
    % Display ~synced video at variable framerate recorded  
    image(color_im)
    
    for points = 1:size(all_vects,2)
        hold on
        plot(all_vects_pixel(2,points,view_loop),all_vects_pixel(1,points,view_loop),'rx')
    hold off
    end
    axis image
    
    % Plot translated + rotated shape
    subplot(1,2,2)
    rotimage = surf(Z+z_trans(view_loop),...
        X+x_trans(view_loop),Y+y_trans(view_loop));
    view([-130 15])
    rotate(rotimage,[1 0 0],z_rot(view_loop))
    rotate(rotimage,[0 1 0],x_rot(view_loop))
    rotate(rotimage,[0 0 1],y_rot(view_loop))
    
    % Set labels and limits
    xlim([-100, 900])
    ylim([-xrad/2,xrad/2])
    set(gca,'Ydir','reverse')
    zlim([-yrad/2,yrad/2])
    axis square
    xlabel('z (mm)')
    ylabel('x (mm)')
    zlabel('y (mm)')
    
    % Get frame being shown to create movie
    mov_data(view_loop)=getframe(gcf);
    
    % Pause to match variable framerate
    drawnow
    %disp('frame')
end

figure
movie(gcf, mov_data)