    
%% 
sessions = bpLoadSessions;
%%
TE = makeTE_LNL_odor_V2(sessions);
%%
% assume that photometry channels are consistent across sessions
channels=[]; dFFMode = {}; BL = {};
if sessions(1).SessionData.Settings.GUI.LED1_amp > 0
    channels(end+1) = 1;
    dFFMode{end+1} = 'simple';
    BL{end + 1} = [1 4];
end

if sessions(1).SessionData.Settings.GUI.LED2_amp > 0
    channels(end+1) = 2;
    dFFMode{end+1} = 'simple';
    BL{end + 1} = [1 4];    
end


    

TE.Photometry = processTrialAnalysis_Photometry2(sessions, 'dFFMode', dFFMode, 'blMode', 'byTrial', 'zeroField', 'Cue', 'channels', channels, 'baseline', BL);

% normalize greem by red
for mt=1:length(TE.Photometry.data(1).ZS)
   y=TE.Photometry.data(2).dFF (mt,:); % green channel
    x=TE.Photometry.data(1).dFF (mt,:); % red channel
    brob = robustfit(x,y)
    TE.Photometry.data(1).norm(mt,:) = x-(brob(1)+brob(2)*x)
end
%% extract peak/trough trial dFF responses to reinforcement and lick counts
% csWindow = cellfun(@(x,y,z) [x(1) max(y(end), z(end))], TE.Cue, TE.AnswerLick, TE.AnswerNoLick); % max- to select either AnswerLick or AnswerNoLick timestamp (unused state contains NaN)
nTrials = length(TE.filename);




usWindow = [0 0.5];
%  below line is in case you varied the delay between cue and outcome
%  across sessions. Then you need to figure out the session-specific time
%  stamps for outcome delivery
usZeros = cellfun(@(x,y,z,a) max(x(1), max(y(1), max(z(1), a(1)))), TE.Reward, TE.Punish, TE.WNoise, TE.Neutral); %'Reward', 'Punish', 'WNoise', 'Neutral'


for channel = channels
    TE.phPeakMean_baseline(channel) = bpCalcPeak_dFF(TE.Photometry, channel, [1 4], [], 'method', 'mean', 'phField', 'ZS');
    TE.phPeakMean_us(channel) = bpCalcPeak_dFF(TE.Photometry, channel, [0 0.75], usZeros, 'method', 'mean', 'phField', 'ZS');    
    if channel == 1 % look for a bump
        % 90th percentiile
        TE.phPeakPercentile_us(channel) = bpCalcPeak_dFF(TE.Photometry, channel, [0 0.75], usZeros, 'method', 'percentile', 'percentile', 0.9, 'phField', 'ZS');
    elseif channel == 2 % look for a dip
        % 10th percentil
        TE.phPeakPercentile_us(channel) = bpCalcPeak_dFF(TE.Photometry, channel, [0 0.75], usZeros, 'method', 'percentile', 'percentile', 0.1, 'phField', 'ZS');  
    end
end




% what window to use?  i
TE.usLicks = countEventFromTE(TE, 'Port1In', [0 0.75], usZeros);


%%
% optionally- create a field called TE.reject and manually use
% e.g.   filterTE(TE, 'trialType', 1, 'reject', 0)
%%

%% generate trial lookups for different combinations of conditions
% see Pavlovian_reversals_blocks    blocks 2 and 3

    
    srewardTrials = filterTE(TE, 'trialType', 1);%, 'reject', 0);
    brewardTrials = filterTE(TE, 'trialType', 2);%, 'reject', 0);
    neutralTrials = filterTE(TE, 'trialType', 3);%, 'reject', 0);

trialCount = [1:length(TE.filename)]';

