function  exportopt2wsdlg(hashProb, hashOpt)
%exportopt2wsdlg exports variables from optimtool to workspace. 
%   Possible variables are 'problem', 'options', and 'results' structures. This 
%   function presents a dialog with choices for exporting any or all of the three 
%   above structures. It also creates variables in MATLAB workspace. The output 'err' 
%   will be a non-empty string (containing error message, if any) when there is any 
%   error in reading 'hashProb' and 'hashOpt'.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/15 19:29:00 $

% Title for the dialog
title = 'Export To Workspace';
% Properties of the dialog
hDialog = dialog('Visible', 'off', 'Name', title, 'WindowStyle', 'normal');
% Default variable names for the structures to be exported
defaultVariableNames = {'optimproblem'; 'options'; 'optimresults'};
variableNames = createVarNames(defaultVariableNames);
% Cancel button for the dialog
cancelButton = uicontrol(hDialog,'String', 'Cancel',...
                                 'Callback', {@CancelCallback, hDialog});
% OK button for the dialog                             
okButton = uicontrol(hDialog,'String', 'OK', 'Fontweight', 'bold');
% Labels for choices given in the dialog
checkboxLabels = {'Export problem and options to a MATLAB structure named:'; ...
                  'Export options to a MATLAB structure named:';...
                  'Export results to a MATLAB structure named:'};
        
% Retrieve problem and options structure from the Java hash table
[probStruct,optStruct] = readOptimHashTable(hashProb, hashOpt);

% Retrieve results strcuture from the workspace and check if it exists
disableFields = true;
resultStruct = getappdata(0,'optimTool_results_121677');
% If results structure does not exist then disable the 'Export results...' choice
if ~isempty(resultStruct)
    disableFields = false; 
end

% Call the function to layout the dialog box
[checkBoxes, editFields] = layoutDialog(hDialog, okButton, cancelButton, ...
                                        checkboxLabels, variableNames,disableFields);
% Set callback function for 'OK' button
set(okButton, 'Callback', {@OKCallback, hDialog, checkBoxes, editFields, ...
                           optStruct, probStruct,resultStruct});
% Set callback function for keyboard responses
set(hDialog, 'KeyPressFcn', {@KeyPressCallback, hDialog, checkBoxes, editFields, ...
                           optStruct, probStruct,resultStruct});
% Show dialog now!
set(hDialog, 'Visible', 'on');

%----------------------------------------------------------------------------
function modifiedNames = createVarNames(defVariableNames)
    % Preallocating for speed
    modifiedNames = cell(1, length(defVariableNames));
    for i = 1:length(defVariableNames)
        modifiedNames{i} = computename(defVariableNames{i});
    end

%----------------------------------------------------------------------------
function name = computename(nameprefix)

