% Define the input and output directories

% Get the full path of the current script
currentScriptFullPath = mfilename('fullpath');

% Extract the directory part of the full path
scriptDir = fileparts(currentScriptFullPath);

% Append the folder name to the script's directory
inputDir = fullfile(scriptDir, 'piano-88-notes');
outputDir = fullfile(scriptDir, 'augmented_files');

% Check if output directory exists; if not, create it
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Get the list of WAV files in the input directory
wavFiles = dir(fullfile(inputDir, '*.wav'));

% Step 2: Process each WAV file
for i = 1:length(wavFiles)
    filepath = fullfile(wavFiles(i).folder, wavFiles(i).name);
    [data, fs] = audioread(filepath);
    [~, name, ~] = fileparts(filepath);

    % Apply each augmentation and save the augmented data
    % Time Stretching
    stretcher = dsp.TimeStretch('SampleRate',fs,'StretchFactor',1.2);
    augmentedData = stretcher(data);
    audiowrite(fullfile(outputDir, [name '_timeStretched.wav']), augmentedData, fs);

    % Noise Addition
    augmentedData = addNoise(data, 0.05);
    audiowrite(fullfile(outputDir, [name '_noisy.wav']), augmentedData, fs);

    % Time Shifting
    augmentedData = timeShift(data, fs, 0.5);
    audiowrite(fullfile(outputDir, [name '_shifted.wav']), augmentedData, fs);

    % Volume Adjustment
    augmentedData = adjustVolume(data, 1.5);
    audiowrite(fullfile(outputDir, [name '_louder.wav']), augmentedData, fs);

    % Dynamic Range Compression
    augmentedData = dynamicRangeCompression(data, fs);
    audiowrite(fullfile(outputDir, [name '_compressed.wav']), augmentedData, fs);

    % Reverberation
    augmentedData = addReverb(data, fs);
    audiowrite(fullfile(outputDir, [name '_reverb.wav']), augmentedData, fs);

    % Low-pass Filtering
    augmentedData = lowPassFilter(data, fs, 2000);
    audiowrite(fullfile(outputDir, [name '_lowPass.wav']), augmentedData, fs);

    % Random Cropping
    augmentedData = randomCrop(data, fs, 2);
    audiowrite(fullfile(outputDir, [name '_cropped.wav']), augmentedData, fs);

    % Phase Jittering
    augmentedData = phaseJitter(data);
    audiowrite(fullfile(outputDir, [name '_jittered.wav']), augmentedData, fs);
end

