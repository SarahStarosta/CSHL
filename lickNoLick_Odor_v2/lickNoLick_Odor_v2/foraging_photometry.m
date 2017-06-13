function foraging_photometry

global BpodSystem


TotalRewardDisplay('init')
%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

defaults = {...
    'GUI.Epoch', 1;...
    'GUI.LED1_amp', 1.5;...
    'GUI.LED2_amp', 8;...
    'GUI.PhotometryOn', 1;...
    'GUI.UsePulsePal', 1;...
    'GUI.MaxTrials', 1000;...
    'GUI.randomDelay', 0;...
    'GUI.ChangeOver', 1;... %
    'GUI.RewardDelay', 5;... %s
    'GUIRewardAmount', [4 10 16];...
    
    'GUI.depleft',0.8;...
    'GUI.depright', 0.8;...
    'GUI.block', 10000;...
    
    'PreCsRecording', 4;...
    'PostUsRecording', 4;...
    };

S = setBpodDefaultSettings(S, defaults);

%% Pause and wait for user to edit parameter GUI
BpodParameterGUI('init', S);
BpodSystem.Pause = 1;
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin


BpodSystem.ProtocolSettings = S; % copy settings back prior to saving
SaveBpodProtocolSettings;

%% Define trials
StartRewardLeft= shuffle(repmat(S.GUI.RewardAmount ,1,500));
StartRewardRight= shuffle(repmat(S.GUI.RewardAmount,1,500));
block=S.GUI.block; % after how many trials should the bridge change?
changebridge = zeros(1,1000);
changebridge(block:block:1000)=1;
howmany=length(find(changebridge==1))
bridgepos= repmat([130; 180; 230],ceil(howmany/3),1);

if S.GUI.randomDelay  ==1
    for k=1:S.GUI.MaxTrials
        delays(k) = exprnd(S.GUI.RewardDelay);
        while delays(k)>10 | delays(k)<1
            delays(k) = exprnd(S.GUI.RewardDelay);
        end
        
    end
else
    delays = ones(1,S.GUI.MaxTrials)*S.GUI.RewardDelay ;
end
count=1;

%% Initialize NIDAQ
S.nidaq.duration = 40*60;% 40 minutes
startX = 0 - S.PreCsRecording; % 0 defined as time from cue (because reward time can be variable depending upon outcomedelay)
if S.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    S = initPhotometry(S);
end
%% photometry plots
if S.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    updatePhotometryPlot('init');
    lickNoLick_Odor_PhotometryRasters('init', 'baselinePeriod', [1 S.PreCsRecording])
end


% determine nidaq/point grey and olfactometer triggering arguments
npgWireArg = 0;
npgBNCArg = 1; % BNC 1 source to trigger Nidaq is hard coded
olfWireArg = 0;
olfBNCArg = 0;
if ~BpodSystem.EmulatorMode
    switch pgSettings.triggerType
        case 'WireState'
            npgWireArg = bitset(npgWireArg, pgSettings.triggerNumber); % its a wire trigger
        case 'BNCState'
            npgBNCArg = bitset(npgBNCArg, pgSettings.triggerNumber); % its a BNC trigger
    end
    olfWireArg = 0;
    olfBNCArg = 0;
    switch olfSettings.triggerType
        case 'WireState'
            olfWireArg = bitset(olfWireArg, olfSettings.triggerNumber);
        case 'BNCState'
            olfBNCArg = bitset(olfBNCArg, olfSettings.triggerNumber);
    end
end

%% Main trial loop

