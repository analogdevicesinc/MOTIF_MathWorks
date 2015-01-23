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

function AD9680_Configure(m, fclk, spectrumCenter, extJitter)

% Modes of Operation
mode = 'mode1';    % ADC Only
%mode = 'mode2';    % Real ADC + DDC
%mode = 'mode3';    % Complex ADC + DDC
%mode = 'mode4';    % Real ADC + DDC + Complex-to-Real
%mode = 'mode5';    % Complex ADC + DDC + Complex-to-Real

% Set mode specific properties
if (strcmp(mode, 'mode1'))
    % No properties to set
elseif (strcmp(mode, 'mode2') || strcmp(mode, 'mode3'))
    ddc_m = 2;          % DDC Decimation {2,4,8,16}
    ddc_gain = 0;       % DDC Gain {0,6} (in dB)
    nco_freq = 2.5e8;   % NCO Frequency [0,fclk] (in Hz)
    nco_phase = 0;      % NCO Phase [0,360] (in deg)
else % (strcmp(cfg.mode, 'mode4') || strcmp(cfg.mode, 'mode5'))
    ddc_m = 1;          % DDC Decimation {1,2,4,8}
    ddc_gain = 0;       % DDC Gain {0,6} (in dB)
    nco_freq = 2.5e8;   % NCO Frequency [0,fclk] (in Hz)
    nco_phase = 0;      % NCO Phase [0,360] (in deg)
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Push settings to model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the current mode for the device
m.setMode(mode);

% Set the GLOBAL sampling rate and input frequency
m.setProp('GLOBAL', 'fclk', num2str(fclk));
m.setProp('GLOBAL', 'tessitura', num2str(spectrumCenter));

% Set the RMS external jitter
m.setProp('settings', 'extjitter', num2str(extJitter));

% Setup the DDC and NCO if enabled
if (~strcmp(mode,'mode1'))
    m.setProp('ddc', 'm', num2str(ddc_m));
    m.setProp('ddc', 'gain', num2str(ddc_gain));
    m.setProp('nco', 'freq', num2str(nco_freq));
    m.setProp('nco', 'phaseoff', num2str(nco_phase));
end








