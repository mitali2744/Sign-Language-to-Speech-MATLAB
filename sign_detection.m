clear;
close all;

%% Load your trained network safely
if exist('trainedSignNet.mat', 'file')
    data = load('trainedSignNet.mat');
    % Check if variable name inside .mat is trainedNet or net
    if isfield(data, 'trainedNet')
        trainedNet = data.trainedNet;
    elseif isfield(data, 'net')
        trainedNet = data.net;
    else
        error('No trained network found inside trainedSignNet.mat');
    end
else
    error('trainedSignNet.mat not found. Please place it in the same folder.');
end

%% Start webcam safely
try
    camList = webcamlist;   
    if isempty(camList)
        error('No webcam detected. Please connect a camera.');
    end
    cam = webcam(1); 
catch ME
    error('Webcam initialization failed: %s', ME.message);
end

%% Define bounding box for hand detection
bbox = [100 50 400 400];
disp('Starting real-time sign detection... Press Ctrl+C to stop.');

%% Settings for stabilization
frameCount = 0;
skipFrames = 7;             % process every 5th frame
stableThreshold = 5;        % require 5 repeats before confirming
prevLabel = "";
currentLabel = "";
repeatCount = 1;
word = "";

%% Initialize Speech Synthesizer
NET.addAssembly('System.Speech');
speaker = System.Speech.Synthesis.SpeechSynthesizer;

%% Start real-time detection
while true
    % Capture frame
    img = snapshot(cam);
    frameCount = frameCount + 1;

    % Skip frames for speed
    if mod(frameCount, skipFrames) ~= 0
        imshow(img);
        title("Waiting for frame...");
        drawnow;
        continue;
    end

    % Crop + preprocess input frame
    cropped = imcrop(img, bbox);
    cropped = imresize(cropped, [227 227]);

    % Classify the image
    try
        label = classify(trainedNet, cropped);
    catch
        error('Classification failed. Check your trained network.');
    end
    label = string(label);

    % Check stability of gesture
    if label == currentLabel
        repeatCount = repeatCount + 1;
    else
        currentLabel = label;
        repeatCount = 1;
    end

    % Confirm letter only after stability threshold
    if repeatCount >= stableThreshold && label ~= prevLabel
        if label == "SPACE"
            word = word + " ";
            % Speak the accumulated sentence when SPACE is detected
            if strlength(strtrim(word)) > 0
                SpeakText = char(strtrim(word));
                disp("Speaking: " + SpeakText);
                speaker.Speak(SpeakText);
            end
        elseif label == "DELETE"
            if strlength(word) > 0
                word = extractBefore(word, strlength(word));
            end
        else
            word = word + label;
        end
        prevLabel = label;  % Lock until a new gesture comes
    end

    % Annotate frame
    imgBox = insertShape(img, 'rectangle', bbox, 'Color', 'green');
    imgBox = insertText(imgBox, [10 10], char(label), ...
        'FontSize', 20, 'BoxColor', 'yellow', 'TextColor', 'black');
    imgBox = insertText(imgBox, [10 50], word, ...
        'FontSize', 20, 'BoxColor', 'cyan', 'TextColor', 'black');

    % Display result
    imshow(imgBox);
    title("Real-Time Sign Detection");
    drawnow;
end   