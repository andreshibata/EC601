
specDir = './SpectogramDatabase';

% Get a list of all the .mat files in the directory
matFiles = dir(fullfile(specDir, '*.mat'));

% Define a fixed size for all spectrograms
fixedSize = [128, 128];

% Initialize arrays for the spectrograms and labels
spectrograms = [];
labels = strings(length(matFiles), 1);

% Loop through each .mat file to load the spectrogram and extract the label
for idx = 1:length(matFiles)
    % Load the .mat file
    data = load(fullfile(specDir, matFiles(idx).name));
    
    % Resize the spectrogram to the fixed size
    resizedSpec = imresize(data.s, fixedSize);
    
    % Append the resized spectrogram to the array
    spectrograms = cat(3, spectrograms, resizedSpec);
    
    % Extract the label from the filename
    [~, name, ~] = fileparts(matFiles(idx).name);
    label = regexp(name, '\d-\w{1,2}$', 'match', 'once');
    labels(idx) = label;
end

% Convert labels to categorical
labels = categorical(labels);

% Split the data into training and test sets (e.g., 80% training, 20% test)
numTrain = floor(0.8 * length(matFiles));
trainIndices = randperm(length(matFiles), numTrain);
testIndices = setdiff(1:length(matFiles), trainIndices);

% ... (previous part of the script remains unchanged)

% Split the data into training and test sets (e.g., 80% training, 20% test)
numTrain = floor(0.8 * length(matFiles));
trainIndices = randperm(length(matFiles), numTrain);
testIndices = setdiff(1:length(matFiles), trainIndices);

XTrain = spectrograms(:,:,trainIndices);
YTrain = labels(trainIndices);


% Define the CNN architecture
layers = [
    imageInputLayer([size(XTrain,1) size(XTrain,2) 1])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(64)
    reluLayer
    
    fullyConnectedLayer(length(unique(labels)))
    softmaxLayer
    classificationLayer
];

options = trainingOptions('sgdm', ...
    'MaxEpochs',10, ...
    'ValidationData',{XTest, YTest}, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

% Train the CNN
net = trainNetwork(XTrain, YTrain, layers, options);

% Evaluate the trained network
YPred = classify(net, XTest);
accuracy = sum(YPred == YTest)/numel(YTest);
disp(['Test accuracy: ', num2str(accuracy*100), '%']);

