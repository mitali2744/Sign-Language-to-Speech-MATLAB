clc;
clear;

%% STEP 1: Set Alphabet 
alphabetLabel = 'space';   % Data Labeling 

%% STEP 2: Initialize Webcam (Integrated Camera)
camList = webcamlist;  % Computer Vision (Image Acquisition from Camera)
disp('Available Cameras:');
disp(camList);

% Use integrated camera
cam = webcam(1);   % Hardware Interfacing with MATLAB

%% STEP 3: Define Region of Interest (ROI)
x = 100; y = 50; width = 400; height = 400;
bboxes = [x y width height];  
% Image Processing (ROI selection for hand gesture extraction)

%% STEP 4: Prepare Saving Directory
outputFolder = fullfile('SignLanguageDataset', alphabetLabel);
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);   % File Handling ( Data Storage / Dataset Organization)
end

%% STEP 5: Capture Images
disp([' Starting capture for: ' alphabetLabel]);
maxSamples = 300;     % Dataset Size (Training Data Requirement)
imageCount = 0;

while imageCount < maxSamples
    % Capture frame
    frame = snapshot(cam);   % Image Acquisition (Camera Feed)

    % Draw ROI Box
    annotatedFrame = insertShape(frame, 'Rectangle', bboxes, ...
        'Color', 'yellow', 'LineWidth', 2);  % Image Processing (Annotation / Visualization)
    annotatedFrame = insertText(annotatedFrame, [x, y - 30], ...
        ['Capturing: ' alphabetLabel ' (' num2str(imageCount+1) '/' num2str(maxSamples) ')'], ...
        'FontSize', 18, 'BoxColor', 'green'); % Visualization of Labels

    % Show frame
    imshow(annotatedFrame);   % Display of Captured Frames
    title('Sign Language Data Capture');

    % Crop, Resize and Save Image
    croppedImg = imcrop(frame, bboxes);              % Image Processing (Cropping ROI)
    resizedImg = imresize(croppedImg, [227 227]);    % Preprocessing (Resizing for CNN input size e.g., AlexNet)
    filename = fullfile(outputFolder, ...
        [alphabetLabel '_' num2str(imageCount) '.jpg']);
    imwrite(resizedImg, filename);   % File I/O (Storing Dataset)

    imageCount = imageCount + 1;
    pause(0.1);  % Signal Processing Concept (Sampling / Frame Delay)
    drawnow;
end

%% STEP 6: Cleanup
clear cam;  % Resource Management
disp('✅ Image capture completed successfully!');
