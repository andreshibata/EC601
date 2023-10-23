%Mixing
function mixedData = mixAudio(data1, data2, mixingRatio)
    mixedData = (1-mixingRatio)*data1 + mixingRatio*data2;
end
