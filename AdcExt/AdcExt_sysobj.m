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

classdef AdcExt_sysobj < matlab.System & ...
                         matlab.system.mixin.Propagates & ...
                         matlab.system.mixin.CustomIcon
    % System Object behavioral model for Analog Devices' High-Speed ADCs
    % Notes:
    %   - The Resolution dropdown filters the ADC options
    %   - In the name of the ADC is the maximum sampling clock, be sure
    %     to adjust your sampling clock accordingly.
   
    properties
        % Model Resolution
        Resolution = '16-Bits';
        
        % 16-Bit ADCs
        ADCs16Bit = 'AD9656_125_2p8V';
        % 14-Bit ADCs
        ADCs14Bit = 'AD9643_250';
        % 12-Bit ADCs
        ADCs12Bit = 'AD9635_125';
        % 11-Bit ADCs
        ADCs11Bit = 'AD9627-11-150';
        % 10-Bit ADCs
        ADCs10Bit = 'AD9608_125';
        % 8-Bit ADCs
        ADCs8Bit = 'AD9484_500';
       
        % Sampling Clock Frequency
        Fclk = 250e6;
        % Mean Frequency
        Tessitura = 2.3e6;
        % RMS Clock Jitter
        ExtJitter = 60e-15;
        % Input Configuration
        InputConfig = 'Normalized';
    end
       
    properties (Access = private)
        pm;         % MOTIF Object
        poffset;    % ADC Offset
        prange;     % ADC Range
    end
    
    properties(Constant, Hidden)
        ResolutionSet = matlab.system.StringSet({'16-Bits', '14-Bits', '12-Bits', '11-Bits', '10-Bits', '8-Bits'});

        ADCs16BitSet = matlab.system.StringSet({'AD9656_125_2p8V', 'AD9656_125_2V', 'AD9652_310_2p5V', 'AD9652_310_2V', 'AD9653_125_2p6V', 'AD9653_125_2V', 'AD9650_105', 'AD9650_80', 'AD9650_65', 'AD9650_25', 'AD9467_250_2p5V', 'AD9467_250_2V', 'AD9467_200_2p5V', 'AD9467_200_2V', 'AD9269_80', 'AD9269_65', 'AD9269_40', 'AD9269_20', 'AD9266_80', 'AD9266_65', 'AD9266_40', 'AD9266_20', 'AD9265_125', 'AD9268_125', 'AD9268_105', 'AD9268_80', 'AD9265_105', 'AD9265_80', 'AD9461_130_3p4V', 'AD9461_125_3p4V', 'AD9460_105_3p4V', 'AD9460_80_3p4V', 'AD9446_100_3p2V', 'AD9446_100_2V', 'AD9446_80_3p2V', 'AD9446_80_2V'});
        ADCs14BitSet = matlab.system.StringSet({'AD9643_250', 'AD9643_210', 'AD9643_170', 'AD9250_250', 'AD9250_170', 'AD9249_65', 'AD9681_125', 'AD9683_250', 'AD9683_170', 'AD9645_125', 'AD9645_80', 'AD9257_65', 'AD9257_40', 'AD9253_125', 'AD9253_105', 'AD9253_80', 'AD9648_125', 'AD9648_105', 'AD9642_250', 'AD9642_210', 'AD9642_170', 'AD9641_80', 'AD9644_80', 'AD9649_80', 'AD9649_65', 'AD9649_40', 'AD9649_20', 'AD9251_80', 'AD9251_65', 'AD9251_40', 'AD9251_20', 'AD9258_125', 'AD9258_105', 'AD9258_80', 'AD9255_125', 'AD9255_105', 'AD9255_80', 'AD9254-150', 'AD9640-150', 'AD9252-50', 'AD9259-50', 'AD9246_125', 'AD9246_105', 'AD9246_80', 'AD9445_125_3p2V', 'AD9445_125_2V', 'AD9445_105_3p2V', 'AD9445_105_2V', 'AD9444-80', 'AD9248_65', 'AD9248_40', 'AD9248_20', 'AD9245_80', 'AD9245_65', 'AD9245_40', 'AD9245_20', 'AD9244_65', 'AD9244_40', 'AD6645_105', 'AD6645_80'});
        ADCs12BitSet = matlab.system.StringSet({'AD9635_125', 'AD9635_80', 'AD9637_80', 'AD9637_40', 'AD9633_125', 'AD9633_105', 'AD9633_80', 'AD9628_125', 'AD9628_105', 'AD9634_250', 'AD9634_210', 'AD9634_170', 'AD9613_250', 'AD9613_210', 'AD9613_170', 'AD9434_500', 'AD9434_370', 'AD9629_80', 'AD9629_65', 'AD9629_40', 'AD9629_20', 'AD9231_80', 'AD9231_65', 'AD9231_40', 'AD9231_20', 'AD9222_65', 'AD9239_250', 'AD9239_210', 'AD9239_170', 'AD9639_210', 'AD9639_170', 'AD9626_250', 'AD9626_210', 'AD9626_170', 'AD9627-150', 'AD9230_250', 'AD9230_210', 'AD9230_170', 'AD9222_50', 'AD9222_40', 'AD9228_65', 'AD9228_40', 'AD9233_125', 'AD9233_105', 'AD9433_125', 'AD9433_105', 'AD9430_210_LVDS', 'AD9430_170_LVDS', 'AD9238_65', 'AD9238_40', 'AD9238_20', 'AD9237_65', 'AD9237_40', 'AD9237_20', 'AD9236-80', 'AD9229_65', 'AD9229_50', 'AD9226_65_2V'});
        ADCs11BitSet = matlab.system.StringSet({'AD9627-11-150', 'AD80141-140'});
        ADCs10BitSet = matlab.system.StringSet({'AD9608_125', 'AD9608_105', 'AD9600_150', 'AD9600_125', 'AD9600_105', 'AD9609_80', 'AD9609_65', 'AD9609_40', 'AD9609_20', 'AD9204_80', 'AD9204_65', 'AD9204_40', 'AD9204_20', 'AD9211_300', 'AD9211_250', 'AD9211_200', 'AD9601-250', 'AD9219_65', 'AD9219_40', 'AD9215_105', 'AD9216_80', 'AD9216_65', 'AD9214_105_1V', 'AD9214_80_1V', 'AD9214_65_2V', 'AD9218_105_1V', 'AD9218_80_1V', 'AD9218_65_2V', 'AD9218_40_1V', 'AD9215_80', 'AD9215_65', 'AD9216_105'});
        ADCs8BitSet = matlab.system.StringSet({'AD9484_500', 'AD9284_250', 'AD9287-100', 'AD9480-250', 'AD9289-65'});

        InputConfigSet = matlab.system.StringSet({'Normalized', 'Absolute'});
    end
    
    properties (DiscreteState)
    end
    
    methods
        % Constructor
        function obj = AdcExt_sysobj(varargin)
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
                'Title','System Object for an ADC',...
                'Text','This is a behavioral model of an ADC.',...
                'ShowSourceLink',false);
        end     
    end
    
    methods (Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
            modelPath = obj.determineModelName();
            
            obj.pm = MOTIF_if(['ADCs/' modelPath '.adc']);
            
            if (~obj.pm.isLoaded())
                disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
                return
            end
            
            % Get maximum sampling rate, and coerce if necessary
            clkmax = str2double(obj.pm.getProp('settings', 'clkmax'));
            if obj.Fclk > clkmax
                fclk = clkmax;
                warning('Sampling Rate was too high, coerced to maximum for this device');
            else
                fclk = obj.Fclk;
            end
            
            % Push simulation properties to MOTIF
            obj.pm.setProp('GLOBAL', 'fclk', num2str(fclk));
            obj.pm.setProp('GLOBAL', 'tessitura', num2str(obj.Tessitura));
            obj.pm.setProp('settings', 'extjitter', num2str(obj.ExtJitter));
            
            if strcmp(obj.InputConfig, 'Normalized')
               obj.poffset = str2double(obj.pm.getProp('settings', 'offset'));
               obj.prange = str2double(obj.pm.getProp('settings', 'range'));
            else
                obj.poffset = 0;
                obj.prange = 2;
            end
        end
        
        function modelPath = determineModelName(obj)
            % Determines the currently selected model name and saves to
            % pmodelPath
            if strcmp(obj.Resolution, '16-Bits')
                modelPath = obj.ADCs16Bit;
            else if strcmp(obj.Resolution, '14-Bits')
                modelPath = obj.ADCs14Bit;
                else if strcmp(obj.Resolution, '12-Bits')
                    modelPath = obj.ADCs12Bit;
                    else if strcmp(obj.Resolution, '11-Bits')
                        modelPath = obj.ADCs11Bit;
                        else if strcmp(obj.Resolution, '10-Bits')
                                modelPath = obj.ADCs10Bit;
                            else
                                modelPath = obj.ADCs8Bit;
                            end
                        end
                    end
                end
            end
            hyphenIdxs = strfind(modelPath, '-');
            if ~isempty(hyphenIdxs)
                modelPath = modelPath(1:hyphenIdxs(end)-1);
            end
        end
        
        function y = stepImpl(obj, u)
            % Implement algorithm. Calculate y as a function of
            % input u and discrete states.
            y = obj.pm.runSamples(u * obj.prange / 2 + obj.poffset);
        end
        
        function releaseImpl(obj)
            % Initialize discrete-state properties.
            obj.pm.destroy();
        end
        
        % This method controls visibility of the object's properties
        function flag = isInactivePropertyImpl(obj, propertyName)
            if strcmp(propertyName, 'ADCs16Bit')
                flag = ~strcmp(obj.Resolution, '16-Bits');
            else if strcmp(propertyName, 'ADCs14Bit')
                flag = ~strcmp(obj.Resolution, '14-Bits');
                else if strcmp(propertyName, 'ADCs12Bit')
                    flag = ~strcmp(obj.Resolution, '12-Bits');
                    else if strcmp(propertyName, 'ADCs11Bit')
                        flag = ~strcmp(obj.Resolution, '11-Bits');
                        else if strcmp(propertyName, 'ADCs10Bit')
                            flag = ~strcmp(obj.Resolution, '10-Bits');
                            else if strcmp(propertyName, 'ADCs8Bit')
                                flag = ~strcmp(obj.Resolution, '8-Bits');
                                else
                                    flag = false;
                                end
                            end
                        end
                    end
                end
            end
        end        
        
        function icon = getIconImpl(obj)
            % Extract generic name from file name
            modelPath = obj.determineModelName();
            
            idx = strfind(modelPath, '_');
            
            if ~isempty(idx)
                generic = modelPath(1:idx(1)-1);
            else
                generic = modelPath;
            end

            icon = sprintf(generic);
        end     
             
        function dataout = getOutputDataTypeImpl(~)
            dataout = 'double';
        end

        function sizeout = getOutputSizeImpl(~)
            sizeout = [1 1];
        end

        function cplxout = isOutputComplexImpl(~)
            cplxout = false;
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
            varargout{1} = 'in (V)';
        end        
        
        function varargout = getOutputNamesImpl(~)
            varargout = cell(1,1);
            varargout{1} = 'out (Code)';
        end    
    end
end
