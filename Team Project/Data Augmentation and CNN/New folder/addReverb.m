%Reverberation
function reverbData = addReverb(data, fs)
    reverbEffect = reverberator('SampleRate', fs);
    reverbData = reverbEffect(data);
end