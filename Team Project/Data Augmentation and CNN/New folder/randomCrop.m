%Random Cropping
function croppedData = randomCrop(data, fs, cropDuration)
    samplesToCrop = cropDuration * fs;
    startSample = randi([1, length(data) - samplesToCrop + 1]);
    croppedData = data(startSample:startSample + samplesToCrop - 1);
end
