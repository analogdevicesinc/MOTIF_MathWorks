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

Description:
  Models  AD7403.pmf and SINC.pmf
  DLL     MOTIF.dll or libMOTIF.so
  Arch    64-bit
  Version 1.0.0.6

  This code simulates operation of the AD7403 followed by a configurable SINC filter.
  The simulation generates a tone, passes it through a model of the device, then through a
  model of the SINC filter, and takes an FFT of the results.  It also allows the user
  to configure some digital specifications of the filter.  Feel free to modify the code to
  suit your application.

Install:
  Unzip the contents into some working folder.
  
Usage:
  From Simulink, open AD7403.slx and run.

  From the MATLAB shell under the MOTIF directory, run Main.m by typing "Main" (it may prompt you to change directories)
  To change the behavior of the filter modify SINC_Configure.m, save, and rerun Main.

Troubleshoot:
  If MATLAB complains that a compiler has not been selected, type "mex -setup" and follow the instrustions.
  Rerun Main.m
  
  For support or questions, please use EngineerZone (ez.analog.com)
 
  
  