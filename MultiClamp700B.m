classdef MultiClamp700B < handle
    % Interact with 700B using the telegraphed windows message system.
    % built with code provided here: https://github.com/JaneliaSciComp/Wavesurfer
    properties (Constant)
        % Serial for the whole amplifier
        serial_number = 00838328
        
        % Minimum version required (2019b+)
        min_version = '9.7.0'
    end

    properties (Access = protected)
        % Which headstage the interface is for
        amp_headstage_uid
    end

    properties
        %-----------------------------
        % Amplifier headstage metadata
        % ----------------------------
        amp_headstage_num                   double = -1 % 1 or 2

        % Dynamic Amplifier Properties
        amp_operating_mode                  char = 'unknown';  % {'V-Clamp'}

        amp_primary_out_signal              char = 'unknown';
        amp_secondary_out_signal            char = 'unknown';

        amp_primary_alpha                   double = -1
        amp_secondary_alpha                 double = -1

        amp_primary_units_scale_factor      double = -1
        amp_secondary_units_scale_factor    double = -1

        amp_primary_units                   char = 'unknown';
        amp_secondary_units                 char = 'unknown'; 

        amp_primary_lpf_cutoff              double = -1
        amp_secondary_lpf_cutoff            double = -1

        amp_membrane_cap                    double = -1
        amp_ext_cmd_sens                    double = -1
        amp_ext_cmd_units                   char = 'unknown';

        amp_ext_cmd_scale_factor            double = nan;
        amp_feedback_resistor               double = 0;
        
        % Manually Updated Amplifier Properties        
        amp_lpf_type_v_clamp                char = 'unknown';
        amp_lpf_type_i_clamp                char = 'unknown';
    end

    methods
        function obj = MultiClamp700B()
            if verLessThan('matlab',obj.min_version)
                error(['MATLAB version must be at least ' obj.min_version]);
            end

            conf_str = ['Correct metadata and scaling requires:\n',...
                        '\tV-Clamp Primary Out = Membrane Potential / Secondary Out = Membrane Current\n',...
                        '\tI-Clamp Primary Out = Membrane Current / Secondary Out = Membrane Potential\n'];
            
            fprintf(conf_str)
        end

        function obj = initalize(obj,options)
            arguments
                obj
                options.amp_headstage_num               (1,1) double = 1
                options.amp_lpf_type_v_clamp            char = 'bessel';
                options.amp_lpf_type_i_clamp            char = 'bessel';
            end

            axon.MulticlampTelegraph('stop');
            pause(.5)
            axon.MulticlampTelegraph('start');

            % Connect to correct headstage #1 269269554 #2 537705010
            obj.amp_headstage_uid = axon.MulticlampTelegraph(...
                            'get700BID',... 
                            uint32(obj.serial_number),...
                            uint32(options.amp_headstage_num));
            obj.amp_headstage_num = options.amp_headstage_num;

            obj.getState(true);

            % Set to the assumed value
            obj.amp_lpf_type_v_clamp = options.amp_lpf_type_v_clamp;
            obj.amp_lpf_type_i_clamp = options.amp_lpf_type_i_clamp;

            obj.print();
        end

        function obj = update(obj)
            if axon.MulticlampTelegraph('getIsRunning') 
                state = axon.MulticlampTelegraph('getElectrodeState', uint32(obj.amp_headstage_uid));
            else
                state = [];
            end

            if ~isempty(state)
                % Rename the channels slightly
                obj.amp_operating_mode = state.OperatingMode;

                %===Primary Channel========================================
                % the type of signal (Im, Vm)
                obj.amp_primary_out_signal = state.ScaledOutSignal;

                % Alpha is the gain on top of the output signal
                obj.amp_primary_alpha = state.Alpha;

                % "scale factor" is the base multiplier, e.g. at Alpha
                % (Gain) = 1, the signal will still be scaled by this
                obj.amp_primary_units_scale_factor = state.ScaleFactor;
                obj.amp_primary_units = state.ScaleFactorUnits;

                obj.amp_primary_lpf_cutoff = state.LPFCutoff;

                %===Secondary Channel (Direct Values)======================                

                % for some reason this is called "Raw" _and_ Secondary
                obj.amp_secondary_alpha = state.SecondaryAlpha;
                obj.amp_secondary_units_scale_factor = state.RawScaleFactor;
                obj.amp_secondary_lpf_cutoff = state.SecondaryLPFCutoff;

                %===Feedback Resistor======================================
                % Use membrane current channel to infer the value of the
                % feedback resistor for the CURRENT mode. This is a
                % terrible hack, membrane current scales with the feedback
                % resistor, but you cannot determine the identity of the
                % secondary output through the telegraph. So, we just check
                % to see if the Primary outputs seem okay (Vm in I-Clamp,
                % and Im in V-Clamp /shrug).
                obj.amp_feedback_resistor = 0;

                switch obj.amp_operating_mode
                    case 'V-Clamp'

                        if ~strcmp(obj.amp_primary_out_signal, 'Im')
                            warning('Cannot infer feedback resistor if primary channel is not Im in V-Clamp')
                        end

                        if strcmp(obj.amp_primary_units,'V/nA')
                            obj.amp_feedback_resistor = obj.amp_primary_units_scale_factor * 1000;
                        elseif strcmp(obj.amp_primary_units,'V/pA')
                            obj.amp_feedback_resistor = obj.amp_primary_units_scale_factor * 1000 * 1000;
                        end

                    case {'I-Clamp', 'I = 0'}
                        if ~strcmp(obj.amp_primary_out_signal, 'Vm')
                            warning('Primary signal was not Vm. Secondary channel MUST be Im to infer feedback resistor in I-Clamp or I = 0.')
                        end

                        % Thankfully there is only one range used here
                        obj.amp_feedback_resistor =  obj.amp_secondary_units_scale_factor * 1000;

                end

                %===Secondary Channel (Inferred Values)====================
                % "state.RawOutSignal" is not yet implemented, which has
                % the secondary channel signal. So we set it based on the
                % primary, and use some error checking. Assumes configured
                % according to warning at start.

                warn_str = 'Primary and Secondary Output not as expected. Errors may occur for some feedback resistor values.';
                obj.amp_secondary_out_signal = '';

                switch obj.amp_operating_mode
                    case {'I-Clamp', 'I = 0'}
                        if strcmp(obj.amp_primary_out_signal, 'Vm')
                            obj.amp_secondary_out_signal = 'Im';
                        else
                            warning(warn_str)
                        end
                    case 'V-Clamp'
                        if strcmp(obj.amp_primary_out_signal, 'Im')
                            obj.amp_secondary_out_signal = 'Vm';
                        else
                            warning(warn_str)
                        end
                end

                % state.RawScaleFactorUnits not implemented, so use the
                % inferred feedback resistor to figure out how things have
                % scaled. Writing it all out to be straightforward

                switch obj.amp_secondary_out_signal
                    case 'Im' % in I-Clamp or I = 0

                        if obj.amp_feedback_resistor == 50
                            obj.amp_secondary_units = 'V/nA';

                        elseif obj.amp_feedback_resistor == 500
                            if obj.amp_secondary_alpha < 20
                                obj.amp_secondary_units = 'V/nA';
                            else
                                obj.amp_secondary_units = 'V/pA';
                            end

                        elseif obj.amp_feedback_resistor == 5000
                            if obj.amp_secondary_alpha < 2
                                obj.amp_secondary_units = 'V/nA';
                            else
                                obj.amp_secondary_units = 'V/pA';
                            end

                        end

                    case 'Vm' % in V-Clamp Vm is always the same
                        obj.amp_secondary_units = 'mV/mV';

                end

                %===External Command Sensitivity===========================
                % The units for external command sensitivity are ALWAYS 
                % returned as pA or mV (in spite of GUI changing).
                if strcmpi(obj.amp_operating_mode, 'I-Clamp')
                    obj.amp_ext_cmd_units = 'pA/V'; %400pA/V -> 4E-10; 2nA/V -> 2E-9
                elseif strcmpi(obj.amp_operating_mode, 'V-Clamp')
                    % V-Clamp does not change with feedback resistor
                    obj.amp_ext_cmd_units = 'mV/V';
                else
                    obj.amp_ext_cmd_units = 'none';
                end

                obj.amp_ext_cmd_sens = state.ExtCmdSens; 

                %===Remaining Parameters===================================

                obj.amp_membrane_cap = state.MembraneCap;

                % standard units scale factor
                obj.amp_ext_cmd_scale_factor = obj.getScaleFactor();

            else
                warning('MultiClampTelegraph is not updating.')
            end
        end

        function state = getState(obj,update)
            arguments
                obj
                update logical = true
            end

            if update
                obj.update();
            end

            state = struct();

            state.amp_headstage_num                 = obj.amp_headstage_num;
            state.amp_operating_mode                = obj.amp_operating_mode;
            state.amp_primary_out_signal            = obj.amp_primary_out_signal;
            state.amp_primary_alpha                 = obj.amp_primary_alpha;
            state.amp_primary_units_scale_factor    = obj.amp_primary_units_scale_factor;
            state.amp_primary_units                 = obj.amp_primary_units;
            state.amp_primary_lpf_cutoff            = obj.amp_primary_lpf_cutoff;
            state.amp_secondary_out_signal          = obj.amp_secondary_out_signal;
            state.amp_secondary_alpha               = obj.amp_secondary_alpha;
            state.amp_secondary_units_scale_factor  = obj.amp_secondary_units_scale_factor;
            state.amp_secondary_units               = obj.amp_secondary_units;
            state.amp_secondary_lpf_cutoff          = obj.amp_secondary_lpf_cutoff;
            state.amp_membrane_cap                  = obj.amp_membrane_cap;
            state.amp_ext_cmd_sens                  = obj.amp_ext_cmd_sens;
            state.amp_ext_cmd_units                 = obj.amp_ext_cmd_units;
            state.amp_feedback_resistor             = obj.amp_feedback_resistor; 

        end

        function num = getHeadstageNumber(obj)
            num = obj.amp_headstage_num;
        end

        function checkState(obj, command_type)

            % make sure the channels are configured properly
            obj.verifyAmpInValidTestState(true);

            % make sure the mode is appropriate
            switch command_type
                case 'current'
                    % Send a current step and look at voltage resp
                    if ~strcmp(obj.amp_operating_mode,'I-Clamp')
                        error('I-Clamp mode required for current commands.')
                    end
                case 'voltage'
                    % Send a voltage step and look at current resp
                    if ~strcmp(obj.amp_operating_mode,'V-Clamp')
                        error('V-Clamp mode required for voltage commands.')
                    end
            end
        end

        function is_valid = verifyAmpInValidTestState(obj,send_error)
            % Makes sure that the amplifier is in a mode where a command
            % can be sent and that the primary and secondary outputs have
            % voltage and current or current and voltage as ouputs. This
            % allows testing of membrane resistance, capacitance etc.,
            % make sure it is not in I=0 and determine the scale factor
            arguments
                obj
                send_error logical = true
            end

            obj.getState(true);

            if ~(strcmp(obj.amp_operating_mode,'V-Clamp') || strcmp(obj.amp_operating_mode,'I-Clamp'))
                mode_valid = false;
                mode_error_str = 'Amplifier not detected as in V-Clamp or I-Clamp mode. Cannot send current or voltage commands.';
                if send_error
                    error(mode_error_str)
                else
                    warning(mode_error_str);
                end
            else
                mode_valid = true;
            end

            % Make sure there are both voltage and current measurements
            if ~((strcmp(obj.amp_primary_out_signal,'Vm') && ...
                  strcmp(obj.amp_secondary_out_signal,'Im')) || ...
                 (strcmp(obj.amp_primary_out_signal,'Im') && ...
                  strcmp(obj.amp_secondary_out_signal,'Vm')))
                signals_valid = false;
                signal_error_str = 'Primary and Secondary Channels must contain both Vm and Im signals.';
                if send_error
                    error(signal_error_str)
                else
                    warning(signal_error_str);
                end
            else
                signals_valid = true;
            end

            is_valid = mode_valid && signals_valid;
        end

        function scale_factor = getScaleFactor(obj)
            % returns scale factor for V in V-Clmap, and A in I-Clamp
            arguments
                obj (1,1) MultiClamp700B
            end

            switch obj.amp_operating_mode
                case 'V-Clamp'
                    switch obj.amp_ext_cmd_units
                        case 'mV/V'
                            scale_factor = obj.amp_ext_cmd_sens / 10^-3;
                        otherwise
                            error('command units %s not accounted for', units)
                    end

                case 'I-Clamp'
                    switch obj.amp_ext_cmd_units
                        case 'pA/V'
                            scale_factor = obj.amp_ext_cmd_sens / 10^-12;
                        case 'nA/V'
                            scale_factor  = obj.amp_ext_cmd_sens / 10^-9;
                        otherwise
                            error('command units %s not accounted for', units)
                    end

                otherwise
                    scale_factor = 0;
            end
        end

        function print(obj)
            % convenience function
            state = obj.getState(false);
            obj.printState(state);
        end

    end

    methods (Static)
        function printState(state)
            n_char = fprintf(['=====', sprintf('\x2661'), '====MultiClamp 700B=====', sprintf('\x2661'), '====\n']); 
            n_char = n_char - 1;
            n = fprintf("= Headstage Number: %d",state.amp_headstage_num); 
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            n = fprintf("= Amplifier Mode:   %s",state.amp_operating_mode); 
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            n = fprintf("= Feedback Res:     %d",state.amp_feedback_resistor); 
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            n = fprintf("= Primary Output:   %s",state.amp_primary_out_signal); 
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            n = fprintf("= Primary Units:    %.2f%s",state.amp_primary_alpha*state.amp_primary_units_scale_factor,state.amp_primary_units);
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            n = fprintf("= Primary Cutoff:   %dHz",state.amp_primary_lpf_cutoff);
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            fprintf([ '= ' repmat('-',1,n_char-4) ' =\n'])
            n = fprintf("= Secondary Output: %s",state.amp_secondary_out_signal);
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            n = fprintf("= Secondary Units:  %.2f%s",state.amp_secondary_alpha*state.amp_secondary_units_scale_factor,state.amp_secondary_units);
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            n = fprintf("= Secondary Cutoff: %dHz",state.amp_secondary_lpf_cutoff);
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])
            fprintf([ '= ' repmat('-',1,n_char-4) ' =\n'])
            n = fprintf("= Ext Cmd Sens:     %.4f%s",state.amp_ext_cmd_sens,state.amp_ext_cmd_units);           
            fprintf([ repmat(' ',1,n_char-1-n) '=' '\n'])            
            fprintf([ repmat('=',1,n_char) '\n'])
        end

        function checkModeErr(state,mode)
            if ~strcmpi(state.amp_operating_mode, mode)
                error('MultiClamp State is NOT %s',mode)
            end
        end

        function [sig_out, units_out] = multiclampUnits2VoltsAmps(sig_in, alpha, scale_factor, units)
        % Scales signals to retrieve milivolts and picoamps

            % remove the scaling from alpha value and scale_factor
            % this is a bit confusing if we do it all in one step, 
            % so first unscaling happens here so that e.g. 10 mV/mv 
            % in multiclamp commander becomes 1 mV/mV (1V/V)
            unscaled_signal = sig_in ./ (alpha * scale_factor);

            switch units
                case 'V/nA'
                    new_scale_factor = 10^-9;
                    units_out = 'A';
                case {'V/V','mV/mV'}
                    new_scale_factor = 1;
                    units_out = 'V';
                case 'V/pA'
                    new_scale_factor = 10^-12;
                    units_out = 'A';
                otherwise
                    error('Was unable to look up conversion factor based on units')
            end

            % multiply by our new scaling factor to get V or A
            sig_out = unscaled_signal .* new_scale_factor;
        end

        function [sig_out, units_out] = multiclampUnits2miliVpicoA(sig_in, alpha, scale_factor, units)
        % Scales signals to retrieve milivolts and picoamps

            % remove the scaling from alpha value and scale_factor
            % this is a bit confusing if we do it all in one step, 
            % so first unscaling happens here so that e.g. 10 mV/mv 
            % in multiclamp commander becomes 1 mV/mV (1V/V)
            unscaled_signal = sig_in ./ (alpha * scale_factor);

            switch units
                case 'V/nA'
                    new_scale_factor = 1000;
                    units_out = 'pA';
                case {'V/V','mV/mV'}
                    new_scale_factor = 1000;
                    units_out = 'mV';
                case 'V/pA'
                    new_scale_factor = 1;
                    units_out = 'pA';
                otherwise
                    error('Was unable to look up conversion factor based on units')
            end

            % multiply by our new scaling factor to get mV or pA, e.g. now 1V/V
            % goes to mV 
            sig_out = unscaled_signal .* new_scale_factor;
        end

    end
end