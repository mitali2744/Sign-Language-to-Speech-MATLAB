clc;
clear;
close all;

% Main dataset folder
mainFolder = 'C:\Users\Mitali brahmankar\OneDrive\Documents\MATLAB\sign to speech\SignLanguageDataset';

% Create subfolder for SPACE gesture
datasetPath = fullfile(mainFolder, 'SPACE');
if ~exist(datasetPath, 'dir')
    mkdir(datasetPath);
end

% Connect to webcam
cam = webcam;

% Define fixed bounding box [x y width height]
bbox = [100 50 400 400];  % adjust as needed

disp('Starting automatic SPACE gesture capture...');

numImages = 300;  % total images to capture
imgCount = 1;

figure;

while imgCount <= numImages
    % Capture frame
    frame = snapshot(cam);

    % Crop region of interest
    cropped = imcrop(frame, bbox);

    % Optional resize (if your network requires it)
    % cropped = imresize(cropped, [227 227]);

    % Save image inside SPACE folder
    fileName = fullfile(datasetPath, sprintf('space_%03d.png', imgCount));
    imwrite(cropped, fileName);
    fprintf('Saved: %s\n', fileName);
    imgCount = imgCount + 1;

    % Annotate
    frameBox = insertShape(frame, 'rectangle', bbox, 'Color', 'green', 'LineWidth', 3);
    frameBox = insertText(frameBox, [10 10], sprintf('Captured: %d/%d', imgCount-1, numImages), ...
        'FontSize',20,'BoxColor','yellow','TextColor','black');

    % Display
    imshow(frameBox);
    drawnow;

    % Small pause to avoid duplicates
    pause(0.1);
end

disp('Finished capturing 300 SPACE gesture images.');

% Clear camera
clear cam;
close all;
