import os
import librosa
import librosa.display
import matplotlib.pyplot as plt
import numpy as np

def generate_mel_spectrograms(folder_path, output_folder, target_sr=22050, n_fft=2048, hop_length=512, n_mels=128, dB_min=-90, dB_max=10):
    # Ensure the output directory exists
    output_dir = os.path.join(folder_path, output_folder)
    os.makedirs(output_dir, exist_ok=True)

    # List all WAV files in the folder
    wav_files = [f for f in os.listdir(folder_path) if f.endswith('.wav')]

    for wav_file in wav_files:
        file_path = os.path.join(folder_path, wav_file)
        # Load the audio file and resample to target_sr
        y, sr = librosa.load(path=file_path, sr=target_sr)

        # Generate mel spectrogram with keyword arguments only
        S = librosa.feature.melspectrogram(y=y, sr=sr, n_fft=n_fft, hop_length=hop_length, n_mels=n_mels)

        # Convert to log scale (dB)
        log_S = librosa.power_to_db(S=S, ref=np.max)

        # Normalize spectrogram to be in [0, 1]
        log_S = (log_S - dB_min) / (dB_max - dB_min)
        log_S = np.clip(log_S, 0, 1)

        # Plot the spectrogram without axis, titles, or color bars
        plt.figure(figsize=(10, 4))
        librosa.display.specshow(data=log_S, sr=sr, hop_length=hop_length, x_axis='time', y_axis='mel')

        # Remove the colorbar, axis labels, and title
        plt.axis('off')

        # Save the figure without axis for CNN
        plt.savefig(os.path.join(output_dir, os.path.splitext(wav_file)[0] + '.png'), bbox_inches='tight', pad_inches=0)
        plt.close()

# Usage
generate_mel_spectrograms('PianoDatabase', 'mel_spectrograms')
