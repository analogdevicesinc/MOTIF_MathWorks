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

function AD9136_Configure(m, fclk, OSR)

% Modes of Operation
mode = 'mode1';    % Nominal

% Set mode specific properties
pnmask = '1E0,-70,1E1,-96,1E2,-115,1E3,-135,1E4,-140,5E4,-140,2E5,-165,1E9,-165';
    % This is the approximate phase noise mask for an Rohde & Schwarz
    % SMA-100A generator, which the AD9136 was characterized with.
    % The list is comma separated frequency (Hz), amplitude (dB) pairs.
    
l = 2;                      % Interpolation {1,2,4,8}
invsinc_enabled = false;    % Enable for inverse sinc.
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Push settings to model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the current mode for the device
m.setMode(mode);

% Set the GLOBAL sampling rate and input frequency
m.setProp('GLOBAL', 'fclk', num2str(fclk));
m.setProp('GLOBAL', 'OSR', num2str(OSR));

% Setup the DDC and NCO if enabled
m.setProp('settings', 'pnmask', pnmask);
m.setProp('settings', 'l', num2str(l));
m.setProp('invsinc', 'enabled', num2str(invsinc_enabled));

