%Time Stretching
function stretchedData = timeStretch(data, fs, stretchFactor)
    stretcher = dsp.TimeStretch('SampleRate',fs,'StretchFactor',stretchFactor);
    stretchedData = stretcher(data);
end