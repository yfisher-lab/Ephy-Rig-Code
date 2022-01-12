function [  ] = zipVideoDirectoryFolder( exptInfo, groupedVideoFolderName )
%ZIPVIDEODIRECTORYFOLDER Created a zipped folder containing all the video
%trial folders and then delete the unzipped folder
% Yvette Fisher 2/2018
contAns = input('\n Would you like to zip the video folder?  Please PAUSE DROPBOX & this could take some time...','s');
if strcmp(contAns,'y')
    
    ephysSettings;
    
    % create zip of video folder name
    %zipGroupedVideoFolderName = [path,'videoFolderCompressed','.zip' ];
    zipGroupedVideoFolderName = [groupedVideoFolderName,'.zip' ];
    
    %groupedVideoFolderName = [path,'videoFolder' ];
    try
        tic; % keep timing logged....
        
        zip( zipGroupedVideoFolderName, groupedVideoFolderName);
        
        toc % timing check
        %
        disp('SUCCESS: Video folder was zipped!');
        
        cd( path );
        % CHECK that this actually works - and does not also remove the
        % zipped folder!!  DROPBOX error?
        rmdir( groupedVideoFolderName, 's');
        
        toc % check timing of this processes
        disp('SUCCESS: unzipped Video folder was deleted!');
        
    catch
        disp('WARNING:Video folder zipped/deleting process was not fully completed');
    end
    
end

