%Noise Addition
function noisyData = addNoise(data, noiseLevel)
    noise = noiseLevel * randn(size(data));
    noisyData = data + noise;
end
