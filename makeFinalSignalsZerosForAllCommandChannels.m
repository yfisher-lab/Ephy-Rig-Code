function [ outCommand ] = makeFinalSignalsZerosForAllCommandChannels( inCommand )
%MAKEFINALSIGNALSZEROFORALLCOMMANDCHANNELS 
% make the final NUMOFZERO elements at the end of all the channels in inCommand matrix be zero to ensure
% that at the end of a readwrite session that output returns to zero volts
%
% INPUT - inCommand - scan data as an MxN double matrix, where M is the number of scans and N is the number of output channels.
% OUTPUT - outCommand = MxN matrix with final NUMOFZEROS values zero for
% all M scan channels
% 
% Yvette Fisher 1/2022
NUMOFZEROS = 10;

outCommand = inCommand;

outCommand(end-NUMOFZEROS:end,:) = 0;
end