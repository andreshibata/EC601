%Filtering
function filteredData = lowPassFilter(data, fs, passbandFrequency)
    lowPass = dsp.LowpassFilter('SampleRate', fs, 'PassbandFrequency', passbandFrequency);
    filteredData = lowPass(data);
end