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
  Model   <any model>.adc
  DLL     MOTIF.dll or libMOTIF.so
  Arch    64-bit
  Version 1.0.0.15

  This code simulates operation of any model ending with the extension ADC.  The simulation
  generates a tone, passes it through a model of the device, and takes an FFT of the results.
  Feel free to modify the code to suit your application.

Install:
  Unzip the contents into some working folder.
  
Usage:
  From Simulink, open AdcExt.slx and run.  Edit the mask to change the device under simulation. 
  The Input Configuration combo box determes whether the input is:
    Normalized, where Amplitude = 1 and Bias = 0 or
    Absolute, where Amplitude = ADC.Range / 2 and Bias = ADC.Offset
  
  From the MATLAB shell, run Main.m by typing "Main" (it may prompt you to change directories)
  The default ADC selected is the AD9467_250_2p5V.  You are free to use any model with an ADC 
  extention for your simulation.
  
Troubleshoot:
  If MATLAB complains that a compiler has not been selected, type "mex -setup" and follow the instrustions.
  Rerun Main.m
  
  If MATLAB complains that there is a problem with loadlibrary, it might be an issue with having
  a valid supported C compiler.  In Windows, MATLAB doesn't work with Microsoft Visual Studio 2010
  Redistributables.  You will need to uninstall any references to VS 2010 Redistributable and 
  install the Windows SDK 7.1.

  For support or questions, please use EngineerZone (ez.analog.com)
 
  
  
