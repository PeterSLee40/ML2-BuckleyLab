function [selection, problemModel, optionModel] = optimguiImportProblem()
%optimguiImportProblem Optimtool helper function to import problem structure. 
% It presents a list dialog to the user. The dialog contains list of valid optim 
% problem structures. This function saves the problem and options structure (which 
% is a field of problem structure) to the MATLAB workspace and also returns the 
% equivalent Java hash tables 'problemModel' and 'optionModel' to the GUI. The name 
% of the selected variable 'selection' to be imported is also returned to the GUI.
%
%   Private to OPTIMTOOL

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/05/23 18:59:14 $


selection = '';
optionModel = '';
problemModel = '';
names = {};
optionsFieldnames = fieldnames(optimset);
% We check for five matching fields (to make sure that MATLAB optimization
% solvers get through this test)
minNumberOfOptionsToCheck = 5; % Display, MaxFunEvals, MaxIter, TolX, and TolFun.

probFieldnames = fieldnames(createProblemStruct('all',[]));
% Required field names for problem structure
requiredFields = {'solver','options'};
validValues    =  {fieldnames(createProblemStruct('solvers')), {} };

whoslist =evalin('base','whos');
for i = 1:length(whoslist)
    if strcmp(whoslist(i).class, 'struct') && strcmp(num2str(whoslist(i).size), '1  1')
        s = evalin('base', whoslist(i).name);
        if validProblem(s,requiredFields,validValues) && ...
                validOptions(s.options,optionsFieldnames,minNumberOfOptionsToCheck)
            names{end + 1} = whoslist(i).name;
        end
    end
end
   
if isempty(names) 
    msgbox('There are no problem structures in the workspace.', 'Optimization Tool');
else
    [selectionIndex, Answer] = listdlg('ListString', names, 'SelectionMode', 'Single', ...
            'ListSize', [250 200], 'Name', 'Import Optimization Problem', ...
            'PromptString', 'Select a problem structure to import:', ...
            'OKString', 'Import');
    % Answer == 1 means that user pressed the 'Import' button
    if Answer == 1
        selection = names{selectionIndex};
        probStruct = evalin('base', selection);
        options = probStruct.options; probStruct = rmfield(probStruct,'options');
        % Stuff all the fields into the hashtable.
        problemModel = createHashTable(probStruct,probFieldnames,selection); % Create Java hashtable
        optionModel = createHashTable(options,optionsFieldnames,[selection,'.options']);
        % Save problem and options to the MATLAB workspace (appdata)
        setappdata(0,'optimTool_Problem_Data',probStruct);
        setappdata(0,'optimTool_Options_Data',options);
     end
end    

% Reset Java hashtable for options and problem change
resetOptimtoolHashTable('optimTool_Problem_HashTable');
resetOptimtoolHashTable('optimTool_Options_HashTable');

