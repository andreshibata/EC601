import os
import re
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tqdm import tqdm
import numpy as np

# Check if TensorFlow is able to recognize your GPU
gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        # Set TensorFlow to only allocate memory as needed, rather than upfront.
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print(f"{len(gpus)} GPU(s) is(are) available and configured to use memory growth.")
    except RuntimeError as e:
        # Memory growth must be set before GPUs have been initialized
        print(e)
else:
    print("No GPUs found. Running on CPU.")

# Define the path to your image directory
input_directory = 'mel_spectrograms'
output_directory = '.'

target_height = 308
target_width = 775

# Function to load and preprocess the image
def load_and_preprocess_image(image_path, target_size=(target_height, target_width)):
    img = load_img(image_path, target_size=target_size, color_mode='rgb')
    img_array = img_to_array(img)
    img_array = img_array.astype('float32') / 255.0  # Normalize to [0, 1]
    return img_array

# Function to extract the label from the filename
def extract_label(filename):
    match = re.search(r'(\d+-[a-z]+)', filename)
    return match.group(1) if match else None

# Load images and labels with progress bar
def load_dataset(directory):
    images = []
    labels = []
    label_map = {}  # To map labels to integers
    all_files = [f for f in os.listdir(directory) if f.endswith('.png')]
    with tqdm(total=len(all_files), desc='Loading images') as pbar:
        for filename in all_files:
            label = extract_label(filename)
            if label not in label_map:
                label_map[label] = len(label_map)
            labels.append(label_map[label])
            img_array = load_and_preprocess_image(os.path.join(directory, filename))
            images.append(img_array)
            pbar.update(1)
    return np.array(images), np.array(labels).astype('int'), label_map

# Load the dataset
images, labels, label_map = load_dataset(input_directory)

# Verify the data types
print(f'Image data type: {images.dtype}, Labels data type: {labels.dtype}')

# Define the input shape
input_shape = (308, 775, 3)  # Height, Width, Channels

# Define the number of classes
num_classes = 88  # Update this with the actual number of classes you have

# Load your images and labels

# Initialize the CNN model
model = Sequential([
    Conv2D(32, (3, 3), activation='relu',input_shape=(target_height, target_width, 3)),
    MaxPooling2D((2, 2)),
    Conv2D(64, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Conv2D(128, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Flatten(),
    Dense(128, activation='relu'),
    Dense(num_classes, activation='softmax')  # num_classes should be the number of unique labels
])

# Compile the model
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Print the model summary
model.summary()

# Use ImageDataGenerator if you want to augment your dataset
#datagen = ImageDataGenerator(rotation_range=20, width_shift_range=0.2, height_shift_range=0.2, horizontal_flip=True)

# Train the model
model.fit(images, labels, batch_size=32, epochs=10, validation_split=0.2)
# Save the trained model
model.save(os.path.join(output_directory, 'cnn_model.h5'))