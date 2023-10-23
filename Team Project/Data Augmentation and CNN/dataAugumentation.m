% Set the directory to the "piano-88-notes" folder in the current directory
folder_path = fullfile(pwd, 'piano-88-notes');
if ~isfolder(folder_path)
    error('Folder "piano-88-notes" does not exist in the current directory.');
end

% Get the list of all wav files in the folder
wav_files = dir(fullfile(folder_path, '*.wav'));

% Loop through each wav file
for i = 1:length(wav_files)
    file_name = fullfile(wav_files(i).folder, wav_files(i).name);
    
    % Read the audio file
    [y, Fs] = audioread(file_name);
    
    % 1. Time Stretching
    stretch_factor = 1.1;  % Example value
    y_stretched = resample(y, round(Fs*stretch_factor), Fs);
    audiowrite(fullfile(wav_files(i).folder, ['time_stretched_', wav_files(i).name]), y_stretched, round(Fs*stretch_factor));
    
    % 2. Additive Noise
    noise_level = 0.01;  % Example value
    y_noisy = y + noise_level*randn(size(y));
    audiowrite(fullfile(wav_files(i).folder, ['noisy_', wav_files(i).name]), y_noisy, Fs);
    
    % 3. Dynamic Range Compression (simplified example)
    y_compressed = compress(y, 0.6);  % You'll need a 'compress' function
    audiowrite(fullfile(wav_files(i).folder, ['compressed_', wav_files(i).name]), y_compressed, Fs);
    
    % 4. Time Shifting
    shift_samples = 4410;  % Example value for 0.1 second shift
    if size(y,2) == 2  % If stereo
        y_shifted = [zeros(shift_samples, 2); y];
    else  % If mono
        y_shifted = [zeros(shift_samples, 1); y];
    end
    audiowrite(fullfile(wav_files(i).folder, ['shifted_', wav_files(i).name]), y_shifted, Fs);

    
    % 5. Random Cropping
    crop_duration = 2; % seconds
    if length(y) > crop_duration * Fs
        start_sample_range = [1, round(length(y) - crop_duration*Fs + 1)];
    
        % Ensure the range is valid
        if start_sample_range(2) >= start_sample_range(1)
            start_sample = randi(start_sample_range);
            y_cropped = y(start_sample:start_sample + crop_duration*Fs - 1);
            audiowrite(fullfile(wav_files(i).folder, ['cropped_', wav_files(i).name]), y_cropped, Fs);
        else
            disp(['Skipping cropping for ', wav_files(i).name, ' due to insufficient length.']);
        end
    else
        disp(['Skipping cropping for ', wav_files(i).name, ' due to insufficient length.']);
    end

    
    % 7. Equalization (EQ) - Boost bass frequencies as an example
    b = fir1(30, 0.4, 'low');
    y_eq = filter(b, 1, y);
    audiowrite(fullfile(wav_files(i).folder, ['eq_', wav_files(i).name]), y_eq, Fs);

    % 8. Change in Volume
    volume_factor = 0.8;  % Decrease volume by 20%
    y_volume_changed = y * volume_factor;
    audiowrite(fullfile(wav_files(i).folder, ['volume_changed_', wav_files(i).name]), y_volume_changed, Fs);

    % 9. SpecAugment - Frequency masking (simple version)
    Y = fft(y);
    mask_start = round(0.2 * length(Y));  % Example values
    mask_end = round(0.3 * length(Y));
    Y(mask_start:mask_end) = 0;
    Y(end-mask_end:end-mask_start) = 0;  % Ensure it's symmetric
    y_masked = ifft(Y);
    audiowrite(fullfile(wav_files(i).folder, ['masked_', wav_files(i).name]), real(y_masked), Fs);

    % 10. Pitch Shifting
    % This requires a more complex algorithm and possibly a third-party toolbox.

    % 11. Random Filtering
    b = fir1(30, 0.4 + 0.2*rand(), 'bandpass');  % Random bandpass filter as an example
    y_filtered = filter(b, 1, y);
    audiowrite(fullfile(wav_files(i).folder, ['filtered_', wav_files(i).name]), y_filtered, Fs);
    
    % 12. Mixing
    % Mix the audio with white noise at 10% of its amplitude
    y_mix = y + 0.1 * randn(size(y));
    audiowrite(fullfile(wav_files(i).folder, ['mixed_', wav_files(i).name]), y_mix, Fs);
end

function y_compressed = compress(y, factor)
    % This is a very basic compression function. More advanced compression would involve
    % using an actual dynamic range compression algorithm.
    y_compressed = y .* factor;
end