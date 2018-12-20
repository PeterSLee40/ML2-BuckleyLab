function err = optimguiGeneratemfile(hashProb,hashOpt)
%OPTIMGUIGENERATEMFILE generates an M-file from OPTIMTOOL.
%   hashProb and hashOpt are Java hash tables containing information about
%   the problem and options model. hashProb and hashOpt contain only information 
%   that user has changed since last time the data (Java model) from the GUI 
%   was passed to MATLAB workspace. (E.g. at the time of exporting, running,
%   generating code.) This function will update the MATLAB workspace and will 
%   call GenerateMfile.m to generate an M-file.
%
%   Private to OPTIMTOOL

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:47:43 $

err = '';
% Get modified fields from the GUI
[probStruct,optStruct,errProb,errOpt] = readOptimHashTable(hashProb, hashOpt);
if ~isempty(errProb)
    err = errProb;
    return;
elseif ~isempty(errOpt)
    err = errOpt;
    return;
end

% Generate M-file with for modified problem and options structure
GenerateMfile(probStruct,optStruct);
