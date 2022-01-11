function runExpt(prefixCode,expNum,stimSetType)
%RUNEXPT master function that runs the Ephy acquisition
%
% RUNEXPT('ExperimentName',expNUM,stimSetNum) runs an experiment with prefix
% code 'ExperimentName' and experiment number expNUM that uses the stimlulus
% specified by stimSetNum
%
% INPUTS
% prefixCode
% expNum
% stimsetNum - The name of the function containing the the stimSet you want to be run during this
% experiment:
% possible options include: 'currentInjections' and
%
% e.g. 'visualStimulus_v13'(panels code from Fisher et al. 2019 & 2021 used in Wilson Lab)
%
% OUTPUTS ----
%
% Example
% runExpt('test',1,'currentInjections')
% This would runs an experiment with a prefix code 'test'
% and experiment number 1 which means the data is saved in a
% folder called ~\Data\ephysData\test\expNum001
% The third input argument specifies the stimulus function/catagory you would like to
% use as a string. ie (currentInjections);


% open experimental settings
ephysSettings;
%% Get fly and experiment details from experimenter
newFly = input('New fly? ','s');
newCell = input('New cell? ','s');
[flyNum, cellNum, cellExpNum] = getFlyNum(prefixCode,expNum,newFly,newCell);


printVariable(flyNum, 'Fly Number');
printVariable(cellNum, 'Cell Number');
printVariable(cellExpNum, 'Cell Experiment Number');

%% Set meta data
exptInfo.prefixCode     = prefixCode;
exptInfo.expNum         = expNum;
exptInfo.flyNum         = flyNum;
exptInfo.cellNum        = cellNum;
exptInfo.cellExpNum     = cellExpNum;
exptInfo.dNum           = datestr(now,'YYmmDD');
exptInfo.exptStartTime  = datestr(now,'HH:MM:SS');
exptInfo.stimSetType     = stimSetType;

%% Get fly details
if strcmp(newFly,'y')
    %get details about this fly and save then in the data directory
    getFlyDetails(exptInfo)
end

%% Create preExptTrials folder and any parents, ie flyNum, cellNum, cellExpNum
[~, path, ~, ~] = getDataFileName(exptInfo);
path = [path,'\preExptTrials'];
if ~isdir(path)
    mkdir(path);
end

%% Run pre-expt routines (measure pipette resistance etc.)
contAns = input('Run preExptRoutine? ','s');
if strcmp(contAns,'y') || strcmp(contAns,'') 
    preExptData = preExptRoutine(exptInfo);
else
    preExptData = [];
end
%% Save Experimental Data ( ephysSettings,genotype + and seal test +)
    [~, path, ~, idString] = getDataFileName(exptInfo);
    settingsFileName = [path,idString,'exptData.mat'];
    save(settingsFileName,'settings','exptInfo','preExptData'); 

%% Run experiment with stimulus
contAns = input('\n Would you like to start the experiment? ','s');
if strcmp(contAns,'y')
    fprintf('**** Running Experiment ****\n')
    
    % run the stimlulus delivery function specified by the string of stimSetType
    eval([stimSetType,'(','exptInfo,','preExptData',')']);
    
end

%contA = input(' Would you like to measure access resistance again?');

% TODO: could be nice to add option here to measure parameters about the cell again!!
% perhaps this can have another name, other than preExpt data??? then
% another option to run more experiments again after that

end

%% Helper Functions
function printVariable(value, label)
fprintf([label, ' = ', num2str(value), '\n'])
end

