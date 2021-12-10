function [ out ] = addAccessStepPeriod( in , varargin)
%ADDACCESSSTEPPERIOD adds a spacer period that checks cell access before and after the main trial
%
%   Short (2) second spacer period at the start and end of the trail
%   with a small current injection step that will be used to analize the neurons' access resistance
%
%      ephySettings is reference to obtain these variables (commented current 10/2016):
%      settings.sampRate.out
%      settings.pulse.Amp
%      settings.pulse.Dur : 0.5
%      settings.pulse.spacerDur : 2 seconds
%
%   INPUT:
%   in - contains 
%
%
%      This version of this function should handle both CURRENT CLAMP and VOLTAGE CLAMP recording mode
%       I-Clamp mode is the default mode that is assumed if there is not a
%       second input variable
%
%      And adds a pulse that is correctly calibrated for the conversion
%      factor to the amplified and based on the Constants for those pulse
%      amplitudes denoted in ephysettings
%
%
% Yvette Fisher 8/2016 updated 2/2017
if( nargin == 1)
    %Default setting of the recording mode for current injection amplitude
    CURRENT_CLAMP_MODE = true;%
else
    % use the logical variable in varargin 2 to set recording mode
    CURRENT_CLAMP_MODE = varargin{1};%  
    % false indicates Voltage clamp mode
end
ephysSettings %used to be samp Rate and pulse amplitude

spacer = zeros(1,settings.pulse.spacerDur*settings.sampRate);
spacerEpochNum = zeros(1,settings.pulse.spacerDur*settings.sampRate);

middleIndex = numel(spacer)/ 2; % find the middle of the spacer duration

% find start and end of the pulse time
pulseStart_ind = round( middleIndex - ((settings.pulse.Dur * settings.sampRate)/2));
pulseEnd_ind = round( middleIndex + ((settings.pulse.Dur * settings.sampRate)/2));


% Set amplitude of the test step for either I-Clamp or V-Clamp
if( CURRENT_CLAMP_MODE )
% for I-Clamp set portion of spacer to be larger than zero for the step of pA injection
spacer( pulseStart_ind : pulseEnd_ind) = settings.pulse.Amp * settings.daq.currentConversionFactor; % in Voltage for the daq to send
else 
% for V-Clamp set portion of spacer to be larger than zero for the step of voltage injection
spacer( pulseStart_ind : pulseEnd_ind) = settings.voltagePulse.Amp * settings.daq.voltageConversionFactor; % in Voltage for the daq to send
end


% if in is a struct (thus contains mutliple fields)
if ( isstruct(in) )
    
    % update all other fields by adding the correct spacers
    fields = fieldnames(in);
    %otherFields = fields(2: end); % all fields after the first one, first needs to be command
    
    for i = 1:length(fields)
        % string of current Field
        currField = fields{i};
        
        if ( strcmp(currField ,  'command' ) ) % if field is command
            
            % add spacer to command field
            out.command = [spacer in.command spacer ];
            
            %Check if the field is its a struct, if so don't add
            %spacers since this is storing parameter and is not a trial array
        elseif ( isstruct(in.(currField) ) )
            
            % store struct 
            out.(currField) = in.(currField);
            
        elseif ( islogical (in.(currField) ) )
            
            % store boolean field
            out.(currField) = in.(currField);
            
        else % if not a struct and not boolean, and not 'command' add zero spacers
            
            % add Zero spacers to this field and add into 'out' variable
            out.(currField) = [spacerEpochNum in.(currField) spacerEpochNum];
        end
        
    end
    
% Functionality begining to be phased out in 'visualStimulus'    
else % simple version of stimlulus
    %add spacer before and after command
    out = [spacer in spacer];
end

end

