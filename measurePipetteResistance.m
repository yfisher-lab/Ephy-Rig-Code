function pipetteResistance = measurePipetteResistance(exptInfo,type,varargin)
%{
MEASUREPIPETTERESISTANCE

Aquires a Trial of voltage data obtained when the seal test is on 
and then use to calculate the pipette (or seal resistance) and also saves
that trace obtains from the recording

By default (set in acquireTrial) this will run of the time period specified by: 
rigSettings.sealTest.Dur

INPUT
exptInfo (struct)
type 'pipette' or 'seal' (String)

OUTPUT
pipetteResistance (MOhms)

%}
[data,trialMeta] = acquireTrial();% sample a quick trial of the seal test

current = data.current;
voltage = data.voltage;

% solve for holding current
holdingCurrent = mean(current);

% set current to where average is zero
currentZeroed = current - holdingCurrent;
voltageZeroed = voltage - mean(voltage);

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
    allVoltageResp(:,counter) = voltageZeroed( voltageStepUpInd(i) : voltageStepUpInd(i) + meanPulseFrameNum);
    counter = counter + 1;
end
% Get mean current trace
meanCurrentResp = mean(allCurrentResp');
meanVoltageResp = mean(allVoltageResp');

%Find the baseline period current for the mean response trace:
 START_OF_BASELINE_TRACE = 6/8; % extract starting baseline period of the trace
 END_OF_BASELINE_TRACE = 7/8;
% 
 startBaselineIndex = round( meanPulseFrameNum* START_OF_BASELINE_TRACE);
 endBaselineIndex = round( meanPulseFrameNum* END_OF_BASELINE_TRACE) - 1;
% 
 baselineCurrent = mean(meanCurrentResp( startBaselineIndex : endBaselineIndex ));
 baselineVoltage = mean(meanVoltageResp( startBaselineIndex : endBaselineIndex ));

meanCurrentRespCorrectBaseline = meanCurrentResp - baselineCurrent;
meanVoltageRespCorrectBaseline = meanVoltageResp - baselineVoltage;
allCurrentRespCorrectBaseline = allCurrentResp - baselineCurrent;

% plot current traces for user to see
figure(); 
plot( allCurrentRespCorrectBaseline ); hold on;
plot( meanVoltageRespCorrectBaseline ); hold on;
h = plot( meanCurrentRespCorrectBaseline); hold on;

% make mean trace line thick
LINE_THICKNESS = 4;
set( h,'linewidth', LINE_THICKNESS) 

% Find peak Current response to the seal pulse
peakCurrent = max( meanCurrentRespCorrectBaseline ); % pA

% Extract a steady state region of the current and voltage traces
START_OF_STEADYSTATE_TRACE = 2/8; % good steady state location
END_OF_STEADYSTATE_TRACE = 3/8;

startSteadyStateIndex = round( meanPulseFrameNum* START_OF_STEADYSTATE_TRACE);
endSteadyStateIndex = round( meanPulseFrameNum* END_OF_STEADYSTATE_TRACE);

steadyStateCurrentAmp = abs( mean( meanCurrentRespCorrectBaseline(startSteadyStateIndex:endSteadyStateIndex)));
steadyStateVoltageAmp = abs( mean( meanVoltageRespCorrectBaseline(startSteadyStateIndex:endSteadyStateIndex)));

%% Calculate seal test amplitude using steady state voltage value
sealTestAmplitude = steadyStateVoltageAmp; % mV
disp(['Seal test amplitude decoded as: ' num2str(sealTestAmplitude) 'mV']);

ephysSettings;
rigSettings.defaultSealTestAmplitude = 10; % mV, this is 700b multiclamp default

if (rigSettings.defaultSealTestAmp-1 > sealTestAmplitude || sealTestAmplitude > rigSettings.defaultSealTestAmp+1)
    warning('Decoded seal test value is outside of the expected default ranage, check 700b multiclamp settings' )
end

%% Calculate pipette Resistance using steady state current value %%
VOLTS_PER_MiliVOLTS = 1e-3; % V /1000 mV
AMPS_PER_pA = 1e-12; % 1e-12 A / 1 pA
MEGAOHM_PER_OHM = 1e-6; % 1 MOhm / 1e6 Ohm

pipetteResistance = ((sealTestAmplitude * VOLTS_PER_MiliVOLTS) / (steadyStateCurrentAmp * AMPS_PER_pA)) * MEGAOHM_PER_OHM; % MOhms


if nargin ~= 0
    [~, path, ~, idString] = getDataFileName(exptInfo);
    switch type
        case 'pipette'
            filename = [path,'\preExptTrials\',idString,'pipetteResistance'];
        case 'seal'
            filename = [path,'\preExptTrials\',idString,'sealResistance'];
    end
    save(filename,'data','exptInfo','trialMeta');
end



