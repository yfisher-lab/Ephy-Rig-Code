function [] = currentInjections(exptInfo,preExptData)
%CURRENTINJECTION function that runs the delivery of current injection
%stimuli
%   within the function the user will be given the option to run multiple
%   trails the contain different current injection protocols


while 1
    ephysSettings;       
        GETSTIMULUSNAME = true;
        while(GETSTIMULUSNAME)
            % Ask user for stimulus command to run
            choosenStimulus = input('Which stimulus would you like to run? Options:q,step(amp_pA,dur_s), stepRamp(min,max), stepLoop(amp_pA,dur_s,reps)\n IVcurve(max),variableSlope, variableSlopeShort(amp),constantCurrent(amp), constantVoltage(amp mV), n=exit: ', 's');
            try
                % evaluate stimluls contruction code and obtain the current command wave form to be used. 
                outCommand = eval(choosenStimulus);
                GETSTIMULUSNAME = false; % If eval ran without breaking, exit this loop and continue on with the rest of the code
            catch 
                if(choosenStimulus == 'n'); break; end% exit this loop if 'n' was entered and user wants to quit...
                
                disp('ERROR: there is a problem with the stimulus command you entered, please try to enter it again :)  ');
            end
        end
        
        % break out of code if 'n' was entered and user wants to quit...
        if(choosenStimulus == 'n'); break; end % exit whole set of code
        
        %add spacer with access test pulse
        outCommandSpacerAdded = addAccessStepPeriod(outCommand);

        % store information about the stimlulus name and waveform
        stimulus.name = choosenStimulus;
        
        % if epoch strucutre is stored in the data, save that too
        if( isstruct( outCommand ) )
            stimulus.epochStructure = outCommandSpacerAdded.epochs; % fixed 9/27
            stimulus.command = outCommandSpacerAdded.command;
            
            % And plot command
            figure();
            plot((1:length(outCommandSpacerAdded.command ))/settings.sampRate, outCommandSpacerAdded.command); xlabel ('seconds');
        else
            stimulus.command = outCommandSpacerAdded;
            
            % And plot command
            figure();
            plot((1:length(outCommandSpacerAdded))/settings.sampRate, outCommandSpacerAdded); xlabel ('seconds');
        end
        
        % aquire a trial, YVETTE: add more input/output arguments
        [data] = acquireTrial(stimulus, exptInfo, preExptData);
end

end
%% Current injection functions
%% q
function [out] = q( )
% quick function that records for 15 seconds
    ephysSettings;
    % trial duration
    TRIAL_DURATION = 15; %seconds

    fprintf('Running the no injection 15 second function');
    out = zeros(1,TRIAL_DURATION*settings.sampRate);
end
%% stepRamp
function [out ] = stepRamp (varargin)
fprintf('Running current Injection trial: stepRamp'); %YVETTE add in notification that uses the function name write this out each time
if( nargin == 0)
    %Default setting of current injection amplitude
    MAX_STEP_AMP = 4;%3; %pA the value you want the largest one to reach this value]
else
    MIN_STEP_AMP = varargin{1}; %pA 
    MAX_STEP_AMP = varargin{2}; % set bump ampltude to the input arguement
end
    ephysSettings;
   %MIN_STEP_AMP = 1; %pA  5
   NUMBER_OF_STEPS = 5; 
   
   PRE_STEP_DURATION = 7;% seconds
   STEP_DURATION = 10;% second
   
    stepSize = (MAX_STEP_AMP - MIN_STEP_AMP) / NUMBER_OF_STEPS ;
    ampList = MIN_STEP_AMP : stepSize : MAX_STEP_AMP;
    % suffle the amptude list, 
    % Removed randomization -11/9/16
    %amp = ampList( randperm( length(ampList) ) ); 
    amp = ampList;

   % create epochs and injectionCommand variables
   epochs = [];
   injectionCommand = []; %create command variable  
for i = 1 : NUMBER_OF_STEPS
    preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );   
    % pick the next amp
    stepCommand = amp(i) * ones( 1, STEP_DURATION * settings.sampRate );
    currentCommand = [preStepCommand stepCommand];
    
     % add this step to the trial
    injectionCommand = [injectionCommand currentCommand];
    
    % add epoch number for this trial to the epoch array
    thisEpoch =  i * ones(1, length (currentCommand ));
    epochs = [epochs thisEpoch];  % add current epoch to the array 
end
out.command = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
out.epochs = epochs;
end
%% IVcurve
function [out] = IVcurve ( maxInj )
fprintf('Running current Injection trial: IVcurve'); %YVETTE add in notification that uses the function name write this out each time
ephysSettings;

