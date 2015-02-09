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

classdef AD9136_sysobj < matlab.System & ...
                         matlab.system.mixin.Propagates & ...
                         matlab.system.mixin.CustomIcon
    % System Object behavioral model for Analog Devices' High-Speed ADCs
    % Notes:
    %   - The Resolution dropdown filters the ADC options
    %   - In the name of the ADC is the maximum sampling clock, be sure
    %     to adjust your sampling clock accordingly.
   
    properties
        % Operating Mode
        Mode = 'Nominal';
        
        % Interpolation
        Interpolation = 1;
        
        % Data Frequency
        Fdata = 2120e6;
                        
        % Inverse SINC
        InvSinc = 'Disabled';
    end

    properties
        % Output Configuration
        OutputConfig = 'Normalized'; 
    end
    
    properties (Access = private)
        pm;         % MOTIF Object
        poffset;    % ADC Offset
        prange;     % ADC Range
        pmodelName = 'AD9136';
    end
    
    properties(Constant, Hidden)
        ModeSet = matlab.system.StringSet({'Nominal'});
        
        InvSincSet = matlab.system.StringSet({'Disabled', 'Enabled'});

        OutputConfigSet = matlab.system.StringSet({'Normalized', 'Absolute'});
    end
    
    methods
        % Constructor
        function obj = AD9136_sysobj(varargin)
            % Support name-value pair arguments when constructing the
            % object.
            
            % Add MOTIF path
            modelPath = get_param(gcs,'FileName');
            modelFolder = fileparts(modelPath);
            resourcesFolder = fullfile(modelFolder, 'MOTIF');
            addpath(resourcesFolder);
            
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods (Static, Access = protected)
        function header = getHeaderImpl
            header = matlab.system.display.Header(mfilename('class'),...                
                'Title','System Object for a DAC',...
                'Text','This is a behavioral model of an DAC.',...
                'ShowSourceLink',false);
        end     
    end
    
    methods (Access = protected)
        %% Common functions
        function validatePropertiesImpl(obj)
            if obj.Interpolation ~= 1 && obj.Interpolation ~= 2 ...
                && obj.Interpolation ~= 4 && obj.Interplation ~= 8
                error('Interpolation must be one of: {1,2,4,8}');
            end
        end
        
        function setupImpl(obj)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
            obj.pm = MOTIF_if(['MOTIF/' obj.pmodelName '.pmf']);
            
            if (~obj.pm.isLoaded())
                disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
                return
            end
            
            % Set the interpolation property
            obj.pm.setProp('settings', 'l', num2str(obj.Interpolation));
            
            % Get maximum sampling rate, and coerce if necessary
            clkmax = str2double(obj.pm.getProp('settings', 'clkmax'));
            if obj.Fdata > clkmax
                Fclk = clkmax;
                warning('Sampling Rate was too high, coerced to maximum for this device');
            else
                Fclk = obj.Fdata;
            end
            
            % Push simulation properties to MOTIF
            obj.pm.setProp('GLOBAL', 'fclk', num2str(Fclk));
            
            if strcmp(obj.OutputConfig, 'Normalized')
               obj.poffset = str2double(obj.pm.getProp('settings', 'offset'));
               obj.prange = str2double(obj.pm.getProp('settings', 'range'));
            else
                obj.poffset = 0;
                obj.prange = 2;
            end
            
            interface = obj.pm.queryInterface();
            if interface.in.is_complex
               obj.poffset = obj.poffset + 1j * obj.poffset;
            end
            
            % Set other properties
            if strcmp(obj.InvSinc, 'Enabled')
                obj.pm.setProp('invsinc', 'enabled', 'true');
            else
                obj.pm.setProp('invsinc', 'enabled', 'false');
            end
        end
             
        function y = stepImpl(obj, u)
            % Implement algorithm. Calculate y as a function of
            % input u and discrete states.            
            y = obj.pm.runSamples(u);
            y = (y - obj.poffset) / obj.prange * 2;
            y = y';
        end
        
        function releaseImpl(obj)
            % Initialize discrete-state properties.
            obj.pm.destroy();
        end
        
        % This method controls visibility of the object's properties
        function flag = isInactivePropertyImpl(obj, propertyName)
            flag = 0;
        end        
        
        function icon = getIconImpl(obj)
            % Extract generic name from file name
            idx = strfind(obj.pmodelName, '_');
            
            if ~isempty(idx)
                generic = obj.pmodelName(1:idx(1)-1);
            else
                generic = obj.pmodelName;
            end

            icon = sprintf(generic);
        end     
             
        function dataout = getOutputDataTypeImpl(~)
            dataout = 'double';
        end

        function sizeout = getOutputSizeImpl(obj)
            sizeout = obj.Interpolation;
        end

        function cplxout = isOutputComplexImpl(obj)
            % This should solicit the complexity from the model,
            %  but the model hasn't been loaded yet.
            if strcmp(obj.Mode, 'Nominal')
                cplxout = true; 
            else
                cplxout = false;
            end
        end

        function fixedout = isOutputFixedSizeImpl(~)
            fixedout = true;
        end
        
        function num = getNumInputsImpl(~)
           num = 1; 
        end
        
        function varargout = getInputNamesImpl(obj)
            numInputs = getNumInputs(obj);
            varargout = cell(1,numInputs);
            varargout{1} = 'in (Code)';
        end        
        
        function varargout = getOutputNamesImpl(~)
            varargout = cell(1,1);
            varargout{1} = 'out (A)';
        end    
    end
end
