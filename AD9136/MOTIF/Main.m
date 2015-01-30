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

% This file is organized as such:
%   1) Tone generation
%   2) Product configuration
%   3) Simulation
%   4) FFT
%
% The following code is a template which you may use in your own
% work flow.  Feel free to modify this file to change operating
% conditions, or to simulate this model within a larger design.

% Simulation parameters
% NOTE: Product configuration is found in AD9680_Configuration.m
spectrumLevel_dB = -0.1;
fdata = 1.06e9;  % Data rate (in Hz)
                 % Constraints (adjust l in AD9136_Config.m):
                 %   l = 1, max fclk = 2.12e9
                 %   l = 2, max fclk = 1.06e9
                 %   l = 4, max fclk = 0.70e9
                 %   l = 8, max fclk = 0.35e9

OSR = 1;         % Over Sampling Ratio of analog output (e.g. 1, 2, 4, 8...)
numOfSamples = 2^12;
latency = 256;    % Extra data appended to numOfSamples
    
% Set the input tone frequency
infreq = 163.1e6;

% Calculate coherent frequency (assumes numOfSamples is a power of 2)
nCycles = floor(infreq * numOfSamples / fdata / 2) * 2 + 1;
spectrumCenter = nCycles / numOfSamples * fdata;

% Load the specified model into memory and returns a "key" to that file.
m = MOTIF_if('AD9136.pmf');

if (~m.isLoaded())
    disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
    return
end

% Configure the simulation.
AD9136_Configure(m, fdata, OSR);

% Return the relevant properties of the current ADC
props = m.queryPropValues();

% Make sure the clock frequency doesn't exceed maximum allowable value
max_fdata = str2double(props('settings.clkmax'));
if (fdata > max_fdata)
   fdata = max_fdata;
   disp('Warning: fclk (input data rate) too fast.  It will be coerced to maximum sample rate of converter');
   m.setProp('GLOBAL', 'fclk', num2str(fdata));
end

nBits = str2double(props('settings.nbits'));
commonMode = str2double(props('settings.offset'));
inputSpan = str2double(props('settings.range'));

inputMode = props('settings.inputmode');
if strcmp(inputMode, 'Offset Binary')
    bias = 2 ^ nBits / 2;
else
    bias = 0;
end

% Create a normalized frequency to generate the sinewave.
frequency = spectrumCenter / fdata * numOfSamples;

% Convert spectrumLevel_dB into a peak amplitude voltage.
amplitude = (2 ^ nBits / 2) * 10 ^ (spectrumLevel_dB / 20);

% Generate a sinewave voltage input to the model.
n = 0:(numOfSamples+latency-1);
codes = round(amplitude * exp(1i * 2 * pi * frequency * n / numOfSamples) + bias * (1 + 1i));

% Run the model
[sinewave, interface] = m.runSamples(codes);
interface.out.f
% Trim the output data to ignore startup transients
sinewave = sinewave(latency*interface.r+1:numOfSamples*interface.r+latency*interface.r);

% Normalize sinewave to full-scale
if interface.out.is_complex
    bias = commonMode * (1 + 1i);
else
    bias = commonMode;
end
sinewave = (sinewave - bias) / (inputSpan / 2);

% Take the FFT
nHarmonics = 2;
useHann = true;
complexOut = false;
sinewave = real(sinewave) + 1j * imag(sinewave) * complexOut;
harms = PlotFFT(sinewave, nHarmonics, 1, useHann, interface.out.f);

% Display DC, fundamental, and harmonic information (only accurate when
%   useHann is false)
%harms
