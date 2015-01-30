% Copyright (c) 2014, Analog Devices Inc. 
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
%
% 2.Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function retval = PlotFFT(h, numOfHarms, res, use_window, fs)

len = length(h);

if (use_window)
    w = hann(len);
    s_w = (w / sum(w)) * len;
    h = h .* s_w';
end

ufft = abs(fft(h));
fftdata = 4 * ufft / len / (2 ^ res);

for i = 1:len
    if (fftdata(i) < 1e-15)
        fftdata(i) = 1e-15;
    end
end

if (isreal(h))
    len = len/2;
    fftdata = 20 * log10(fftdata(1:len));
    xmin = 1;
    xmax = len;
else
    fftdata = 20 * log10(fftdata/2);
    fftdata = [fftdata(len/2+1:len) fftdata(1:len/2)];
    xmin = -len/2;
    xmax = len/2-1;
end
sf = fs / len / 2;

p = 1;
max = fftdata(1);
for i=2:len
    if fftdata(i) > max
        max = fftdata(i);
        p = i;
    end
end

harms = [fftdata(1)];
for i=1:numOfHarms+1
    index = p*i-i+1;
    
    %freq wrap
    index = mod(index, len*2);
    if (index > len)
        index = len*2-index+2;
    end
    %end freq wrap
      
    harms = [harms fftdata(index)];
end

%report harmonics
retval = harms;

%figure;
plot((xmin:xmax)*sf, fftdata);
axis([xmin*sf xmax*sf -130 6]);
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');

