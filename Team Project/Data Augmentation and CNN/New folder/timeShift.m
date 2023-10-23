%Time Shifting
function shiftedData = timeShift(data, fs, shiftSeconds)
    shiftAmount = round(shiftSeconds * fs);
    shiftedData = circshift(data, shiftAmount);
end
