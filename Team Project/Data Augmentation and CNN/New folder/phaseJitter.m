%Phase Jittering
function phaseJitteredData = phaseJitter(data)
    dataFFT = fft(data);
    phaseJitter = 2*pi*rand(size(dataFFT));
    jitteredFFT = abs(dataFFT) .* exp(1i*(angle(dataFFT) + phaseJitter));
    phaseJitteredData = real(ifft(jitteredFFT));
end