function [] = frodoProtocols( exptInfo, preExptData )
%FRODOPROTOCOLS  function that runs experimental protocols written for rig
%frodo in 135
% the user is prompted with all the optional protocols to run. 
% Yvette Fisher 1/2022

while 1
    ephysSettings;

    % get user to pick wanted stimulus
    GETSTIMULUSNAME = true;
    while(GETSTIMULUSNAME)
        
        prompt = ['Which stimulus would you like to run? Options: TODO enter options here  n=exit: '];
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