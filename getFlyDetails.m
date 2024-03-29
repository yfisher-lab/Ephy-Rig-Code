function FlyData = getFlyDetails(exptInfo,basename,varargin)
%{
GETFLYDETAILS Used in the case of a new fly to get information from the user about this
fly/experimental parameters/particulars of the dissection

INPUT
exptInfo
basename
-prompts user for additional information


OUTPUT

FlyData (struct)
.line (genotype/Gal4/effector...)
.freenessLeft
.freenessRight
.notesOnDissection
.prepType
.eclosionDate

All of these subfields are obtained from the user and saved
%}

%% Ask user for input
FlyData.line = input('Fly Line: ','s');
FlyData.notesOnDissection = input('Notes on dissection: ','s');
FlyData.prepType = input('Prep type: ','s');

% Get eclosion date using GUI calendar
h = uicontrol('Style', 'pushbutton', 'Position', [20 150 100 70]);
uicalendar('DestinationUI', {h, 'String'});
waitfor(h,'String'); 
FlyData.eclosionDate = get(h,'String');
display = append('Eclosion Date: ', FlyData.eclosionDate);
disp(display);
close all

%% Get filename
prefixCode  = exptInfo.prefixCode;
expNum      = exptInfo.expNum;
flyNum      = exptInfo.flyNum;

% Make numbers strings
eNum = num2str(expNum,'%03d');
fNum = num2str(flyNum,'%03d');

%make date number string
format = 'yymmdd';  %YYMMDD format
dateString = [ '_' datestr(now, format) ]; % today's date ie '_161014'

% calls ephysSettings to obtain the variable rigSettings.dataDirectory - yf
ephysSettings;

% save current ephySetting variables into FlyData for future reference
% FlyData.ephySettings.bob = settings.bob;
FlyData.ephySettings = rigSettings;

path = [rigSettings.dataDirectory,prefixCode,'\expNum',eNum,...
    '\flyNum',fNum, dateString];

if ~isfolder(path)
    mkdir(path)
end

if exist('basename','var')
    filename = [path,'\',basename,'flyData'];
else 
    filename = [path,'\flyData'];
end

%% Save
save(filename,'FlyData')
