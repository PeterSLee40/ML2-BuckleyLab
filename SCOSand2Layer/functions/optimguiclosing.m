function optimguiclosing()
%OPTIMGUICLOSING GUI helper function to clean up 'result' appdata from 
%   the MATLAB workspace when the GUI is closed.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:47:46 $

% Remove appdata structures used by optimtool
if isappdata(0,'optimTool_results_121677')
    rmappdata(0,'optimTool_results_121677');
end

if isappdata(0,'optimTool_Problem_HashTable')
    rmappdata(0,'optimTool_Problem_HashTable');
end

if isappdata(0,'optimTool_Options_HashTable')
    rmappdata(0,'optimTool_Options_HashTable');
end
