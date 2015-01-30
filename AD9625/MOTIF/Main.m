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

% Simulation parameters
% NOTE: Product configuration is found in AD9625_Configuration.m
spectrumLevel_dB = -1;
fclk = 2.5e9;
numOfSamples = 2^16;
latency = 1024;
    
% Set the input tone frequency
infreq = 523.1e6;

% Calculate coherent frequency (assumes numOfSamples is a power of 2)
nCycles = floor(infreq * numOfSamples / fclk / 2) * 2 + 1;
spectrumCenter = nCycles / numOfSamples * fclk;

% Load the specified model into memory and returns a "key" to that file.
m = MOTIF_if('AD9625_2500.pmf');

if (~m.isLoaded())
    disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
    return
end

% Return the relevant properties of the current ADC
props = m.queryPropValues();

% Make sure the clock frequency doesn't exceed maximum allowable value
max_fclk = str2double(props('settings.clkmax'));
if (fclk > max_fclk)
   fclk = max_fclk;
   disp('Warning: fclk too fast.  It will be coerced to maximum sample rate of converter');
end

nBits = str2double(props('settings.nbits'));
commonMode = str2double(props('settings.offset'));
inputSpan = str2double(props('settings.range'));
extJitter = str2double(props('settings.extjitter'));
outputMode = props('settings.outputmode');

% Create a normalized frequency to generate the sinewave.
frequency = spectrumCenter / fclk * numOfSamples;

% Convert spectrumLevel_dB into a peak amplitude voltage.
amplitude = (inputSpan / 2) * 10 ^ (spectrumLevel_dB / 20);

% Generate a sinewave voltage input to the model.
n = 0:(numOfSamples+latency-1);
sinewave = amplitude * exp(1i * 2 * pi * frequency * n / numOfSamples) + commonMode * (1 + 1i);

% Configure the simulation.
AD9625_Configure(m, fclk, spectrumCenter, extJitter);

% Run the model
[codes, interface] = m.runSamples(sinewave);

% Trim the output data to ignore startup transients
codes = codes(latency*interface.r+1:numOfSamples*interface.r+latency*interface.r);

% Take the FFT
nHarmonics = 2;
useHann = true;
harms = PlotFFT(codes, nHarmonics, nBits, useHann, interface.out.f);

% Display DC, fundamental, and harmonic information (only accurate when
%   useHann is false)
%harms