%%
    h=ensureFigure('Averages', 1); 
    mcLandscapeFigSetup(h);

    pm = [4 1]; % subplot matrix
    
    % - 6 0 4
    % plot reward and neutral trials (trial types 1 and 2)
    if ismember(1, channels)
        subplot(pm(1), pm(2), 1, 'FontSize', 12, 'LineWidth', 1); 
        % channel provided as the 3rd argument
        [ha, hl] = phPlotAverageFromTE(TE, {srewardTrials, brewardTrials, neutralTrials}, 1,...
            'FluorDataField', 'dFF', 'window', [-3, 7], 'linespec', {'y','r', 'k'}); %high value, reward
        legend(hl, {'smallrew','bigrew', 'norew'}, 'Location', 'northwest', 'FontSize', 12); legend('boxoff');
        title('GCamp'); ylabel('Green dF/F Zscored');
    end
    if ismember(2, channels)
        subplot(pm(1), pm(2), 2, 'FontSize', 12, 'LineWidth', 1); 
        [ha, hl] = phPlotAverageFromTE(TE, {srewardTrials, brewardTrials, neutralTrials}, 2,...
            'FluorDataField', 'dFF', 'window', [-3, 7], 'linespec', {'y','r', 'k' }); %high value, reward
        legend(hl, {'smallrew','bigrew','norew'}, 'Location', 'northwest', 'FontSize', 12); legend('boxoff');
        title('TDtomato'); ylabel('Red dF/F Zscored');
    end
    
    subplot(pm(1), pm(2), 3, 'FontSize', 12, 'LineWidth', 1); % normalized Channel1
    
    [ha, hl] = phPlotAverageFromTE(TE, {srewardTrials, brewardTrials, neutralTrials}, 1,...
            'FluorDataField', 'norm', 'window', [-3, 7], 'linespec', {'y','r', 'k' }), hold on; %high value, reward
        [ha, hl] = phPlotAverageFromTE(TE, { brewardTrials}, 1,...
            'FluorDataField', 'dFF', 'window', [-3, 7], 'linespec', {':r'});
        legend(hl, {'smallrew','bigrew','norew'}, 'Location', 'northwest', 'FontSize', 12); legend('boxoff');
        title('normalized'); ylabel('normalized green channel');
  
    
    
    % lick averages
    % I don't even remember why I supply trialNumbering parameter right
    % now...
    varargin = {'trialNumbering', 'consecutive',...
        'binWidth', 0.5, 'window', [-3 7], 'zeroField', 'Cue', 'startField', 'PreCsRecording', 'endField', 'PostUsRecording'};
    axh = [];
    subplot(pm(1), pm(2), 4); [ha, hl] = plotEventAverageFromTE(TE, {srewardTrials, brewardTrials, neutralTrials}, 'Port1In', varargin{:});'linespec'; {'y','r','k'};
    legend(hl, {'smallrew', 'bigrew', 'norew'}, 'Location', 'southwest', 'FontSize', 12); legend('boxoff');
    title('Cue Licks'); ylabel('licks (s)'); xlabel('time from cue (s)'); 
    
    %%
    channels = [1 2]; % might vary dpeendijng on experiemnt
    %%
    
    CLimFactor = 2; % scale each image +/-  2 * global baseline standard deviation

for channel = channels

    saveName = ['Rasters_ch' num2str(channel)];
    h=ensureFigure(saveName, 1);
    mcPortraitFigSetup(h);
    subplot(1,6,1); % lick raster
    eventRasterFromTE(TE, srewardTrials, 'Port1In', 'trialNumbering', 'consecutive',...
        'zeroField', 'Cue', 'startField', 'PreCsRecording', 'endField', 'PostUsRecording');
    title('small reward Trials'); ylabel('trial number');
    set(gca, 'XLim', [-4 7]); 
%     set(gca, 'YLim', [0 max(trialCount)]);
    set(gca, 'FontSize', 14)        
    
    % photometry raster
    subplot(1,6,2); phRasterFromTE(TE, srewardTrials, channel, 'CLimFactor', CLimFactor, 'trialNumbering', 'consecutive');
        set(gca, 'FontSize', 14)
        
   subplot(1,6,3); % lick raster
    eventRasterFromTE(TE, brewardTrials, 'Port1In', 'trialNumbering', 'consecutive',...
        'zeroField', 'Cue', 'startField', 'PreCsRecording', 'endField', 'PostUsRecording');
    title('big reward Trials'); ylabel('trial number');
    set(gca, 'XLim', [-4 7]); 
%     set(gca, 'YLim', [0 max(trialCount)]);
    set(gca, 'FontSize', 14)        
    
    % photometry raster
    subplot(1,6,4); phRasterFromTE(TE, brewardTrials, channel, 'CLimFactor', CLimFactor, 'trialNumbering', 'consecutive');
        set(gca, 'FontSize', 14)
        
    subplot(1,6,5);
    eventRasterFromTE(TE, neutralTrials, 'Port1In', 'trialNumbering', 'consecutive',...
        'zeroField', 'Cue', 'startField', 'PreCsRecording', 'endField', 'PostUsRecording');
    title('Neutral Trials'); ylabel('trial number');
    set(gca, 'XLim', [-4 7]); 
%     set(gca, 'YLim', [0 max(trialCount)]);
    set(gca, 'FontSize', 14)        

        
        subplot(1,6,6); phRasterFromTE(TE, neutralTrials, channel, 'CLimFactor', CLimFactor, 'trialNumbering', 'consecutive');
        set(gca, 'FontSize', 14)
%     line(repmat([-4; 7], 1, length(reversals)), [reversals'; reversals'], 'Parent', gca, 'Color', 'g', 'LineWidth', 2); % reversal lines   

end