STEP_DURATION = .1; % 100ms, seconds
PRE_STEP_DURATION = 1; % seconds
NUMBER_OF_STEPS = 10;
% steps from -maxInj up to +maxInj increamenting up
MAX_INJ = maxInj; %pA
MIN_INJ = -1*maxInj; %pA

stepSize = (MAX_INJ - MIN_INJ) / NUMBER_OF_STEPS ;
ampList = MIN_INJ : stepSize : MAX_INJ;

% create epochs and injectionCommand variables
epochs = [];
injectionCommand = [];
for i = 1 : NUMBER_OF_STEPS
    
    preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );
    % pick the next amp
    stepCommand = ampList(i) * ones( 1, STEP_DURATION * settings.sampRate );
    currentCommand = [preStepCommand stepCommand];
    % add this step to the trial
    injectionCommand = [injectionCommand currentCommand];
    
    % add epoch number for this trial to the epoch array
    thisEpoch =  i * ones(1, length (currentCommand ));
    epochs = [epochs thisEpoch];  % add current epoch to the array 
end
out.command = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
out.epochs = epochs;
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

preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );

stepCommand = STEP_AMP * ones( 1, STEP_DURATION * settings.sampRate );

injectionCommand = [preStepCommand stepCommand];

out = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
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

preStepCommand = zeros(1, PRE_STEP_DURATION * settings.sampRate );

stepCommand = STEP_AMP * ones( 1, STEP_DURATION * settings.sampRate );

injectionCommand = [injectionCommand preStepCommand stepCommand];
end

out = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

%% hyperPulse
function [out] = hyperPulse (varargin)
% hyperpolarizing seal test to be used in current clamp to adjust the Series
% resistance compensation
fprintf('Running current Injection trial: hyperPulse'); %YVETTE add in notification that uses the function name write this out each time
ephysSettings;
if( nargin == 0)
    %Default duration of trial
    DURATION = 60;%seconds
else
    DURATION = varargin{1}; %seconds
end

PULSE_DURATION = 0.5;% seconds
totalFramesNum = DURATION * settings.sampRate;


injectionCommand = [];
while(1) % keep adding pulses until the trial is long enough
    %add an up pulse and a down pulse
    preStepCommand = zeros(1, PULSE_DURATION * settings.sampRate );
    stepCommand = settings.pulse.Amp * ones(1, PULSE_DURATION * settings.sampRate );
    injectionCommand = [injectionCommand preStepCommand stepCommand];
    if length( injectionCommand) >= totalFramesNum  
        break;% keep adding pulses until the trial is long enough
    end
end

out = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

%%
function [out] = variableSlope()
% keep bump amplitude constant with changing width- aka Standard diviation
fprintf('******Running the variableSlope function******* \n');

ephysSettings;
% random pick from Standard Deviation, keep area aka charge transfer the
% same
FRAME_RATE = settings.sampRate;
LENGTH_OF_BUMP_SEC = 10; % seconds  %YVETTE: make this figure out spacing based on bump size eventually!!
MU = LENGTH_OF_BUMP_SEC / 2;  % put mean of bump in middle of the trail
% I want to shortest bump to have a 2*SD of 10 ms
% therefore I want to shortest Sd to be 5 ms,
MIN_STD = 0.005;   % seconds
MAX_STD = 1; % 1 seconds, so ~2 sec wide

NUMBER_OF_BUMPS = 10; % Each bump will be a different size, for repeat trials run again
BUMP_AMPLITUDE = 15;%1%2%3%10; %pA the value you want the largest one to reach this value

% % randi needs interger inputs %YVETTE: edit this so that there are a set
% % number of STD that are use and that that number is an input/Constant
% std = MIN_STD * randi(MAX_STD / MIN_STD ,MIN_STD / MIN_STD, NUMBER_OF_BUMPS);
stepSize = (MAX_STD - MIN_STD) / NUMBER_OF_BUMPS ;
stdList = MIN_STD : stepSize : MAX_STD;
std = stdList( randperm( length(stdList) ) ); % shuffle the std order

% timeArray in correct frame rate
timeArray = 0 : 1 / FRAME_RATE : LENGTH_OF_BUMP_SEC;

% % find max peak for the MIN_STD
% norm = normpdf (timeArray, MU, MIN_STD);
% peak = max(norm);
% scaleFactor = MAX_AMPLITUDE / peak;
injectionCommand = [];

