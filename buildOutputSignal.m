function [out] = buildOutputSignal(name,output)
%BUILDOUTPUTSIGNAL build a signal that will set sent as a nidaq output and
% obtain information about daq settings and channel to send to from
% EphySettings
%
% INPUTS
% name - string that is the name out the type of output - this must be a
% signal that is annonated in ephySettings
% output - array that contains the data set to be used
%
% OUTPUT
% out.[name].measurementType e.g. "Voltage" or "Digital"
% out.[name].channelID e.g. 'ao0' or "port0/line0"
% out.[name]
% out.output = output array that will be sent to the nidaq
%
%   Yvette Fisher 6/2022
ephysSettings;

% check ephysetting variables for the infromation about where these signals
% should be sent on the nidaq, if can't find throw an error...
if ~isfield(rigSettings, name)
    error('Error: The requested output name is not currently specifized with daq channelID and needed infromation in the ephySettings script')
end

% store infromation about the daq output channel and measurementType
out.measurementType = rigSettings.(name).measurementType;
out.channelID = rigSettings.(name).channelID;
out.name = name;
out.output = output;

end