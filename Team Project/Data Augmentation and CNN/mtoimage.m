% Define the directories
inputDir = 'spectogramDatabase';
outputDir = 'spectrogramImageDatabase';

% Create the output directory if it doesn't exist
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Get a list of .mat files in the input directory
filePattern = fullfile(inputDir, '*.mat');
melFiles = dir(filePattern);

% Loop over each file and convert it to a PNG
for k = 1:length(melFiles)
    baseFileName = melFiles(k).name;
    fullFileName = fullfile(inputDir, baseFileName);
    
    % Load the mel spectrogram data from .mat file
    melSpectrogramData = load(fullFileName);
    
    % Assuming there's only one variable in each .mat file and it is the mel spectrogram
    fn = fieldnames(melSpectrogramData);
    S = melSpectrogramData.(fn{1});

    % Create a figure without displaying it
    fig = figure('Visible', 'off');

    % Plot the mel spectrogram
    imagesc(10*log10(S + eps)); % Convert power to dB
    colormap('jet'); % Set colormap (optional)
    axis xy; % Flip the axis so lower frequencies are at the bottom
    xlabel('Time');
    ylabel('Frequency');
    title('Mel Spectrogram');
    colorbar;

    % Define the output file name
    [~, name, ~] = fileparts(baseFileName);
    pngFileName = fullfile(outputDir, [name '.png']);

    % Save the figure as a PNG file
    saveas(fig, pngFileName);

    % Close the figure
    close(fig);
end

