%clearvars
close all
%load('coords_test.mat')
%% Setup

% Define variables
nframes = 3;
no_points = 3;

% Import vector arrays (x=x|y|z, y=dot number, z=frame number)
%rng(1234)
%all_vects = 50.*ones(3,no_points,nframes); % TEMPORY VARIABLE!
%theta = 110;
%Rx = [1,0,0;0,cosd(theta),-sind(theta);0,sind(theta),cosd(theta)];
%all_vects(:,:,2) = Rx*all_vects(:,:,1);
%for loop = 1:499
%    all_vects(:,:,loop+1) = all_vects(:,:,loop)+1;
%end
%load('coords_test.mat')
%all_vects = permute(coords3,[2,3,1]);
%all_vects = xyz_Data;

% Preallocate output arrays
x_trans = zeros(1,nframes);
y_trans = x_trans;
z_trans = x_trans;
x_rot = x_trans;
y_rot = x_trans;
z_rot = x_trans;

%% Calculate Transformation
for trans_loop = 1:2
    %% Pick Information to Compare
    % Get all located points data for frame and frame after
    frame_matrix_all_1 = all_vects(:,:,trans_loop);
    frame_matrix_all_2 = all_vects(:,:,trans_loop+1);
    
    if length(frame_matrix_all_1) > 3
        % Select all avaliable points avaliable in BOTH frames
        capturefind_1 = ~isnan(frame_matrix_all_1(1,:));
        capturefind_2 = ~isnan(frame_matrix_all_2(1,:));
        all_cols_to_use = find(capturefind_1==capturefind_2);
        cols_to_use = all_cols_to_use;
    else
        % Be sad because three points can't be found :(
        disp(['Lost points on frame ',num2str(trans_loop)])
        cols_to_use=1:3;
    end
    
    % Get points data to calculate transform with
    frame_matrix_1 = frame_matrix_all_1(:,cols_to_use);
    frame_matrix_2 = frame_matrix_all_2(:,cols_to_use);
     
    
    %% Calculate Transformation Matrices (Horn Algorithm for Quaternions)
    
    % Calculate mean centroids
    left_cent=mean(frame_matrix_1,2);
    right_cent=mean(frame_matrix_2,2);
    
    % Subtract mean centroids from measurements
    left_adj = frame_matrix_1-left_cent;
    right_adj = frame_matrix_2-right_cent;
    
    % Extract various S components from M, and use to calculate N
    M=left_adj*right_adj.';
    Sxx = M(1); Syx = M(2); Szx = M(3); Sxy = M(4);
    Syy = M(5); Szy = M(6); Sxz = M(7); Syz = M(8); Szz = M(9);
    N=[(Sxx+Syy+Szz), (Syz-Szy),     (Szx-Sxz),      (Sxy-Syx);...
        (Syz-Szy),    (Sxx-Syy-Szz), (Sxy+Syx),      (Szx+Sxz);...
        (Szx-Sxz),    (Sxy+Syx),     (-Sxx+Syy-Szz), (Syz+Szy);...
        (Sxy-Syx),    (Szx+Sxz),     (Syz+Szy),      (-Sxx-Syy+Szz)];
    
    % Calculate eigenvalue corresponding to maximum eigenvector
    [V,D]=eig(N);
    [~,max_eig_pos]=max(real(diag(D)));
    quat=real(V(:,max_eig_pos)); 
    
    % Calculate rotation matrix
    q0=quat(1); qx=quat(2); qy=quat(3); qz=quat(4); q=quat(2:4);  
    Z=[q0,-qz,qy ; qz,q0,-qx ; -qy,qx,q0];   
    rot_matrix=(q*q')+Z^2;  
    
    trans_matrix=right_cent-rot_matrix*left_cent;
    homog_matrix = [rot_matrix,trans_matrix;[0 0 0 1]];

% Use file exchange code to test against
  regparams = absor(frame_matrix_1,frame_matrix_2);
     if min(min(round(regparams.M,2)==round(homog_matrix,2))) == 0
         disp('ahhh')
         break
     end

%% Calculate Transformations
x_trans(trans_loop) = trans_matrix(1);
x_rot(trans_loop) = atan2d(rot_matrix(3,2),rot_matrix(3,3));

y_trans(trans_loop) = trans_matrix(2);
y_rot(trans_loop) = atan2d(-rot_matrix(3,1),...
    sqrt(rot_matrix(3,2)^2+rot_matrix(3,3)^2));

z_trans(trans_loop) = trans_matrix(3);
z_rot(trans_loop) = atan2d(rot_matrix(2,1),rot_matrix(1,1));

end

% Calculate cumulative result of each transformation
x_trans = cumsum(x_trans);
y_trans = cumsum(y_trans);
z_trans = cumsum(z_trans);
x_rot = cumsum(x_rot);
y_rot = cumsum(y_rot);
z_rot = cumsum(z_rot);