for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    LeftValveTime(1) = GetValveTimes(StartRewardLeft(1), [1]);
    RightValveTime(1) = GetValveTimes(StartRewardRight(1), [1]); % Update reward amounts
    LeftAmount(1)= StartRewardLeft(1);
    RightAmount(1)= StartRewardRight(1);
    sma = NewStateMatrix();
    sma = SetGlobalTimer(sma,1,S.GUI.Answer); % post cue
    sma = SetGlobalTimer(sma,2,S.nidaq.duration); % photometry acq duration
    
    
    % check if animal has been in this port before
    if currentTrial>1
        if isnan(BpodSystem.Data.RawEvents.Trial{1,currentTrial-1}.States.RightReward(1))==0%has it been to the right port on the last trial?
            LeftAmount(currentTrial)= StartRewardLeft(currentTrial);
            LeftValveTime(currentTrial) = GetValveTimes(StartRewardLeft(currentTrial), [1]);
            RightAmount(currentTrial)=  RightAmount(currentTrial-1)* S.GUI.depright;
            RightValveTime(currentTrial) = GetValveTimes(RightAmount(currentTrial), [3]); % Update reward amounts
            
        elseif isnan(BpodSystem.Data.RawEvents.Trial{1,currentTrial-1}.States.LeftReward(1))==0 % has it been to the left port on the last trial?
            RightAmount(currentTrial)=  StartRewardRight(currentTrial);
            RightValveTime(currentTrial) = GetValveTimes(StartRewardRight(currentTrial), [1]);
            LeftAmount(currentTrial)=  LeftAmount(currentTrial-1)* S.GUI.depleft;
            LeftValveTime(currentTrial) = GetValveTimes(LeftAmount(currentTrial), [1]); % Update reward amounts
            
        else
            LeftAmount(currentTrial)=StartRewardLeft(currentTrial);
            RightAmount(currentTrial)= StartRewardRight(currentTrial);
            LeftValveTime(currentTrial) =  GetValveTimes(LeftAmount(currentTrial), [1]);
            RightValveTime(currentTrial) = GetValveTimes(RightAmount(currentTrial), [3]);
        end
    end
    if RightAmount(currentTrial)< 1 % check what is reasonable here; 0.02 is circa 0.7um
        RightAmount(currentTrial)= 0;
        RightValveTime(currentTrial) = GetValveTimes(RightAmount(currentTrial), [3]);
    elseif LeftAmount(currentTrial)< 1 %
        LeftAmount(currentTrial)= 0;
        LeftValveTime(currentTrial) =  GetValveTimes(LeftAmount(currentTrial), [1]);
    end
    
    % Bridge?
    if changebridge(currentTrial)==1
        count=count+1;
        SerialPort = serial('COM1', 'BaudRate', 115200, 'DataBits', 8, 'StopBits', 1, 'Timeout', 1, 'DataTerminalReady', 'off');
        % Send new servo position:
        fopen(SerialPort)
        pause (2)
        fwrite(SerialPort,['A' bridgepos (count)]) % Note: range = 130-250
        fclose(SerialPort); % Terminate connection:
        % give BNC input
        sma = AddState(sma, 'Name', 'ChangeBridge', ...
            'Timer', 3,...
            'StateChangeConditions', {'Tup', 'BridgeStop'},...
            'OutputActions', {'BNCState', 1}); %%% give BNC output
        sma = AddState(sma, 'Name', 'BridgeStop', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'WaitForPoke'},...
            'OutputActions', {'BNCState', 0}); %%% stop BNC output
    end
    
    if currentTrial>2
        if isnan(BpodSystem.Data.RawEvents.Trial{1,currentTrial-1}.States.LeftReward(1))==0 % has it been to the left port on the last trial?
            sma = AddState(sma, 'Name', 'Delayrightpoke', ...
                'Timer',  S.GUI.ChangeOver,...
                'StateChangeConditions', {'Tup', 'WaitForPoke','Port1In', 'LeftRewardDelay',},...
                'OutputActions', {});
        elseif isnan(BpodSystem.Data.RawEvents.Trial{1,currentTrial-1}.States.RightReward(1))==0%has it been to the right port on the last trial?
            sma = AddState(sma, 'Name', 'Delayleftpoke', ...
                'Timer',  S.GUI.ChangeOver,...
                'StateChangeConditions', {'Tup', 'WaitForPoke','Port3In', 'RightRewardDelay',},...
                'OutputActions', {});
        end
        
    end
    
    % every trial
  
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 5,...
        'StateChangeConditions', {'Tup', 'WaitForPoke','Port1In', 'LeftRewardDelay', 'Port3In', 'RightRewardDelay'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'LeftRewardDelay', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'LeftReward','Port1Out','LeftReward'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'RightRewardDelay', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'RightReward','Port3Out','RightReward'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'LeftReward', ...
        'Timer', LeftValveTime(currentTrial),...
        'StateChangeConditions', {'Tup', 'Drinkingleft'},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', RightValveTime(currentTrial),...
        'StateChangeConditions', {'Tup', 'Drinkingright'},...
        'OutputActions', {'ValveState', 4});
    
    sma = AddState(sma, 'Name', 'Drinkingright', ...
        'Timer', delays(currentTrial),...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'Drinkingleft', ...
        'Timer', delays(currentTrial),...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
       
    %%
    SendStateMatrix(sma);
    
    %% prep data acquisition
    if S.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        preparePhotometryAcq(S);
    end
    %% Run state matrix
    RawEvents = RunStateMatrix();  % Blocking!
    tic;
    %% Stop Photometry session
    if S.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        stopPhotometryAcq;
    end
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        %% Process NIDAQ session
        if S.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
            processPhotometryAcq(currentTrial);
            %% online plotting
            processPhotometryOnline(currentTrial);
            updatePhotometryPlot('update', startX);
            xlabel('Time from cue (s)');
        end
        %% collect and save data
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)     
        
        %% save data
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    else
        disp([' *** Trial # ' num2str(currentTrial) ':  aborted, data not saved ***']); % happens when you abort early (I think), e.g. when you are halting session
    end
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        if ~BpodSystem.EmulatorMode
            fclose(valveSlave);
            delete(valveSlave);
        end
        return
    end
end
