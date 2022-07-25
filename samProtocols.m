function [] = samProtocols( exptInfo, preExptData )
%SAMPROTOCOLS function that runs experimental protocols written for rig
%sam in 135
% The user is prompted with a list of all the optional protocols to run.
%
% Yvette Fisher 1/2022

while 1
    ephysSettings;

    % get user to pick wanted stimulus
    GETSTIMULUSNAME = true;
    while(GETSTIMULUSNAME)

        prompt = ['Which stimulus would you like to run? Options:q,step(amp,dur),stepLoop(amp,dur,reps), LEDstim(stim,isi,reps),\n' ...
            'LEDstim_currInject_corr(stim,isi,inject,reps), noCurrent(dur),makeInjectionWaveform(InjpA,BaseDur,PulseDur,PostDur),\n' ...
            'summation(X,Y,Z,BaseDur,PulseDur,PostDur), wholeProtocol(X,Y,Z,BaseDur,PulseDur,PostDur), n=exit: '];
        % Ask user for stimulus command to run
        choosenStimulus = input( prompt, 's');

        try
            % evaluate stimulus contruction code and obtain the current command wave form to be used.
            stimulus = eval(choosenStimulus);
            stimulus.name = choosenStimulus; % Also store information about the stimulus name and waveform

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

    % Acquire a trial
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
commandArray = zeros(1,TRIAL_DURATION*rigSettings.sampRate);
out.command = buildOutputSignal('command', commandArray);
end

%% WRITE NEW FUNCTION HERE!!! with any inputs you like and out.command as the output for current injections in voltage correctly correspoding to the external output current
function [out]= makeInjectionWaveform (InjpA,BaseDur,PulseDur,PostDur)
%Injects Current for given Duration(s)
ephysSettings;
% makeInjectionWaveform function to inject current
InjectionBaseSamples = rigSettings.sampRate*BaseDur; % Hz=samples/sec
InjectionPulseSamples = rigSettings.sampRate*PulseDur;
InjectionPostSamples = rigSettings.sampRate*PostDur;

%Volts = ampGain*(InjpA/1000); %Voltage injection (1nA=1000pA)
%Volts = InjpA/ampGain;

Array_Base = [zeros(1,InjectionBaseSamples)]; %array Baseline values 0pA
Array_Inj = InjpA*[ones(1,InjectionPulseSamples)]; %array Injection Voltage values ?pA
Array_Post = [zeros(1,InjectionPostSamples)]; %array Post-injection values 0pA
fprintf('Running the single set current injection protocol');
commandArray = [Array_Base,Array_Inj,Array_Post] * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
out.command = buildOutputSignal('command', commandArray);
end
%% Inject step current
function [out] = summation(X,Y,Z,BaseDur,PulseDur,PostDur) %where x,y,z is current injected and by what steps
% Syntax
ephysSettings;
InjectionBaseSamples = rigSettings.sampRate*BaseDur; % Hz=samples/sec
InjectionPulseSamples = rigSettings.sampRate*PulseDur;
InjectionPostSamples = rigSettings.sampRate*PostDur;
% Initilising loop to be zero
Voltstep = 0;
CurrentToInject = X:Y:Z;
stepArray = [];
for i = 1:length(CurrentToInject)
    % loop
    %Voltstep = CurrentToInject(i)/ampGain;

    Array_Base = [zeros(1,InjectionBaseSamples)]; %array Baseline values 0pA
    Array_Inj = CurrentToInject(i)*[ones(1,InjectionPulseSamples)]; %array Injection Voltage values ?pA
    Array_Post = [zeros(1,InjectionPostSamples)]; %array Post-injection values 0pA

    stepArray = [stepArray, Array_Base,Array_Inj,Array_Post];
   
end

fprintf('Running the multiple current injection protocol');
commandArray = stepArray * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
out.command = buildOutputSignal('command', commandArray);
end

%% Inject Step Current multiple times throughout run

%15-20 minute run with baseline and step Current recordings; add ATP around
%the 4 minute mark
function [out] = wholeProtocol(X,Y,Z,BaseDur,PulseDur,PostDur) %where x,y,z is current injected and by what steps
%BaseDur and PostDur at 60 seconds = T(2n+1) where n is sec base and T is
%number of current injections
% Syntax
ephysSettings;
%All the noCurrent baseline variables
BaselineOne = rigSettings.sampRate*60; % Hz=samples/sec; set as 60s
BaselineTwo = rigSettings.sampRate*180; % Hz=samples/sec; set as 120s
postOne = rigSettings.sampRate*360; % Hz=samples/sec; set as 420 (8min)
postTwo = rigSettings.sampRate*120; % Hz=samples/sec; set as 120s

