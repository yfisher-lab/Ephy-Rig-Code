function [ampMeta] = telegraphCommander( varargin )

% TELEGRAPH COMMANDER uses MultiClamp700B.m wrapper from Stephen Holtz to
% create a structure containing the MultiClamp 700B Commander software
% configuration information
%
% OUTPUT
% ampMeta = struct that contains information about the configuration for 
% the MultiClamp700B Commander software


MC = MultiClamp700B();

%set serial number to argument, else set to serialnumber inMultiClamp770b.m
if (nargin == 1)
    MC.serial_number = varargin{1};
end

MC.initalize;
ampMeta = MC.getState();

end