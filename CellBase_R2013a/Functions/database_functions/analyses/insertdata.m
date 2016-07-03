function varargout = insertdata(varargin)%INSERTDATA   Insert data into CellBase directly.%   NF = INSERTDATA(DATA,PARAM,VALUE) inserts DATA into TheMatrix%   and ANALYSES (see CellBase documentation). It optionally returns the%   list of entries in DATA which did not provide a match with CELLIDLIST%   (NF).%   Input arguments:%       DATA - Either a Matlab variable or a full pathname to a .mat or an%           Excel file. It can optionally contain a header row with%           'property_names' in the first column and corresponding property%           names for data columns. First column should contain cellIDs. If%           property names are added as both input argument and data%           header, the user is forced to choose which one to use.%       'TYPE', T - Parameter indicating whether an analysis or a set of%           properties are added. T should start with the letter 'a' or 'p'%           accordingly.%       'NAME', NM - Name of the analysis or properti(es). For analysis: %           it should be the name of a valid m file. For properties: either%           a character array (one property) or a cell array of strings%           (multiple properties).%       'INPUT_ARGUMENTS', LS1 - Input arguments for analysis, cell array.%       'OUTPUT_ARGUMENTS', LS2 - Names of output arguments for analysis, %           cell array of strings. This determines the property names when%           an analysis is added.%%   The number of properties or output arguments (in case of adding values%   to an analysis) must match the number of data columns (number of all%   columns minus one) in DATA.%%   Missing input arguments are asked for interactively. If DATA is empty,%   the user has to browse for the data file. If 'Cancel' is selected for%   browsing result, data values will interactively be prompted for%   according to a selected tag type (animal, session, tetrode or cell).%%   If a property or an analysis is already added to CellBase, the user is%   asked whether to overwrite previous data. An analysis is only%   considered the same if the name of the m file and both the list of %   input and output arguments are the same. If the data is overwritten,%   the timestamp property in ANALYSES is updated.%%   New data is inserted into TheMatrix and ANALYSES according to the%   corresponding cellIDs. A backup of the previous cellbase file is stored%   before overwriting.%%   Examples:%   insertdata(data,'type','analysis','name','LRatio','input_arguments',...%       {{'Amplitude','Energy'}},'output_arguments',{'ID_amp','Lr_amp'})%   not_found = insertdata([],'type','prop','name','validity');%   insertdata('c:\Balazs\_analysis\NB\tagging\validity.xls','type',...%       'prop','name','validity')%   insertdata('c:\Balazs\_analysis\NB\tagging2\spikeshapecorr.xls','type',...%       'analysis','name','spikeshapecorr')%%   See also ADDANALYSIS and RUNANALYSIS.%   Edit log: AK,SPR 5/10; BH 5/3/12% Input argumentsprs = inputParser;addOptional(prs,'data',[],@(s)isempty(s)||iscell(s)||ischar(s))addParamValue(prs,'type','',@(s)ismember(s(1),{'p','a'})) % property or analysisaddParamValue(prs,'name',{},@(s)ischar(s)||iscell(s))  % name of properties or analysis functionaddParamValue(prs,'input_arguments',{},@iscell) % name of input arguments for analysis functionaddParamValue(prs,'output_arguments',{},@(s)ischar(s)||iscell(s)) % name of output arguments for analysis function - used for proporty names if type=analysisparse(prs,varargin{:})g = prs.Results;% If no options specified, ask everything% Property or analysis?if isempty(g.type)    pora = '';    while ~ismember(pora,{'p','a'})        pora = input('\n Do you want to insert a property or an analysis? p/a ','s');    endelse    pora = g.type(1);end% Property names or mfile nameswitch pora    case 'p'    % property names        if isempty(g.name)            tinp = input('\n Please enter the property names you want to add. ','s');            propnames = strread(tinp,'%s','delimiter',', ')';        else            propnames = g.name;        end        if ischar(propnames) % convert to cell if there's only one property            propnames = {propnames};        end        funhandle = @insertdata;    % for properties, the function handle is 'insertdata'        arglist = {};   % a property does not have arguments                         % (except for manually entered properties, where it is the 'option', see below)                case 'a'    % mfile name        if isempty(g.name)            wi = 0;            while ~wi                mfile = input('\n Please enter the name of the analysis function. ','s');                funhandle = str2func(mfile);    % check analysis function                funinfo = functions(funhandle);                if ~isempty(funinfo.file)                    fprintf('\n%s\n','Analysis file was loacated: ')                    disp(funinfo.file)                    wi = 1;                else                    fprintf('\n%s\n','INSERTDATA: Function is not valid.')                end            end        else            mfile = g.name;            funhandle = str2func(mfile);        end        if isempty(g.input_arguments)     % mfile input arguments            tinp = input(['\n Please enter the list of input arguments for '...                mfile ',\n or press Enter for no arguments. ']);            arglist = tinp;        else            arglist = g.input_arguments;        end        if isempty(g.output_arguments)     % mfile output arguments (properties)            tinp = input(['\n Please enter the list of output arguments for '...                mfile '. '],'s');            propnames = strread(tinp,'%s','delimiter',', ')';        else            propnames = g.output_arguments;        end        if ischar(propnames) % convert to cell if there's only one output argument            propnames = {propnames};        endend% Load dataif isempty(g.data)    [filename, pathname] = uigetfile( ...        {'*.mat;*.xls;*.xlsx','Supported formats (*.mat,*.xls,*.xlsx)';...        '*.mat','MAT-files (*.mat)'; ...        '*.xls;*.xlsx','Excel files (*.xls,*.xlsx)'; ...        '*.*',  'All Files (*.*)'}, ...        'Select Datafile');     % select data file    fullpth = fullfile(pathname,filename);    vardata = read_data(fullpth);else    if ischar(g.data)        vardata = read_data(g.data);    else        vardata = g.data;    endend% Load CellBaseload(getpref('cellbase','fname'));% Check dataif ~isempty(vardata)    if isequal(vardata{1,1},'property_names')   % property names in data header        newpropnames = vardata(1,2:end);        vardata = vardata(2:end,:);        if isempty(propnames)            propnames = newpropnames;            fprintf('\n%s','Using property names detected in data header:')            disp(propnames)        end        if ~isequal(propnames,newpropnames)   % optionally overwrite input argument with header            useheader = input('\nUse property/argument names of data header? (y/n) ','s');            while ~ismember(useheader,{'y','n'})                useheader = input('\nUse property/argument names of data header? (y/n) ','s');            end            if isequal(useheader,'y')                propnames = newpropnames;                fprintf('\n%s','Using property names detected in data header:')                disp(propnames)            end        end    end    infinx = cellfun(@(s)isequal('Inf',s),vardata);    % convert 'Inf' to Inf    vardata(infinx) = {Inf};    infinx = cellfun(@(s)isequal('-Inf',s),vardata);    vardata(infinx) = {-Inf};    naninx = cellfun(@(s)isequal('NaN',s),vardata);   % convert 'NaN' to NaN    vardata(naninx) = {NaN};    if ~isequal(length(propnames),size(vardata,2)-1)        error('INSERTDATA: Data does not match the number of properties.')    endend% If no data, add values one by oneif isempty(vardata)    option = input(['\nYou will be prompted to add values manually. \n'...        'Would you like to add separate value for each \n'...        'animal/session/tetrode/cell? '],'s');    if ~(strncmp(option,'ani',3) || strncmp(option,'rat',3) || ...            strncmp(option,'ses',3) || strncmp(option,'tet',3) || ...            strncmp(option,'cel',3))        error('INSERTDATA: unknown option.');    else        arglist = {option};     % store the chosen option in the argument field    end        % Add values for each properties    vardata = {};  % initalize    for prp = 1:length(propnames)        propname = propnames{prp};        lastcellpos = 0;                % Create list to display        list = listtag(option);      % find all relevant cell classes        if strncmp(option,'session',3)            list2add = strcat(char(list(:,1)),'_',char(list(:,2)));        elseif strncmp(option,'tetrode',3)            list2add = strcat(char(list(:,1)),'_',char(list(:,2)),'_',char(list(:,3)));        else  % option = rat or cell            list2add = char(list);        end                % Type values        fprintf('\n%s%s%s\n','Insert values for ',propname,'.')        for i = 1:size(list2add,1)            value = prompt_for_value(list2add(i,:));            if strncmp(option,'session',3)                pos = findcellpos('rat',list(i,1),'session',list(i,2));            elseif strncmp(option,'tetrode',3)                pos = findcellpos('rat',list(i,1),'session',list(i,2),'tetrode',list(i,3));            elseif strncmp(option,'rat',3)                pos = findcellpos('rat',list(i));            elseif strncmp(option,'animal',3)                pos = findcellpos('animal',list(i));            else                pos = findcellpos(list(i));            end                        cells2add = CELLIDLIST(pos);  % add cellid and value for each new cell            nws = length(cells2add);            vardata(lastcellpos+1:lastcellpos+nws,1)=cells2add';            vardata(lastcellpos+1:lastcellpos+nws,prp+1)={value}; %#ok<AGROW>            lastcellpos = lastcellpos + nws;        end    endend% Time stamptimestamp = {gettimestamp};% Insert data% Find the position to insert toNumCol = length(propnames);NumCell = size(vardata,1);NumAnal = length(ANALYSES);  %#ok<NODEF>if NumAnal == 0    lastcolumn = 0;else    lastcolumn = ANALYSES(NumAnal).columns(end);endcolumns = lastcolumn+1:lastcolumn+NumCol;isoverwrite = false;    % changed later if previous data is overwritten% Add to ANALYSESswitch pora    case 'p'   % properties are added one by one        for i = 1:NumCol            [prevanal anum] = findanalysis(propnames{i});            if prevanal  % give an option to overwrite                str = sprintf('\nINSERTDATA: Analysis already exists for %s at position %d.',propnames{i},prevanal);                disp(str)                co = input('Overwrite previous data? overwrite/cancel [c] ','s');                if ~strncmp(co,'overwrite',4)                    fprintf('\n%s\n','INSERTDATA: Action cancelled. No data inserted.')                    return                end                columns(i) = prevanal;                ANALYSES(anum(1)).timestamp = timestamp; %#ok<AGROW>                ANALYSES(anum(1)).varargin = arglist; %#ok<AGROW>            else                ANALYSES(NumAnal+i).funhandle = funhandle; %#ok<AGROW>                ANALYSES(NumAnal+i).varargin = arglist; %#ok<AGROW>                ANALYSES(NumAnal+i).propnames = propnames(i); %#ok<AGROW>                ANALYSES(NumAnal+i).columns = columns(i); %#ok<AGROW>                ANALYSES(NumAnal+i).timestamp = timestamp; %#ok<AGROW>            end        end            case 'a'    % output arguments of an analysis are added as a single entry        [cols anum] = findanalysis(funhandle);        mts = length(anum);   % multiple matches with different arguments are possible        isfound = nan(1:mts);        for aa = 1:mts            isfound(aa) = ~isequal(cols,0) & isequal(ANALYSES(anum(aa)).varargin,arglist)...                & isequal(ANALYSES(anum(aa)).propnames,propnames); % consider the same if the analysis name, input and output parameters are the same        end        if any(isfound)  % give an option to overwrite            anum = anum(logical(isfound));            columns = ANALYSES(anum).columns;            str = sprintf('\nINSERTDATA: Analysis already exists at position %d.',cols);            disp(str)            co = input('Overwrite previous data? overwrite/cancel [c] ','s');            if ~strncmp(co,'overwrite',4)                fprintf('\n%s\n','INSERTDATA: Action cancelled. No data inserted.')                return            else                isoverwrite = true;            end            ANALYSES(anum).timestamp = timestamp;        else            ANALYSES(NumAnal+1).funhandle = funhandle;            ANALYSES(NumAnal+1).varargin = arglist;            ANALYSES(NumAnal+1).propnames = propnames;            ANALYSES(NumAnal+1).columns = columns;            ANALYSES(NumAnal+1).timestamp = timestamp;        endend% Add to TheMatrix[cmn inxa inxb] = intersect(CELLIDLIST,vardata(:,1)); %#ok<*ASGLU>if iscell(TheMatrix) %#ok<NODEF>    TheMatrix(inxa,columns) = vardata(inxb,2:end);   % TheMatrix is a cell in the updated CellBaseelse    if ~isoverwrite        TheMatrix(:,columns) = NaN;   % initialize with NaNs to avoid padding with zeros    end    TheMatrix(inxa,columns) = cell2mat(vardata(inxb,2:end));  % keep it compatible with the old versionendnotfound_list = setdiff(vardata(:,1),CELLIDLIST);NotFound = length(notfound_list);% Return changed variables to workspace & save allassignin('base','TheMatrix',TheMatrix)assignin('base','ANALYSES',ANALYSES)cb = getpref('cellbase','fname');[pth fnm ext] = fileparts(cb);dsr = datestr(now);dsr = regexprep(dsr,':','_');backup_name = fullfile(pth,[fnm '_' dsr ext]);copyfile(cb,backup_name)    % make backup before overwritingsave(cb,'TheMatrix','ANALYSES','CELLIDLIST')% Feedbackif NotFound    donestr = sprintf('INSERTDATA done.\nData added to %d cells creating/updating %d properti(es).\n %d cellids not found.\n',NumCell,NumCol,NotFound);else    donestr = sprintf('INSERTDATA done.\nData added to %d cells creating/updating %d properti(es).\n',NumCell,NumCol);enddisp(donestr);if nargout > 0    varargout{1} = notfound_list;end% -------------------------------------------------------------------------function value = prompt_for_value(tag,varargin)value = [];question = sprintf('Enter value for %s    ',tag);if nargin == 1	while isempty(value)        value = input(question);	endelseif strcmpi(varargin{1},'NaN')    value = input(question);    if isempty(value)        value = NaN;    end   end% -------------------------------------------------------------------------function  ts = gettimestamp% Nowc = clock;ts = sprintf('%d/%d/%d %.2d:%.2d',c(2),c(3),c(1),c(4),c(5));% -------------------------------------------------------------------------function vardata = read_data(fullpth)% Decompose path name[pth fnm ext] = fileparts(fullpth);% Read the data for supported formatsswitch ext    case {'.xls' '.xlsx'}        [t0 t1 vardata] = xlsread(fullpth);     % Excel    case '.mat'        pvd = load(fullpth);    % Matlab        fld = fieldnames(pvd);        vardata = pvd.(fld{1});    otherwise        vardata = [];end