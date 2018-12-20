function [err,x,fval,exitMessage,nrow,ncol] = optimguirun(hashProb, hashOpt)
%OPTIMGUIRUN Optimization Toolbox GUI 'Start' button callback function.
%   Two arguments 'hashProb' and 'hashOpt' are Java hash tables for 
%   problem model and options model respectively.
%   The output 'err' is the error string returned by either readOptimHashTable
%   or callSolver functions. x,fval,exitMessage are outputs from the solver
%   and [nrow,ncol] is the size of 'x' which is needed to display 'x' in the GUI. 

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:47:47 $

err = '';
x = '';
fval = '';
exitMessage = '';
% Size of the result vector 'X'
nrow = [];
ncol = [];
% Maximum length of 'X' vector to be shown in the GUI
MAX_NUM_ELEMENT_SHOW = 100;
% Get modified fields from the GUI
[probStruct,optStruct,errProb,errOpt] = readOptimHashTable(hashProb, hashOpt);
if ~isempty(errProb)
    err = errProb;
    return;
elseif ~isempty(errOpt)
    err = errOpt;
    return;
end
% We need to adjust 'OutputFcn' field so that 'optimtooloutput' function is
% called in every iteration. The GUI and solvers interact through the output 
% function 'optimtooloutput'.
if isempty(optStruct.OutputFcn)
    optStruct.OutputFcn = @optimtooloutput;
elseif iscell(optStruct.OutputFcn)
    % Add 'optimtooloutput' at the end of the array
    optStruct.OutputFcn{end+1} = @optimtooloutput;
else % Make it a cell
    optStruct.OutputFcn = {optStruct.OutputFcn};
    % Add 'optimtooloutput' as output function
    optStruct.OutputFcn{end+1} = @optimtooloutput;
end

lasterr('');
lastwarn(''); 
% Warnings are displayed in the GUI
warning off;
try
    % Call solver and save the result structure to MATLAB workspace (appdata)
    resultStruct = callSolver(probStruct,optStruct);
    setappdata(0,'optimTool_results_121677',resultStruct);
    exitMessage = resultStruct.output.message;
    x = resultStruct.x;
    
    % Set iteration number in the GUI
    optimGUI = com.mathworks.toolbox.optim.OptimGUI.getOptimGUI; % Get a handle to the GUI
    if ~isempty(optimGUI)
        optimGUI.setIteration(value2RHS(resultStruct.output.iterations)); % Update iteration number in the GUI
    end

    % Least square solvers have 'resnorm' and not 'fval'
    try
        fval = resultStruct.fval;
    catch
        fval = resultStruct.resnorm;
    end
    if ndims(x) < 3 && (isnumeric(x) || isa(x,'double')) && ...
            numel(x) <= MAX_NUM_ELEMENT_SHOW
        [nrow, ncol] = size(x);
    else
        nrow = -1;
        ncol = -1;
        x = [];
    end
catch
    nrow = -1;
    ncol = -1;
    x = [];
    err = lasterr;
end

