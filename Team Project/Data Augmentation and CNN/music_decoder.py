import os
import subprocess
import librosa
import tensorflow as tf
from spectrogramGenerator import generate_mel_spectrogram
import soundfile as sf
import numpy as np

# Function to translate note names from '0-a' to 'A0' etc.
def translate_note_name(note):
    if '-' not in note:
        raise ValueError(f"Invalid note format: {note}")

    octave, note_name = note.split('-')
    translation = {
        'a': 'A', 'as': 'A#', 'b': 'B', 'c': 'C', 'cs': 'C#',
        'd': 'D', 'ds': 'D#', 'e': 'E', 'f': 'F', 'fs': 'F#',
        'g': 'G', 'gs': 'G#'
    }
    return translation[note_name] + octave

# Mapping from index to note name
note_mapping = {'0-a': 0, '0-as': 1, '0-b': 2, '1-a': 3, '1-as': 4, '1-b': 5, '1-c': 6, '1-cs': 7, '1-d': 8, '1-ds': 9, '1-e': 10, '1-f': 11, '1-fs': 12, '1-g': 13, '1-gs': 14, '2-a': 15, '2-as': 16, '2-b': 17, '2-c': 18, '2-cs': 19, '2-d': 20, '2-ds': 21, '2-e': 22, '2-f': 23, '2-fs': 24, '2-g': 25, '2-gs': 26, '3-a': 27, '3-as': 28, '3-b': 29, '3-c': 30, '3-cs': 31, '3-d': 32, '3-ds': 33, '3-e': 34, '3-f': 35, '3-fs': 36, '3-g': 37, '3-gs': 38, '4-a': 39, '4-as': 40, '4-b': 41, '4-c': 42, '4-cs': 43, '4-d': 44, '4-ds': 45, '4-e': 46, '4-f': 47, '4-fs': 48, '4-g': 49, '4-gs': 50, '5-a': 51, '5-as': 52, '5-b': 53, '5-c': 54, '5-cs': 55, '5-d': 56, '5-ds': 57, '5-e': 58, '5-f': 59, '5-fs': 60, '5-g': 61, '5-gs': 62, '6-a': 63, '6-as': 64, '6-b': 65, '6-c': 66, '6-cs': 67, '6-d': 68, '6-ds': 69, '6-e': 70, '6-f': 71, '6-fs': 72, '6-g': 73, '6-gs': 74, '7-a': 75, '7-as': 76, '7-b': 77, '7-c': 78, '7-cs': 79, '7-d': 80, '7-ds': 81, '7-e': 82, '7-f': 83, '7-fs': 84, '7-g': 85, '7-gs': 86, '8-c': 87}

# Function to generate a LilyPond file from notes
def create_lilypond_file(notes, ly_file_name):
    with open(ly_file_name, 'w') as file:
        file.write("\\version \"2.18.2\"\n")
        file.write("\\score {\n")
        file.write("  \\new Staff {\n")
        file.write("    \\clef treble\n")
        file.write("    \\time 4/4\n")
        file.write("    \\relative c' {\n")

        for note in notes:
            file.write(note + " ")
            # Reset to default octave ('c') after an octave-changing note
            if ',' in note or "'" in note:
                file.write("c' ")

        file.write("\n    }\n  }\n")
        file.write("  \\layout { }\n")
        file.write("  \\midi { }\n")
        file.write("}\n")
# Function to call LilyPond and generate the PDF
def generate_pdf(ly_file_name, pdf_file_name):
    lilypond_path = "C:\\Program Files (x86)\\LilyPond\\bin\\lilypond.exe"  # Adjust this path as necessary
    command = [lilypond_path, "-o", pdf_file_name, ly_file_name]
    subprocess.run(command, check=True, shell=True)

# Function to segment audio into notes
def segment_audio(file_path, segments_folder):
    print(f"Segmenting audio file: {file_path}")
    y, sr = librosa.load(file_path, sr=None)
    onsets = librosa.onset.onset_detect(y=y, sr=sr, units='samples')
    print(f"Found {len(onsets)} segments")

    # Ensure the segments folder exists
    os.makedirs(segments_folder, exist_ok=True)

    segments = []
    for i in range(len(onsets)):
        start = onsets[i]
        end = onsets[i + 1] if i < len(onsets) - 1 else len(y)
        segment_file = os.path.join(segments_folder, f'segment_{i}.wav')
        sf.write(segment_file, y[start:end], sr)
        segments.append((segment_file, start, end))

    return segments

# Main function
def music_decoder(file_path, model_path):
    segments_folder = 'segments'
    spectrograms_folder = 'spectrograms'

    # Segment the audio into notes
    segments = segment_audio(file_path, segments_folder)

    # Ensure the spectrograms folder exists
    os.makedirs(spectrograms_folder, exist_ok=True)

    # Load the pre-trained model
    print(f"Loading model from {model_path}")
    model = tf.keras.models.load_model(model_path)

    # Predict the note for each spectrogram
    predictions = []
    for segment_file, start, end in segments:
        spectrogram_file = os.path.join(spectrograms_folder, os.path.splitext(os.path.basename(segment_file))[0] + '.png')
        print(f"Generating spectrogram and predicting note for segment: {segment_file}")
        generate_mel_spectrogram(segment_file, spectrograms_folder)
        img = tf.keras.preprocessing.image.load_img(spectrogram_file, target_size=(308, 775))
        img_array = tf.keras.preprocessing.image.img_to_array(img)
        img_array = tf.expand_dims(img_array, 0)

        prediction = model.predict(img_array)
        predictions.append(prediction)

    # Translate predictions to note names
    note_predictions = []
    for prediction in predictions:
        predicted_index = np.argmax(prediction)
        note_key = [note for note, index in note_mapping.items() if index == predicted_index][0]
        predicted_note = translate_note_name(note_key)
        note_predictions.append(predicted_note)

    return note_predictions

def translate_note_name_to_lilypond(note):
    # Mapping for note conversion
    note_translation = {'C': 'c', 'D': 'd', 'E': 'e', 'F': 'f', 'G': 'g', 'A': 'a', 'B': 'b'}
    lilypond_note = note_translation[note[0]]

    # Adjusting the octave
    octave = int(note[1])
    if octave < 4:
        lilypond_note += "," * (4 - octave)
    elif octave > 4:
        lilypond_note += "'" * (octave - 4)

    return lilypond_note


if __name__ == '__main__':
    print("start")
    notes = music_decoder('acdll.wav', 'cnn_model.h5')
    print("Predicted Notes:", notes)

    lilypond_notes = [translate_note_name_to_lilypond(note) for note in notes]
    print(lilypond_notes)
    ly_file_name = 'music_score.ly'
    pdf_file_name = 'music_score'
    create_lilypond_file(lilypond_notes, ly_file_name)
    generate_pdf(ly_file_name, pdf_file_name)
    print(f"PDF created: {pdf_file_name}.pdf")