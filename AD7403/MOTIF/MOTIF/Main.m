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
% NOTE: Product configuration is found in AD7403_Configuration.m
% NOTE: SINC filter configuration is found in SINC_Configuration.m
amplitude = 0.25;
fclk = 20e6;
numOfSamples = 2^19;
latency = 256;
nBits = 16;	% output resolution of the SINC

% Set the input tone frequency
infreq = 2007;

% Calculate coherent frequency (assumes numOfSamples is a power of 2)
nCycles = floor(infreq * numOfSamples / fclk / 2) * 2 + 1;
spectrumCenter = nCycles / numOfSamples * fclk;

% Load the specified model into memory and returns a "key" to that file.
m_adc = MOTIF_if('AD7403.pmf');

if (~m_adc.isLoaded())
    disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
    return
end

m_sinc = MOTIF_if('SINC.pmf');

if (~m_sinc.isLoaded())
    disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
    return
end

% Configure the simulation.
AD7403_Configure(m_adc, fclk);
interface_adc = m_adc.queryInterface();

SINC_Configure(m_sinc, fclk);
interface_sinc = m_sinc.queryInterface();

r = interface_adc.r * interface_sinc.r;

% Create a normalized frequency to generate the sinewave.
frequency = spectrumCenter / fclk * numOfSamples;

% Generate a sinewave voltage input to the model.
n = 0:(numOfSamples+latency/r-1);
sinewave = amplitude * exp(1i * 2 * pi * frequency * n / numOfSamples);

% Run the models
[codes] = m_adc.runSamples(sinewave);
[codes] = m_sinc.runSamples(2*codes-1);

% Trim the output data to ignore startup transients
codes = codes(latency+1:numOfSamples*r+latency);

%Take the FFT
nHarmonics = 2;
useHann = true;
harms = PlotFFT(codes, nHarmonics, nBits, useHann);

% Display DC, fundamental, and harmonic information (only accurate when
%   useHann is false)
%harms
