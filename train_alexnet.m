clc;
clear all;
close all;

% Path to your dataset
datasetPath = 'C:\\Users\\Mitali brahmankar\\OneDrive\\Documents\\MATLAB\\sign to speech\\SignLanguageDataset';

% Create an imageDatastore
imds = imageDatastore(datasetPath, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames', ...
    'FileExtensions', {'.jpg','.png','.bmp','.JPG','.PNG','.BMP'}); % include bmp

% Count classes
disp('Classes found:');
disp(unique(imds.Labels));

% Split dataset: 80% training, 20% validation
[imdsTrain, imdsVal] = splitEachLabel(imds, 0.8, 'randomized');

% Load AlexNet
net = alexnet;
inputSize = net.Layers(1).InputSize;  % [227 227 3]

% Modify network for your number of classes
numClasses = numel(categories(imdsTrain.Labels));
layers = net.Layers;
layers(23) = fullyConnectedLayer(numClasses);
layers(25) = classificationLayer;

% Resize images automatically using augmentedImageDatastore
augImdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain);
augImdsVal   = augmentedImageDatastore(inputSize(1:2), imdsVal);

% Training options
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 32, ...
    'ValidationData', augImdsVal, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Train network
disp('Training started...');
trainedNet = trainNetwork(augImdsTrain, layers, options);

% Save trained model
save('trainedSignNet.mat', 'trainedNet');
disp('Training complete! Model saved as trainedSignNet.mat');
