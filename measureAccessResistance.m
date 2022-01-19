function [holdingCurrent, accessResistance, inputResistance] = measureAccessResistance(exptInfo,varargin)
%{
MEASUREACCESSRESISTANCE

Aquires a Trial of voltage clamp data obtained when the seal test is on 
and then use this response to calculate the accessResistance,
membraneResistance and inputResistance and also the holding current. The 
obtained trace is saved


INPUT
exptInfo (struct)

OUTPUT
holdingCurrent (pA) average current being injected to hold voltage
accessResistance (MOhms) calcluated as delta_V / delta_I transient
membraneResistance (MOhms) calcluated as delta_V / delta_I steady state
inputResistance (MOhms) sum of access and membrane resistance (?)

%}
[data,trialMeta] = acquireTrial();% sample a quick trial of the seal test

current = data.current;
voltage = data.voltage;

% solve for holding current
holdingCurrent = mean(current);

% set current to where average is zero
currentZeroed = current - holdingCurrent;

% find out when the voltage is above (1) and below (0) the mean value.
pulseOn =  voltage > mean(voltage);

% Extract the indexes where voltage steps Up or Down
voltageStepUpInd = find( diff(pulseOn) == 1);
voltageStepDownInd = find( diff(pulseOn) == -1);

lengthOfShorterArray = min([ length( voltageStepUpInd) ,length( voltageStepDownInd) ]); 

% Find average pulse duration
meanPulseFrameNum = mean( voltageStepUpInd(1 :lengthOfShorterArray) - voltageStepDownInd (1:lengthOfShorterArray) );

% Round to integer and make positive, times 2 to include up and down pulse
meanPulseFrameNum = 2 * abs( round (meanPulseFrameNum));

%% debugging plots
figure(88)
plot(voltage); hold on;
scatter(voltageStepUpInd', -0.5 * ones(1, length(voltageStepUpInd))); hold on 
scatter(voltageStepDownInd', -0.5 * ones(1, length(voltageStepDownInd)))
plot(currentZeroed)
%%

FIRST_PULSE_TO_USE = 2; % start on second pulse incase first pulse has aberation
LAST_PULSE_TO_USE = length(voltageStepUpInd) - 1;  % skip last pulse incase it is too short.
counter = 1;

for i = FIRST_PULSE_TO_USE: LAST_PULSE_TO_USE 
    
    %Store current trace for each pulse in this array
    allCurrentResp(:,counter) = currentZeroed( voltageStepUpInd(i) : voltageStepUpInd(i) + meanPulseFrameNum);
    counter = counter + 1;
end
% Get mean current trace
meanCurrentResp = mean(allCurrentResp');

%Find the baseline period current for the mean response trace:
 START_OF_BASELINE_TRACE = 1/6; % extract starting baseline period of the trace
 END_OF_BASELINE_TRACE = 2/6;
% 
 startBaselineIndex = round( meanPulseFrameNum* START_OF_BASELINE_TRACE);
 endBaselineIndex = round( meanPulseFrameNum* END_OF_BASELINE_TRACE) - 1;
% 
 baselineCurrent = mean(meanCurrentResp( startBaselineIndex : endBaselineIndex ));

meanCurrentRespCorrectBaseline = meanCurrentResp - baselineCurrent;
allCurrentRespCorrectBaseline = allCurrentResp - baselineCurrent;

% plot current traces for user to see
figure(); 
plot( allCurrentRespCorrectBaseline ); hold on;
h = plot( meanCurrentRespCorrectBaseline);

% make mean trace line thick
LINE_THICKNESS = 4;
set( h,'linewidth', LINE_THICKNESS) 


% Find peak Current response to the -5mV pulse
peakCurrent = abs( min( meanCurrentRespCorrectBaseline )); % pA

% Solve for acccessResistance using peak current value
VOLTAGE_STEP_AMP = 5; %mV  (seal test from the amplifier)
VOLTS_PER_MiliVOLTS = 1e-3; % V /1000 mV
AMPS_PER_pA = 1e-12; % 1e-12 A / 1 pA
MEGAOHM_PER_OHM = 1e-6; % 1 MOhm / 1e6 Ohm

accessResistance = ((VOLTAGE_STEP_AMP * VOLTS_PER_MiliVOLTS) / (peakCurrent * AMPS_PER_pA)) * MEGAOHM_PER_OHM; % MOhms

% Extract a steady state region of the trace
START_OF_STEADYSTATE_TRACE = 4/6; % extract middle 1/3 of trace
END_OF_STEADYSTATE_TRACE = 5/6;

startSteadyStateIndex = round( meanPulseFrameNum* START_OF_STEADYSTATE_TRACE);
endSteadyStateIndex = round( meanPulseFrameNum* END_OF_STEADYSTATE_TRACE);

steadyStateCurrentAmp = abs( mean( meanCurrentRespCorrectBaseline (startSteadyStateIndex:endSteadyStateIndex)));

%solve for the input resistance using steady state current
inputResistance = ((VOLTAGE_STEP_AMP * VOLTS_PER_MiliVOLTS) / (steadyStateCurrentAmp * AMPS_PER_pA)) * MEGAOHM_PER_OHM; % MOhms


% Save
[~, path, ~, idString] = getDataFileName(exptInfo);
filename = [path,'\preExptTrials\',idString,'accessResistance'];
save(filename,'data','exptInfo','trialMeta');

end