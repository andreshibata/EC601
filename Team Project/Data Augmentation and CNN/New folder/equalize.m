%Equalization
function eqData = equalize(data, fs)
    geq = graphicEQ('SampleRate', fs);
    eqData = geq(data);
end