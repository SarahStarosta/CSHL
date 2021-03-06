function TE = makeTE_SO_RewardPunish_Odor_v2(sessions)

    if nargin < 1
        sessions = bpLoadSessions;
    end
    
    % find total number of trials acrosss selected sesssions
    scounter = zeros(size(sessions));
    for i = 1:length(sessions)
        scounter(i) = sessions(i).SessionData.nTrials;
    end
    nTrials = sum(scounter);
    statesToAdd= {'ITI', 'PreCsRecording', 'Cue', 'Delay', 'Reward', 'Punish', 'Omit', 'PostUsRecording'};

    %% initialize TE
    TE = struct(...
        'filename', {},... 
        'trialNumber', zeros(nTrials, 1),...
        'trialType', zeros(nTrials, 1),...  
        'trialOutcome', NaN(nTrials, 1),... 
        'epoch', NaN(nTrials, 1),...         
        'sessionIndex', NaN(nTrials, 1),...
        'sessionChange', NaN(nTrials, 1),...
        'ITI', zeros(nTrials, 1),...
        'odorValve', zeros(nTrials, 1)...
        );

    for i = 1:length(statesToAdd)
        TE(1).(statesToAdd{i}) = bpAddStateAsTrialEvent(sessions, statesToAdd{i});
    end
    TE(1).Port1In = bpAddEventAsTrialEvent(sessions, 'Port1In');
    TE.filename = cell(nTrials, 1);
    
    tcounter = 1;
    for sCounter = 1:length(sessions)
        session = sessions(sCounter);
        for counter = 1:session.SessionData.nTrials
            TE.filename{tcounter} = session.filename;
            TE.trialNumber(tcounter) = counter;
            TE.trialType(tcounter) = session.SessionData.TrialTypes(counter);
            TE.trialOutcome(tcounter) = session.SessionData.TrialOutcome(counter);
            TE.odorValve(tcounter) = session.SessionData.TrialSettings(counter).currentValve;
            if isfield(session.SessionData, 'Epoch')
                TE.epoch(tcounter) = session.SessionData.Epoch(counter);
            else
                TE.epoch(tcounter) = 1;
            end
            tcounter = tcounter + 1; % don't forget :)            
        end
    end
    
    sessionNames = unique(TE.filename);
    for counter = 1:length(sessionNames)
        sname = sessionNames{counter};
        TE.sessionIndex(cellfun(@(x) strcmp(x, sname), TE.filename)) = counter;
    end
    TE.sessionIndex = TE.sessionIndex';
    TE.sessionChange = [0; diff(TE.sessionIndex)];    
    
    TE.cueCondition = ismember(TE.trialType, 1:2) * 1 + ismember(TE.trialType, 3:4) * 2; % 1 = rewarded odor, 2 = punished odor
    sessionNames = unique(TE.filename);
    for counter = 1:length(sessionNames)
        sname = sessionNames{counter};
        TE.sessionIndex(cellfun(@(x) strcmp(x, sname), TE.filename)) = counter;
    end
    TE.sessionChange = [0; diff(TE.sessionIndex)];    
    