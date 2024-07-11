function [fullFileName, path, trialNum, idString] = getDataFileName(exptInfo)
%GETDATAFILENAME
%   [fullFileName, path] =  getDataFileName(prefixCode, expNum)
%
%   Returns the path and the path\fileName in which to store data. Format is:
%
%   path: \dataDirectory\prefixCode\expNum\YYMMDD\flyNum\flyExpNum\
%   filename: prefixCode_expNum_YYMMDD_flyNum_flyExpNum_nextSequentialNumber.mat
%       
%
%   JSB 3\22\2013

    prefixCode  = exptInfo.prefixCode;
    expNum      = exptInfo.expNum; 
    flyNum      = exptInfo.flyNum;
    cellNum     = exptInfo.cellNum;
    cellExpNum  = exptInfo.cellExpNum; 
    
    ephysSettings;   % Loads rigSettings
  
    % Make numbers strings
    eNum = num2str(expNum,'%03d');
    fNum = num2str(flyNum,'%03d');
    cNum = num2str(cellNum,'%03d');
    cENum = num2str(cellExpNum,'%03d');
    
    %make date number string
    format = 'yymmdd';  %YYMMDD format
    dateString = [ '_' datestr(now, format) ]; % today's date ie '_161014'
    
        % Put together path name and fileNamePreamble  
    path = [rigSettings.dataDirectory ,prefixCode,'\expNum',eNum,...
        '\flyNum',fNum, dateString, '\cellNum',cNum,'\','cellExpNum',cENum,'\'];
        
    fileNamePreamble = [prefixCode,'_expNum',eNum,...
        '_flyNum',fNum, dateString, '_cellNum',cNum,'_cellExpNum',cENum,'_trial'];
    
    idString = [prefixCode,'_expNum',eNum,...
        '_flyNum',fNum, dateString, '_cellNum',cNum,'_cellExpNum',cENum,'_'];

    
    % Determine trial number 
    trialNum = 1;
    while( size(dir([path,fileNamePreamble,num2str(trialNum,'%03d'),'.mat']),1) > 0)
        trialNum = trialNum + 1;
    end
    
    % Put together full file name 
    fullFileName = [path,fileNamePreamble,num2str(trialNum,'%03d'),'.mat'];