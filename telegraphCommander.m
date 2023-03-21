function [ampMeta] = telegraphCommander()

% TELEGRAPH COMMANDER uses MultiClamp700B.m wrapper from Stephen Holtz to
% create a structure containing the MultiClamp 700B Commander software
% configuration information
% 
% OUTPUT
% ampMeta = struct that contains information about the configuration for 
% the MultiClamp700B Commander software

MC = MultiClamp700B();
MC.initalize;
ampMeta = MC.getState();

end