%Injection baseline variables
InjectionBaseSamples = rigSettings.sampRate*BaseDur; % Hz=samples/sec
InjectionPulseSamples = rigSettings.sampRate*PulseDur;
InjectionPostSamples = rigSettings.sampRate*PostDur;

%NoCurrent zeroArrays
Array_BaselineOne = [zeros(1,BaselineOne)]; %array Baseline values 0pA
Array_BaselineTwo = [zeros(1,BaselineTwo)]; %array Baseline values 0pA
Array_postOne = [zeros(1,postOne)]; %array Baseline values 0pA
Array_postTwo = [zeros(1,postTwo)]; %array Baseline values 0pA

% Initilising loopBaseline to be zero
Voltstep = 0;
CurrentToInject = X:Y:Z;
stepArray = [];
for i = 1:length(CurrentToInject)
    % loop
    %Voltstep = CurrentToInject(i)/ampGain;

    Array_Base = [zeros(1,InjectionBaseSamples)]; %array Baseline values 0pA
    Array_Inj = CurrentToInject(i)*[ones(1,InjectionPulseSamples)]; %array Injection Voltage values ?pA
    Array_Post = [zeros(1,InjectionPostSamples)]; %array Post-injection values 0pA

    stepArray = [stepArray, Array_Base,Array_Inj,Array_Post];
   
end
finalArray = [Array_BaselineOne stepArray Array_BaselineTwo stepArray Array_postOne stepArray Array_postTwo];
fprintf('Running the 15-20 minute multiple current injection protocol');
commandArray = finalArray * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
out.command = buildOutputSignal('command', commandArray);
end

%% noCurrent(dur)
function [out] = noCurrent(dur)
% quick function that records for 15 seconds
ephysSettings;
% trial duration
TRIAL_DURATION = dur; %seconds

fprintf('Running the no injection 15 second function');
commandArray = zeros(1,TRIAL_DURATION*rigSettings.sampRate);
out.command = buildOutputSignal('command', commandArray);
end

%% step
function [out] = step( amp, dur )
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

commandArray = injectionCommand * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
out.command = buildOutputSignal('command', commandArray);
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

commandArray = injectionCommand * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
out.command = buildOutputSignal('command', commandArray);
end

%%
function [out] = LEDstim( stimInterval_sec, interStimInterval_sec, reps)
ephysSettings;

LEDLogical = zeros(1, interStimInterval_sec * rigSettings.sampRate); % intitial interval with LED off

for i = 1:reps
    LEDLogical = [LEDLogical ones(1, stimInterval_sec * rigSettings.sampRate) zeros(1, interStimInterval_sec * rigSettings.sampRate)];
end

% LED output channel
out.LEDcommand = buildOutputSignal('LEDcommand',LEDLogical);

% command output channel
commandArray = zeros(1, length(LEDLogical));
out.command = buildOutputSignal('command', commandArray);
end


%%
function [out] = LEDstim_currInject( stimInterval_sec, interStimInterval_sec, inject_pA, offsetShift_sec,  reps)
% LEDstim_currInject
% stimInterval_sec - amount of LED stim time 
% interStimInterval_sec - time between stimulution
% inject_pA - how much current to inject for same interval and cadence as
% LED stim
% offsetShift_sec - seconds to offset the LED and current traces 
% by e.g. 0= correlated, 0.1 = current lags LED by 100ms
% reps = number of times to repeat.
ephysSettings;

LEDLogical = zeros(1, interStimInterval_sec * rigSettings.sampRate); % initial interval with LED off

for i = 1:reps
    LEDLogical = [LEDLogical ones(1, stimInterval_sec * rigSettings.sampRate) zeros(1, interStimInterval_sec * rigSettings.sampRate)];
end

% LED output channel
out.LEDcommand = buildOutputSignal('LEDcommand',LEDLogical);

currLogical = circshift(LEDLogical, offsetShift_sec*rigSettings.sampRate); % shift the current trace offset from the LED trace
% command output channel
commandArray = currLogical * inject_pA * rigSettings.command.currentClampExternalCommandGain; % send full command out, in Voltage for the daq to send
out.command = buildOutputSignal('command', commandArray);
end

%% 
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
    if ( ~strcmp(currField,'name') )
        % plot array on figure
        plot( stimulus.(currField).output ); hold on;
    end
end

% adds a title with stimulus' name
title(stimulus.name);
end