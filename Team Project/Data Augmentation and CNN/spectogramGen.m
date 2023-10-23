% Define the directories
sourceDir = './PianoDatabase';
destDir = './SpectogramDatabase';

% Ensure destination directory exists or create it
if ~isfolder(destDir)
    mkdir(destDir);
end

% Get a list of all the WAV files in the source directory
wavFiles = dir(fullfile(sourceDir, '*.wav'));

% Loop through each WAV file to compute the mel spectrogram and save it
for idx = 1:length(wavFiles)
    % Read the WAV file
    [y, Fs] = audioread(fullfile(sourceDir, wavFiles(idx).name));
    
    % Compute the mel spectrogram
    [s, f, t] = melSpectrogram(y, Fs);
    
    % Create a filename for the spectrogram (using the same name as the source but with a .mat extension)
    specFilename = fullfile(destDir, [wavFiles(idx).name(1:end-4), '.mat']);
    
    % Save the mel spectrogram to the file
    save(specFilename, 's', 'f', 't');
end

disp('Mel spectrograms saved to SpectogramDatabase.');


