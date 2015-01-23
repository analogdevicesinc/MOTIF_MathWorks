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

classdef AD7403_sysobj < matlab.System & ...
                         matlab.system.mixin.Propagates & ...
                         matlab.system.mixin.CustomIcon
    % System Object behavioral model for AD7403
          
    properties (Nontunable,Constant)
        % Model Path
        ModelPath = 'MOTIF/AD7403.pmf';
    end
    
    properties (Nontunable)
        % Mode
        Mode = 'Modulator';
        % Sampling Clock Frequency
        Fclk = 20e6;
    end
    
    properties(Constant, Hidden)
        ModeSet = matlab.system.StringSet({'Modulator', 'Average'});
    end
    
    properties (Access = private)
        pm;         % MOTIF Object
    end
    
    properties (DiscreteState)
    end
    
    methods
        % Constructor
        function obj = AD7403_sysobj(varargin)
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
                'Title','System Object for AD7403',...
                'Text','This is a behavioral model of the AD7403 modulator.  The output is a single bit stream.',...
                'ShowSourceLink',false);
        end
        
%         function groups = getPropertyGroupsImpl
%             valueGroup = matlab.system.display.Section(...
%             thresholdGroup = matlab.system.display.Section(...
%             mainGroup = matlab.system.display.SectionGroup(...
%             initGroup = matlab.system.display.SectionGroup(...
%             groups = [mainGroup,initGroup];
%         end       
    end
    
    methods (Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Implement tasks that need to be performed only once,
            % such as pre-computed constants.
            obj.pm = MOTIF_if(obj.ModelPath);
            
            if (~obj.pm.isLoaded())
                disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
                return
            end
            
            % Fetch parameters from parent block mask
            if strcmp(obj.Mode, 'Modulator')
                modeID = 'mode1';
            else
                modeID = 'mode2';
            end
            obj.pm.setMode(modeID);
            
            obj.pm.setProp('GLOBAL', 'fclk', num2str(obj.Fclk));
        end
        
        function y = stepImpl(obj,u,clk)
            % Implement algorithm. Calculate y as a function of
            % input u and discrete states.
            y = obj.pm.runSamples(u);
        end
               
        function releaseImpl(obj)
            % Initialize discrete-state properties.
            obj.pm.destroy();
        end
        
        function icon = getIconImpl(~)
            icon = sprintf('AD7403');
        end
        
        function processTunedPropertiesImpl(obj)
            % Generate a lookup table of note frequencies
            %SetProperty('GLOBAL','fclk',obj.Fclk,obj.pKey);
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
        
        function num = getNumInputsImpl(obj)
           num = 2; 
        end
        
        function varargout = getInputNamesImpl(obj)
            numInputs = getNumInputs(obj);
            varargout = cell(1,numInputs);
            varargout{1} = 'in (V)';
            if numInputs > 1
                varargout{2} = 'MCLKIN';
            end
            %varargout = cell(1,1);
            %varargout{1} = 'in (V)';
            %varargout{2} = 'MCLKIN';
        end        
        
        function varargout = getOutputNamesImpl(~)
            varargout = cell(1,1);
            varargout{1} = 'out (Bit)';
        end    
    end
end
