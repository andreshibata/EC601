%Dynamic Range Compression
function compressedData = dynamicRangeCompression(data, fs)
    dynRangeCompressor = compressor('SampleRate',fs);
    compressedData = dynRangeCompressor(data);
end