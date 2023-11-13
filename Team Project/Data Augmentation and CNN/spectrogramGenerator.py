import os
import librosa
import librosa.display
import matplotlib.pyplot as plt
import numpy as np

def generate_mel_spectrogram(wav_file, output_folder, target_sr=22050, n_fft=2048, hop_length=512, n_mels=128, dB_min=-90, dB_max=10):
    # Ensure the output directory exists
    os.makedirs(output_folder, exist_ok=True)

    # Load the audio file and resample to target_sr
    y, sr = librosa.load(path=wav_file, sr=target_sr)

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
    output_file = os.path.join(output_folder, os.path.splitext(os.path.basename(wav_file))[0] + '.png')
    plt.savefig(output_file, bbox_inches='tight', pad_inches=0)
    plt.close()
