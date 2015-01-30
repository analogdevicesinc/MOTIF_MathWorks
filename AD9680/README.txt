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
  Model   AD9680_1000.pmf
  DLL     MOTIF.dll or libMOTIF.so
  Arch    64-bit
  Version 1.0.0.6
  
  This code simulates operation of the AD9680.  The simulation generates a tone, passes it 
  through a model of the device, and takes an FFT of the results.  It also allows the user
  to configure some digital features of the device.  Feel free to modify the code to suit
  your application.

Install:
  Unzip the contents into some working folder.
  
Usage:
  From the MATLAB shell, run Main.m by typing "Main" (it may prompt you to change directories)
  To change the behavior of the model modify AD9680_Configuration.m, save, and rerun Main.

Troubleshoot:
  If MATLAB complains that a compiler has not been selected, type "mex -setup" and follow the instrustions.
  Rerun Main.m
  
  If MATLAB complains that there is a problem with loadlibrary, it might be an issue with having
  a valid supported C compiler.  In Windows, MATLAB doesn't work with Microsoft Visual Studio 2010
  Redistributables.  You will need to uninstall any references to VS 2010 Redistributable and 
  install the Windows SDK 7.1.

  For support or questions, please use EngineerZone (ez.analog.com)
 
  
  
