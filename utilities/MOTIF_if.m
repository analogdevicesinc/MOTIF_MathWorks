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

classdef MOTIF_if < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    properties (Access = protected)
        key = 0;
    end
    
    methods 
        function obj = MOTIF_if(filename)
            % OS specific code
            if ispc()
                prefix = '';
                suffix = '.dll';
            else
                prefix = 'lib';
                suffix = '.so';
            end
            
            library_name = [prefix 'MOTIF' suffix];

            % Check to see if the library is loaded already
            if (~libisloaded('MOTIF'))
                loadlibrary(library_name, 'MOTIF.h', 'alias', 'MOTIF');
            end

            % Try and resolve absolute path
            if ~exist(filename, 'file')
               tf = ['MOTIF' filesep filename];
               if exist(tf, 'file')
                  filename = tf;
               else
                   error_msg = sprintf('Cannot find model: %s', filename);
                   error(error_msg);
               end
            end
            
            % Load the PMF into memory
            obj.key = calllib('MOTIF', 'ImportPMF', filename);
        end
        
        function key = getKey(obj)
           key = obj.key; 
        end
        
        function isLoaded = isLoaded(obj)
           isLoaded = ~(obj.key == 0);
        end
        
        function interface = queryInterface(obj)
            direction = 0;  % Input
            in_count = obj.getPortCount(direction);
            interface.in = obj.queryPort(direction, in_count - 1);

            direction = 1;  % Output
            out_count = obj.getPortCount(direction);
            interface.out = obj.queryPort(direction, out_count - 1);

            interface.r = interface.out.f / interface.in.f;
        end
        
        function [modeName, modeDisplayName] = getMode(obj)
            response = obj.processMessage('<getmode />'); 
            
            modeElements = MOTIF_if.getChildren(response);
            attributes = MOTIF_if.getAttributes(modeElements(1));
            
            modeName = attributes('mn');
            modeDisplayName = attributes('mdn');
        end
        
        function modes = queryModes(obj)
            % Returns a Maps that contain the mode display names
            
            response = obj.processMessage('<querymodes />');
            queryModesElements = MOTIF_if.getChildren(response);
            modeElements = MOTIF_if.getChildren(queryModesElements(1));
            
            modes = containers.Map;
            for i = 1:length(modeElements)
                attributes = MOTIF_if.getAttributes(modeElements(i));
                
                modes(attributes('mn')) = attributes('mdn');
            end            
        end
        
        function printModes(obj)
            modes = obj.queryModes();
            
            ks = keys(modes);
            for k_idx = 1:length(ks)
                k = ks(k_idx);
                mode = modes(k{1});
                disp([k{1} ' : ' mode]);
            end            
        end
        
        function setMode(obj, mode)
            msg = ['<setmode>' mode '</setmode>'];
            obj.processMessage(msg);            
        end
        
        function [value, displayName, permission, limits, type, unit, toolTip] = getProp(obj, blockName, propName)
            response = obj.processMessage(['<getprop bn="' blockName '" pn="' propName '"/>']);
            getPropElements = MOTIF_if.getChildren(response);
            value = MOTIF_if.getText(getPropElements(1));
            attributes = MOTIF_if.getAttributes(getPropElements(1));
            
            displayName = attributes('pdn');
            permission = attributes('p');
            limits = attributes('l');
            type = attributes('t');
            unit = attributes('u');
            toolTip = attributes('tt');
        end
        
        function props = queryProps(obj)
            % Returns a Map of Maps that contain the properties
            % Explanantion of keys -
            %   pn = property name
            %   pdn = property display name
            %   bn = block name
            %   bdn = block display name
            %   p = permissions
            %   l = limits
            %   t = type
            %   u = unit
            %   tt = tool tip
            
            response = obj.processMessage('<queryprops />');
            queryPropsElements = MOTIF_if.getChildren(response);
            propElements = MOTIF_if.getChildren(queryPropsElements{1});
            
            props = containers.Map;
            for i = 1:length(propElements)
                value = MOTIF_if.getText(propElements{i});
                attributes = MOTIF_if.getAttributes(propElements{i});
                attributes('value') = value;
                
                k = [attributes('bn') '.' attributes('pn')];
                props(k) = attributes;
            end            
        end
        
        function props = queryPropValues(obj)
            % Returns a Map that values
            
            response = obj.processMessage('<queryprops />');
            queryPropsElements = MOTIF_if.getChildren(response);
            propElements = MOTIF_if.getChildren(queryPropsElements{1});
            
            props = containers.Map;
            for i = 1:length(propElements)
                value = MOTIF_if.getText(propElements{i});
                attributes = MOTIF_if.getAttributes(propElements{i});
                
                k = [attributes('bn') '.' attributes('pn')];
                props(k) = value;
            end
        end
                
        function printProps(obj)
            props = obj.queryProps();
            
            k0s = keys(props);
            for k0_idx = 1:length(k0s)
                k0 = k0s(k0_idx);
                prop = props(k0{1});
                
                disp([k0{1} ' :']);
                
                k1s = keys(prop);
                for k1_idx = 1:length(k1s)
                    k1 = k1s(k1_idx);
                    attribute = prop(k1{1});
                    
                    disp(['  ' k1{1} ' : ' attribute]);
                end
            end
        end
                
        function setProp(obj, blockName, propName, value)
            msg = ['<setprop bn="' blockName '" pn="' propName '">' value '</setprop>'];
            obj.processMessage(msg);
        end
        
        function versionInfo = queryVersion(obj)
            % Returns a Map that contain the version information
            % Explanantion of keys -
            %   dllversion = version of MOTIF simulator
            %   pmfversion = version of Product Model File
            response = obj.processMessage('<queryversion />');
            queryVersionElements = MOTIF_if.getChildren(response);
            versionInfo = MOTIF_if.getAttributes(queryVersionElements(1));
        end
        
        function printVersion(obj)
            versionInfo = queryVersion(obj);
            disp(['Library Version: ', versionInfo('dllversion')]);
            disp(['PMF Version: ', versionInfo('pmfversion')]);
        end
                
        function [out, interface] = runSamples(obj, in)
            % Save input length
            len = length(in);

            interface = obj.queryInterface();
                        
            % Format input
            if (interface.in.is_complex)
                tin(1:2:len*2) = real(in);
                tin(2:2:len*2) = imag(in);
            else
                tin = real(in);
            end

            % Initialize the output code array
            if (interface.out.is_complex)
                out_len = ceil(len*2*interface.r);
            else
                out_len = ceil(len*interface.r);
            end
            out = zeros(1, out_len);

            [~, ~, out] = calllib('MOTIF', 'RunSamples', tin, out, len, obj.key);

            if (interface.out.is_complex)
                idx = 1:2:out_len;
                out = out(idx) + 1i*out(idx+1);
            end
        end
        
        function destroy(obj)
            calllib('MOTIF', 'Destroy', obj.key);
        end
    end
    
    methods (Access = protected)
        function count = getPortCount(obj, direction)
            count = 0;
            [~, count] = calllib('MOTIF', 'GetPortCount', count, direction, obj.key);
        end
        
        function port = queryPort(obj, direction, index)
            % init return variable
            if index ~= 0   % Only one port supported at this time
               port.f = 1;
               port.is_complex = 0;
               port.domain = '[unspecified]';
               port.unit = '[unspecified]';
               return;
            end

           if (obj.key == 0)
               return
           end
            
            f = 1;
            is_complex = 0;
            domain = 0;
            unitPtr = libpointer('voidPtrPtr');

            [~, f, is_complex, domain, unitPtr] = calllib('MOTIF', 'QueryPort', f, is_complex, domain, unitPtr, direction, index, obj.key);

            port.f = f;
            port.is_complex = is_complex;

            if domain == 1
                port.domain = 'analog';
            else
                if domain == 2
                    port.domain = 'digital';
                else
                    port.domain = '[unspecified]';
                end
            end

            unitPtr.setdatatype('voidPtr', 64);
            unit = libpointer('stringPtr', unitPtr);
            port.unit = unit.Value;
        end
        
        function response = processMessage(obj, msg)
            msg = ['<motif>' msg '</motif>'];

            responsePtr = libpointer('voidPtrPtr');

            [~, ~, responsePtr] = calllib('MOTIF', 'ProcessMessage', msg, responsePtr, obj.key);

            responsePtr.setdatatype('voidPtr', 64);
            response = libpointer('stringPtr', responsePtr);
            response = response.Value;            
        end
    end
    
    methods (Static, Access = public)
        function destroyAll()
           calllib('MOTIF', 'DestroyAll');
            if (libisloaded('MOTIF')) % which it should be
                unloadlibrary('MOTIF')
            end 
        end
        
        function str = bool2str(boolVal)
           if (boolVal)
                str = 'true';
            else
                str = 'false';
            end 
        end
    end
    
    methods (Static, Access = protected)
        function childrenStrings = getChildren(xmlString)
            xmlString = char(xmlString);
            
            % Find current element
            firstChildIdx = strfind(xmlString, '>')+1;
            element = xmlString(2:firstChildIdx-2);
            idx = strfind(element, ' ');
            if ~isempty(idx)
               element = element(1:idx-1); 
            end
            
            childrenStrings = {};
            
            % Find closing tag
            lastChildIdx = strfind(xmlString, ['</' element '>'])-1;
            if isempty(lastChildIdx)
               % This element has no children
               return               
            end
            
            rest = xmlString(firstChildIdx:lastChildIdx);
            
            % Split childrenString by elements
            while ~isempty(rest)
                % Find current element
                iStart = strfind(rest, '>')+1;
                element = rest(2:iStart-2);
                idx = strfind(element, ' ');
                if ~isempty(idx)
                   element = element(1:idx-1); 
                end
                
                % Find closing tag
                iStop = strfind(rest, ['</' element '>'])-1;
                if ~isempty(iStop)
                    iStop = iStop+3+length(element);
                    childrenStrings = [childrenStrings; {rest(1:iStop)}];
                    rest = rest(iStop+1:end);
                else
                    iStop = strfind(rest, '/>')+1;
                    childrenStrings = [childrenStrings; {rest(1:iStop)}];
                    rest = rest(iStop+1:end);
                end
            end
        end
        
        function attributes = getAttributes(elementString)
            elementString = char(elementString);
            
            % Returns a Map of attributes names to values
            attributes = containers.Map;
            
            idx = strfind(elementString, '>')+1;
            text = elementString(1:idx-1);
            
            idx = strfind(text, ' ');
            if isempty(idx)
               % No attributes
               return 
            end
            
            rest = text(idx+1:end);
            while ~strcmp(rest, '>') && ~strcmp(rest, '/>')
                idx = strfind(rest, '=');
                k = strtrim(rest(1:idx-1));
                
                rest = rest(idx+2:end);
                idx = strfind(rest, '"');
                value = rest(1:idx-1);
                
                attributes(k) = value;
                
                rest = strtrim(rest(idx+1:end)); 
            end
        end
        
        function text = getText(elementString)
            elementString = char(elementString);
            
            text = '';
            idx = strfind(elementString, '/>');
            if ~isempty(idx)
                % Any element string containing /> cannot have a text value
                return
            end    
            
            iStart = strfind(elementString, '>')+1;
            iStop = strfind(elementString(2:end), '<');
            text = elementString(iStart:iStop);
        end
    end
end

