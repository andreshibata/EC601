audiofile = 'E_major_piano.mp3';
[y,Fs] = audioread(audiofile);
% if stereo audio, take just one channel:
y = y(:,1);

N = 4096;

info = audioinfo(audiofile);

L = N/2;
%raised cosine window
h = hann(L,'periodic');
%zero pad
h = [h; zeros(N-L,1)];


numFrames = 0;
lastFreq = 0;

freqs = [];
frames = [];

%make note change threshold half of the resolution of TET:
threshold = 13;


M = floor(info.TotalSamples/(L/2));
%zero pad last block
paddingSize = M*L/2 + N - info.TotalSamples;
y = [y; zeros(paddingSize,1)];

for j=0:M
    n = L/2*j+1:L/2*j+N;
    block = y(n);
    
    Y = abs(fft(block.*h)/N);
    f = Fs/N*(1:N);
    
    %k = floor(12*log2(i/440)+49);
    %currFreq = 27.5*(2)^((1/12)*(k-1));
    %currFreq = i;

    R = ifft(fft(block.*h).*conj(fft(block.*h)));
    [p,i] = findpeaks(R(1:N/2),1:N/2,"NPeaks",1,"SortStr","descend");
    currFreq = 1/(1/Fs*i)*2;
    
 
    lastFreq = sum(freqs(end-numFrames+1:end))/numFrames;
    if currFreq>lastFreq+threshold || currFreq<lastFreq-threshold
        frames = [frames numFrames];
        numFrames = 1;
    else
        numFrames = numFrames + 1;
    end
    lastFreq = currFreq;

    freqs = [freqs currFreq];
end

figure
stem(1:length(freqs),freqs)
xlabel("Sample #")
ylabel("Frequency (Hz)")

noteLen = mode(frames);
noteTime = 1/Fs * L/2 * noteLen;