for i = 1 : length (std)
    %make gaussian bump with choosen std
    norm = normpdf (timeArray, MU, std(i));
    
    %find peak of this bump
    peak = max( norm );
    scaleFactor = BUMP_AMPLITUDE / peak;
    
    bump = norm * scaleFactor; % scale that bump to have BUMP_AMPLITUDE (pA)
    slopedStep = bump;
    
    stepStart = (LENGTH_OF_BUMP_SEC / 2) * FRAME_RATE; % start half way into the bump trace
    stepEnd = LENGTH_OF_BUMP_SEC * FRAME_RATE; % end of bump trace
    slopedStep(stepStart : stepEnd ) =  BUMP_AMPLITUDE; % set step equal to bump amplitude 
    
    injectionCommand = [injectionCommand slopedStep]; % add new bump onto trace
end
out = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

%%
function [out] = variableSlopeShort(varargin)
% keep bump amplitude constant with changing width- aka Standard diviation
fprintf('******Running the variableSlopeShort function******* \n');

if( nargin == 0)
    %Default setting of current injection amplitude
    BUMP_AMPLITUDE = 4;%6;%4;%3; %pA the value you want the largest one to reach this value]
else
    BUMP_AMPLITUDE = varargin{1}; % set bump ampltude to the input arguement
end
ephysSettings;
FRAME_RATE = settings.sampRate;

STD_SLOPE_LIST = [0.5 1e-1 1e-2 1e-3 1e-4];% std of gaussian bump, in seconds
NUMBER_OF_TIMES_THOUGH_LIST = 10;

stdListRamdomized = STD_SLOPE_LIST( randperm( length (STD_SLOPE_LIST) ) ); %shuffle the order of this slopes/std
stdList = repmat(stdListRamdomized, 1, NUMBER_OF_TIMES_THOUGH_LIST); % list of all the slope/epochs to use

LENGTH_OF_BUMP_SEC = 4; % seconds  %YVETTE: maybe make this figure out spacing based on bump size eventually!!
MU = LENGTH_OF_BUMP_SEC / 2;  % put mean of bump in middle of the trail

PEAK_DURATION = .200 ;% second, 200 ms, time the step stays at the peak inejction value

% timeArray in correct frame rate
timeArray = 0 : 1 / FRAME_RATE : LENGTH_OF_BUMP_SEC;

injectionCommand = [];
epochs = [];

% loop over each std and build the command trace
for i = 1 : length (stdList)
    %make gaussian bump with choosen std
    norm = normpdf (timeArray, MU, stdList(i));
    
    %find peak of this bump
    peak = max( norm );
    scaleFactor = BUMP_AMPLITUDE / peak;
    
    bump = norm * scaleFactor; % scale that bump to have BUMP_AMPLITUDE (pA)
    % extract the first half of the bump trace
    stepPeakFrame = (LENGTH_OF_BUMP_SEC / 2) * FRAME_RATE; % start half way into the bump trace
    slopedRegion = bump (1 : stepPeakFrame);
    
    % add extented peak period after the slope- 
    peakRegion = BUMP_AMPLITUDE * ones (1 , PEAK_DURATION * FRAME_RATE );
    
    slopedStep = [ slopedRegion peakRegion ]; % combine slope and peak regions

    injectionCommand = [injectionCommand slopedStep]; % add new slope and Step onto trace
    
    % find which value you are in STD_SLOPE_LIST and add this num to the
    % epoch list ...
    currentEpoch = find (STD_SLOPE_LIST == stdList(i)); % find which epoch we are on
    
    % build a trace the length of the this slopedStep of that epoch number
    % repeating
    thisEpoch =  currentEpoch * ones(1, length (slopedStep));
    epochs = [epochs thisEpoch];  % add current epoch to the array 
    
end
out.command = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
out.epochs = epochs;
end

function [out] = constantCurrent(InjAmp)
% quick function that records for 60 seconds
    ephysSettings;
    % trial duration
    TRIAL_DURATION = 60; %seconds

    fprintf('Running constant injection for 60 second function');

    injectionCommand = InjAmp * ones(1,TRIAL_DURATION*settings.sampRate);
    out = injectionCommand * settings.daq.currentConversionFactor; % send full command out, in Voltage for the daq to send
end

function [out] = constantVoltage(mVoltAmp)
% quick function that records for 60 seconds
    ephysSettings;
    % trial duration
    TRIAL_DURATION = 60; %seconds

    fprintf('Running constant injection for 60 second function');
    injectionCommand = mVoltAmp * ones(1,TRIAL_DURATION*settings.sampRate); % mV
    out = injectionCommand * settings.daq.voltageConversionFactor; % send full command out, in Voltage for the daq to send
end