if (evalin('base',['exist(''', nameprefix,''', ''var'');']) == 0)
    name = nameprefix;
    return
end

% get all names that start with prefix in workspace
workvars = evalin('base', ['char(who(''',nameprefix,'*''))']);
% trim off prefix name
workvars = workvars(:,length(nameprefix)+1:end); 

if ~isempty(workvars)
    % remove all names with suffixes that are "non-numeric"
    lessthanzero = workvars < '0';
    morethannine = workvars > '9';
    notblank = (workvars ~= ' ');
    notnumrows = any((notblank & (lessthanzero | morethannine)),2);
    workvars(notnumrows,:) = [];
end

% find the "next one"
if isempty(workvars)
    name = [nameprefix, '1'];
else
    nextone = max(str2num(workvars)) + 1;
    if isempty(nextone)
        name = [nameprefix, '1'];
    else
        name = [nameprefix, num2str(nextone)];
    end
end

%----------------------------------------------------------------------------
function OKCallback(obj, eventdata, dialog, cb, e, optStruct, probStruct,resultStruct)

    CB_PROBLEM = 1;
    CB_OPTION = 2;
    CB_RESULTS = 3;
    
    varnames = [];
    
     % we care only about items that are checked
     for i = 1:length(e)
         if get(cb{i}, 'Value') == 1
            varnames{end + 1} = get(e{i}, 'String');
         end
     end
    
     if isempty(varnames)
         errordlg('You must select an item to export', ...
                  'Export to Workspace');
         return;
     end
    
    %check for invalid and empty variable names
    badnames = [];
    numbadentries = 0;
    emptystrmsg = '';
    badnamemsg = '';
    for i = 1:length(varnames)
        if strcmp('', varnames{i})
            numbadentries = numbadentries + 1;
            emptystrmsg = sprintf('%s\n', ...
                'An empty string is not a valid choice for a variable name.');
        elseif ~isvarname(varnames{i})
            badnames{end + 1} = varnames{i};
            numbadentries = numbadentries + 1;
        end
    end
    badnames = unique(badnames);
   
    if ~isempty(badnames)
        if (length(badnames) == 1)
            badnamemsg = ['"' badnames{1} '"' ...
                      ' is not a valid MATLAB variable name.'];
        elseif (length(badnames) == 2)
            badnamemsg = ['"' badnames{1} '" and "' badnames{2} ...
                      '" are not valid MATLAB variable names.'];
        else 
            badnamemsg = [sprintf('"%s", ', badnames{1:end-2}),...
                      '"' badnames{end-1} ...
                      '" and "' badnames{end} ...
                      '" are not valid MATLAB variable names.', ];
        end
    end
    
    if numbadentries > 0 
        dialogname = 'Invalid variable names';
        if numbadentries == 1
            dialogname = 'Invalid variable name';
        end
        errordlg([emptystrmsg badnamemsg], dialogname);    
        return; 
    end
    
    %check for names already in the workspace
    dupnames = [];
    for i = 1:length(varnames)
        if evalin('base',['exist(''',varnames{i},''', ''var'');'])
            dupnames{end + 1} = varnames{i};
        end
    end
    dupnames = unique(dupnames);
 
    if ~isempty(dupnames) 
        dialogname = 'Duplicate variable names';
        if (length(dupnames) == 1)
            queststr = ['"' dupnames{1} '"'...
                        ' already exists. Do you want to overwrite it?'];
            dialogname = 'Duplicate variable name';
        elseif (length(dupnames) == 2)
            queststr = ['"' dupnames{1} '" and "' dupnames{2} ...
                        '" already exist. Do you want to overwrite them?'];
        else
            queststr = [sprintf('"%s" , ', dupnames{1:end-2}), ...
                        '"' dupnames{end-1} '" and "' dupnames{end} ...
                        '" already exist. Do you want to overwrite them?'];
        end
        buttonName = questdlg(queststr, dialogname, 'Yes', 'No', 'Yes');
        if ~strcmp(buttonName, 'Yes') 
            return;
        end 
    end

    %Check for variable names repeated in the dialog edit fields
    [uniqueArray ignore uniqueIndex] = unique(varnames);
    if length(varnames) == length(uniqueArray)
        if get(cb{CB_PROBLEM}, 'Value') == 1  % Export problem structure
            % Input argument 'probStruct' is modified so that it contains only fields relevant
            % to the solver 'probStruct.solver'
            probStruct = createProblemStruct(probStruct.solver,[],probStruct);
            probStruct.options = optStruct;
            assignin('base', get(e{CB_PROBLEM}, 'String'), probStruct);
        end
        if get(cb{CB_OPTION}, 'Value') == 1   % Export options structure
            assignin('base', get(e{CB_OPTION}, 'String'), optStruct);
        end
        if get(cb{CB_RESULTS}, 'Value') == 1  % export result structure
            assignin('base', get(e{CB_RESULTS}, 'String'), resultStruct); 
        end
        if length(varnames) == 1
            msg = sprintf('The variable ''%s'' has been created in the current workspace.', varnames{1});
        elseif length(varnames) == 2 
            msg = sprintf('The variables ''%s'' and ''%s'' have been created in the current workspace.', varnames{1}, varnames{2});
        elseif length(varnames) == 3
            msg = sprintf('The variables ''%s'', ''%s'' and ''%s'' have been created in the current workspace.', varnames{1}, varnames{2}, varnames{3});
        else  %shouldn't get here
            msg='';
        end
        disp(msg);
        delete(dialog);
    else
        errordlg('Names must be unique', 'Invalid Names');
    end
 
%----------------------------------------------------------------------------
function CancelCallback(obj, eventdata, dialog)
    delete(dialog);
   
%----------------------------------------------------------------------------
function KeyPressCallback(obj, eventdata, dialog, cb, e, optStruct, probStruct,resultStruct)
% This functon is a callback for reponse from keyboard instead of mouse (a wrapper around 
% 'OKCallback' function)
    asciiVal = get(dialog, 'CurrentCharacter');
    if ~isempty(asciiVal)
        % space bar or return is the "same" as OK
        if (asciiVal==32 || asciiVal==13)   
            OKCallback(obj, eventdata, dialog, cb, e, optStruct, probStruct,resultStruct);
        elseif (asciiVal == 27) % Escape has the same effect as Cancel
            delete(dialog);
        end
    end
   
%----------------------------------------------------------------------------
function [cb, e] = layoutDialog(hDlg, okBut, cancelBut, checkboxLabels, ...
                                variableNames,disableFields)
% Dialog position and other properties are set in this function

    EXTENT_WIDTH_INDEX = 3;  % width is the third argument of extent
    
    POS_X_INDEX      = 1;
    POS_Y_INDEX      = 2;
    POS_WIDTH_INDEX  = 3;
    POS_HEIGHT_INDEX = 4;
    
    CONTROL_SPACING  = 5;
    EDIT_WIDTH       = 90;
    CHECK_BOX_WIDTH  = 20;
    DEFAULT_INDENT   = 20;
    
    CB_PROBLEM = 1;
    CB_OPTION = 2;
    CB_RESULTS = 3;
    
    okPos = get(okBut, 'Position');
    cancelPos = get(cancelBut, 'Position');
    longestCBExtent = 0;
    ypos = okPos(POS_HEIGHT_INDEX) + okPos(POS_Y_INDEX)+ 2*CONTROL_SPACING;
    cb = cell(3, 1);
    e = cell(3, 1);
    for i = 3:-1:1
        cb{i} = uicontrol(hDlg, 'Style', 'checkbox', 'String', ...
                          checkboxLabels{i});
        check_pos = get(cb{i}, 'Position');
        check_pos(POS_Y_INDEX) = ypos;
        extent = get(cb{i}, 'Extent');
        width = extent(EXTENT_WIDTH_INDEX);
        check_pos(POS_WIDTH_INDEX) = width + CHECK_BOX_WIDTH;  
        set(cb{i}, 'Position', check_pos);
        e{i} = uicontrol(hDlg, 'Style', 'edit', 'String', variableNames{i}, ...
            'BackgroundColor', 'white', ...
            'HorizontalAlignment', 'left');
        edit_pos = get(e{i}, 'Position');
        edit_pos(POS_Y_INDEX) = ypos;
        edit_pos(POS_WIDTH_INDEX) = EDIT_WIDTH;
        % cursor doesn't seem to appear in default edit height
        edit_pos(POS_HEIGHT_INDEX) = edit_pos(POS_HEIGHT_INDEX) + 1;
        set(e{i}, 'Position', edit_pos);
        ypos = ypos + CONTROL_SPACING + edit_pos(POS_HEIGHT_INDEX);
        if width > longestCBExtent
            longestCBExtent = width;
        end
        
        if disableFields
            set(cb{CB_RESULTS}, 'Enable', 'off');
            set(e{CB_RESULTS}, 'Enable', 'off');
            set(e{CB_RESULTS}, 'Backgroundcolor', [0.831373 0.815686 0.784314]);
            if strcmp(get(cb{CB_PROBLEM}, 'Enable'), 'off')  % only options is enabled - check it
                set(cb{CB_OPTION}, 'Value', 1);
            end
        end
    end

    % Position edit boxes
    edit_x_pos = check_pos(POS_X_INDEX) + longestCBExtent + CONTROL_SPACING ...
                           + CHECK_BOX_WIDTH;
    for i = 1:3
        edit_pos = get(e{i}, 'Position');
        edit_pos(POS_X_INDEX) = edit_x_pos;
        set(e{i}, 'Position', edit_pos);
    end
    h_pos = get(hDlg, 'Position');
    
    h_pos(POS_WIDTH_INDEX) = max(edit_x_pos + edit_pos(POS_WIDTH_INDEX) + ...
                                 CHECK_BOX_WIDTH, okPos(POS_WIDTH_INDEX) + ...
                                 cancelPos(POS_WIDTH_INDEX) + ...
                                 CONTROL_SPACING + (2 * DEFAULT_INDENT));
    h_pos(POS_HEIGHT_INDEX) = ypos;
    set(hDlg, 'Position', h_pos);
    
    % Make sure it is on-screen
    oldu = get(0,'Units');
    set(0,'Units','pixels');
    screenSize = get(0,'ScreenSize');
    set(0,'Units',oldu);
    outerPos = get(hDlg,'OuterPosition');
    if outerPos(1)+outerPos(3) > screenSize(3)
        outerPos(1) = screenSize(3) - outerPos(3);
    end
    if outerPos(2)+outerPos(4) > screenSize(4)
        outerPos(2) = screenSize(4) - outerPos(4);
    end
    set(hDlg, 'OuterPosition', outerPos);
    
    x_ok = (h_pos(POS_WIDTH_INDEX))/2 -  (okPos(POS_WIDTH_INDEX) + ... 
            CONTROL_SPACING + cancelPos(POS_WIDTH_INDEX))/2;
    okPos(POS_X_INDEX) = x_ok;
    set(okBut, 'Position', okPos);
    cancelPos(POS_X_INDEX) = okPos(POS_X_INDEX) + okPos(POS_WIDTH_INDEX) + ...
                                   CONTROL_SPACING;
    set(cancelBut, 'Position', cancelPos);

    % Reorder the children so that tabbing makes sense
    children = get(hDlg, 'children');
    children = flipud(children);
    set(hDlg, 'children', children);
