function [] = frodoProtocols( exptInfo, preExptData )
%FRODOPROTOCOLS function that runs experimental protocols written for rig
%frodo in 135
% The user is prompted with a list of all the optional protocols to run.
%
% Yvette Fisher 1/2022

while 1
    ephysSettings;

    % get user to pick wanted stimulus
    GETSTIMULUSNAME = true;
    while(GETSTIMULUSNAME)

        prompt = ['Which stimulus would you like to run? Options:q,step(amp,dur),stepLoop(amp,dur,reps) n=exit: '];
        % Ask user for stimulus command to run
        choosenStimulus = input( prompt, 's');

        try
            % evaluate stimulus contruction code and obtain the current command wave form to be used.
            stimulus = eval(choosenStimulus);
            stimulus.name = choosenStimulus; % Also store information about the stimlulus name and waveform

            GETSTIMULUSNAME = false; % If eval ran without breaking, exit this loop and continue on with the rest of the code
        catch
            if(choosenStimulus == 'n'); break; end % exit this loop if 'n' was entered and user wants to quit...

            disp('ERROR: there is a problem with the stimulus command you entered, please try to enter it again :)  ');
        end
    end

    % break out of code if 'n' was entered and user wants to quit...
    if(choosenStimulus == 'n')
        break;
    end % exit whole set of code

    % plot command, and Trigger signal that are in stimulus
    plotCommandSignals( stimulus );

    % Aquire a trial
    [data] = acquireTrial(stimulus, exptInfo, preExptData);
end
end
%% Frodo ephy rig protocols functions
%% q
function [out] = q( )
% quick function that records for 15 seconds
ephysSettings;
% trial duration
TRIAL_DURATION = 15; %seconds

fprintf('Running the no injection 15 second function');
out.command = zeros(1,TRIAL_DURATION*rigSettings.sampRate);
end

%% step
function [out] = step ( amp, dur )
% step runs a quick trial with a single step of
% amp = amplitude of the step in pA
% dur = durations of the step in seconds
ephysSettings;
PRE_STEP_DURATION = 2; % seconds
STEP_DURATION = dur; % seconds
STEP_AMP = amp; % pA

preStepCommand = zeros(1, PRE_STEP_DURATION * rigSettings.sampRate );

stepCommand = STEP_AMP * ones( 1, STEP_DURATION * rigSettings.sampRate );

injectionCommand = [preStepCommand stepCommand];

out.command = injectionCommand * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
end

%% stepLoop
function [out] = stepLoop ( amp, dur, reps )
% step runs a quick trial with a single step of
% amp = amplitude of the step in pA
% dur = durations of the step in seconds
% for as many times as is specified in reps
ephysSettings;
PRE_STEP_DURATION = 2; % seconds
STEP_DURATION = dur; % seconds
STEP_AMP = amp; % pA

injectionCommand = [];
for i = 1: reps
    preStepCommand = zeros(1, PRE_STEP_DURATION * rigSettings.sampRate );
    stepCommand = STEP_AMP * ones( 1, STEP_DURATION * rigSettings.sampRate );
    injectionCommand = [injectionCommand preStepCommand stepCommand];
end

out.command = injectionCommand * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
end

function [] = plotCommandSignals( stimulus )
% PLOTCOMMANDSIGNALS Plotting helper function
% Takes stimulus and parces which of these is an array
% plot all array, subfields in a figure to show the pattern to the user
% Yvette Fisher 2/2017
figure();
fields = fieldnames(stimulus);
% Loop over struct and plot any field that is not itself a struct
for i = 1:length(fields)
    % string of current Field
    currField = fields{i};
    % check that field is not a param struct or the name field
    if ( ~isstruct (stimulus.(currField) )  && ~strcmp(currField,'name') )
        % plot array on figure
        plot( stimulus.(currField) ); hold on;
    end
end
% adds a title with stimulus' name
title(stimulus.name);
end