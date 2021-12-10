function [ cameraTriggerArray ] = createCameraTrigger( stimulus )
%CREATECAMERATRIGGER Builds an array to trigger when the camera should take
%frames using the cameraRate specified in ephysettings and the length of the trial.  
%   
%   Yvette Fisher 3/2017
ephysSettings;

 cameraTriggerArray = zeros( size ( stimulus.command ) ); % make camera trigger array same length as trial by comparining command
 
 frameInterval = round(settings.sampRate/settings.camRate); % find frame interval
 
 cameraTriggerArray(1:frameInterval:end) = 1; % set array to 1 on those intervals
 
end

