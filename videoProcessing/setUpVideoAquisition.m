function [ videoBool,  movieDirectoryGroupedVideo ] = setUpVideoAquisition( dirToSaveVideoIn , exptInfo)
%SETUPVIDEOAQUISITON Determines if video will be recorded for this experiment if so returns true and
% Gets the directory ready to hold video files and
%
%   Yvette Fisher 3/2017, updated 8/18
ephysSettings
videoFolderName = ['videoFolder_' exptInfo.prefixCode '_' exptInfo.dNum '_flyNum' num2str( exptInfo.flyNum ) '_cellNum' num2str( exptInfo.cellNum) '_expNum' num2str( exptInfo.cellExpNum) ]; 
% movieDirectoryFileName = [ dirToSaveVideoIn 'videoFolder\video' ];
movieDirectoryFileName = [ dirToSaveVideoIn videoFolderName '\video' ];
movieDirectoryGroupedVideo = [ dirToSaveVideoIn videoFolderName ];
clipboard('copy', movieDirectoryFileName)

prompt = ['Should fly-videos be aquired in this experiment?(y) Make sure camera is ON. ' ...
    ' \n Press *record button* then paste directory from system clipboard into *save Filename* section,' ...
    ' \n then press *Start Recording* !'];

%Ask the user if we are aquireing video in this experiment?
videoRecording = input( prompt, 's');
if strcmp(videoRecording,'y')
    
    videoBool =  true;
    %      % delete all files and directories from inside this tmp folder location
    %     rmdir( settings.rawVidDir, 's');
    %     mkdir( settings.rawVidDir );
else
    videoBool = false;
end

end

