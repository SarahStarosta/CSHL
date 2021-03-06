% 4/10/17  Analysis script for pavlovian reversals using LickNoLick_Odor_V2
% protocol

saveOn = 0;
%%
saveOn = 1;
%%
sessions = bpLoadSessions; % load sessions
%% 
TE = makeTE_wheel_v1(sessions); % make TE structure
%%
% assume that photometry channels are consistent across sessions, bleach
% fit dFF for GCaMP6f (ch1) and simple dFF for jRGECO1a (ch2)
channels=[]; dFFMode = {}; %BL = {};
if sessions(1).SessionData.Settings.GUI.LED1_amp > 0
    channels(end+1) = 1;
    dFFMode{end+1} = 'simple';
%     BL{end + 1} = [1 4];
end

if sessions(1).SessionData.Settings.GUI.LED2_amp > 0
    channels(end+1) = 2;
    dFFMode{end+1} = 'simple';
%     BL{end + 1} = [2 4];    
end


TE.Photometry = processTrialAnalysis_Photometry2(sessions, 'dFFMode', dFFMode, 'blMode', 'byTrial',...
    'zeroField', 'Baseline', 'channels', channels, 'baseline', [0 29], 'startField', 'Baseline', 'downsample', 305);

%%
TE.Wheel = processTrialAnalysis_Wheel(sessions, 'duration', 30, 'Fs', 20, 'startField', 'Start');

%% pupil data
%  [wheelY_new, wheelTimes_new] = resample(wheelY, wheelTimes, 20, 'linear');

TE = addPupilometryToTE(TE, 'duration', 30, 'zeroField', 'Baseline', 'startField', 'Baseline', 'frameRate', 60, 'frameRateNew', 20);
%% Now saved in directory according to first session filename
% savepath = 'C:\Users\Adam\Dropbox\KepecsLab\_Fitz\SummaryAnalyses\CuedOutcome_Odor_Complete';
% savepath = 'Z:\SummaryAnalyses\CuedOutcome_Odor_Complete';
% basepath = 'Z:\SummaryAnalyses\CuedOutcome_Odor_Complete\';
basepath = uigetdir;
sep = strfind(TE.filename{1}, '.');
subjectName = TE.filename{1}(1:sep(1)-1);
disp(subjectName);
savepath = fullfile(basepath, subjectName);
ensureDirectory(savepath);

%% plot raw and smoothed scatter plots of all the data (excepting the first few trials)
nPoints = numel(TE.Photometry.data(2).ZS(1:end,:)); 
ensureFigure('scatter', 1); 
ChAT_raw = reshape(TE.Photometry.data(1).ZS(1:end,:), nPoints, 1);
DAT_raw = reshape(TE.Photometry.data(2).ZS(1:end,:), nPoints, 1);
a=zeros(2,1);
smoothfactor = 100;
a(1) = subplot(1,2,1); scatter(DAT_raw, ChAT_raw, '.'); xlabel('DAT fluor (Zscored)'); ylabel('ChAT fluor (Zscored)'); title('raw');
a(2) = subplot(1,2,2); scatter(smooth(DAT_raw, smoothfactor), smooth(ChAT_raw, smoothfactor), '.'); xlabel('DAT fluor (Zscored)'); ylabel('ChAT fluor (Zscored)'); title('smoothed');
sameXYScale(a); %sameXScale(a);sameYScale(a);
% setXYsameLimit(a(1), 0);setXYsameLimit(a(2), 0);

if saveOn
    saveas(gcf, fullfile(savepath, 'scatter.fig'));
    saveas(gcf, fullfile(savepath, 'scatter.jpg'));
end
%%
window = [-2 2];
fs = 20; % sample rate
blSamples = (0 - window(1)) * fs;
[rewards_dat, ts, tn] = extractDataByTimeStamps(TE.Photometry.data(2).raw, TE.Photometry.startTime, 20, TE.Reward, [-2 2]);
rewards_chat = extractDataByTimeStamps(TE.Photometry.data(1).raw, TE.Photometry.startTime, 20, TE.Reward, [-2 2]);

% local dFF
bl_dat = nanmean(rewards_dat(:,1:blSamples), 2);
rewards_dat = bsxfun(@minus, rewards_dat, bl_dat);
rewards_dat = bsxfun(@rdivide, rewards_dat, bl_dat);
sd_dat = nanmean(nanstd(rewards_dat(:,1:blSamples)));
bl_chat = nanmean(rewards_chat(:,1:blSamples), 2);
rewards_chat = bsxfun(@minus, rewards_chat, bl_chat);
rewards_chat = bsxfun(@rdivide, rewards_chat, bl_chat);
sd_chat = nanmean(nanstd(rewards_chat(:,1:blSamples)));
nTrials = length(sessions.SessionData.nTrials);
ts_abs = zeros(size(ts));
for counter = 1:length(ts)
    ts_abs(counter) = ts(counter) + sessions.SessionData.TrialStartTimestamp(tn(counter));    
end

iri_pre = [Inf; diff(ts_abs)];
iri_post = [diff(ts_abs); Inf];

[~, I] = sort(iri_pre);
iri_pre_sorted = iri_pre(I);
rewards_dat_sorted = rewards_dat(I, :);
rewards_chat_sorted = rewards_chat(I, :);
climFactor = 4;
clim_chat = [-climFactor * sd_chat, climFactor * sd_chat] + 0.003;
clim_dat = [-climFactor * sd_dat, climFactor * sd_dat] + 0.03;
ensureFigure('random_rewards', 1); 
    % subplot(3,2,1); image(rewards_chat, 'XData', window, 'CDataMapping', 'Scaled'); set(gca, 'CLim', [min(min(rewards_chat_sorted)), max(max(rewards_chat_sorted))]); colormap('jet');  title('ChAT');
% subplot(3,2,2); image(rewards_dat, 'XData', window,  'CDataMapping', 'Scaled'); set(gca, 'CLim', [min(min(rewards_dat_sorted)), max(max(rewards_dat_sorted))]); colormap('jet');    title('DAT');
subplot(3,2,1); image(rewards_chat, 'XData', window, 'CDataMapping', 'Scaled'); set(gca, 'CLim', clim_chat); colormap('jet');  title('ChAT');
subplot(3,2,2); image(rewards_dat, 'XData', window,  'CDataMapping', 'Scaled'); set(gca, 'CLim', clim_dat); colormap('jet');    title('DAT');
xdata = linspace(window(1), window(2), size(rewards_chat, 2));
subplot(3,2,3); plot(xdata, nanmean(rewards_chat));
subplot(3,2,4); plot(xdata, nanmean(rewards_dat));
subplot(3,2,5); triggeredEventRasterFromTE(TE, 'Port1In', TE.Reward);
set(gca, 'YLim', [0 size(rewards_chat, 1)]);

% reward licks vs. trial number to truncate
rl = extractTriggeredEvents(TE, 'Port1In', TE.Reward);
ensureFigure('truncate', 1);
rl_trials = unique(rl.eventTrials);
rl_count = zeros(size(rl_trials));
for counter = 1:length(rl_trials)
    trial = rl_trials(counter);
    rl_count(counter) = sum(rl.eventTimes > 0 & rl.eventTrials == trial);    
end
plot(rl_trials, smooth(rl_count)); ylabel('# reward licks'); xlabel('trial #');
    

if saveOn
    saveas(gcf, fullfile(savepath, 'random_rewards.fig'));
    saveas(gcf, fullfile(savepath, 'random_rewards.jpg'));
end


%%
% good trials for 5/31 session,  1, 2, 3, 17
% good trials for 6/1 session 1, 4-  !!!! trial 1 is good for showing DAT
% and ChAT correlations with reward and without but doesn't have nice pupil
% diameter
% good trials with pupil traces that needed gap filling: 12
trial = 1;
ensureFigure('examples', 1);
subplot(4,1,1);
ydata = TE.Photometry.data(1).raw(trial, :);    
plot(TE.Photometry.xData, ydata, 'k'); hold on;
tsx = repmat(TE.Reward{trial}(:,1), 1, 2)';
tsy = [repmat(min(min(ydata)), 1, size(tsx, 2)); repmat(max(max(ydata)), 1, size(tsx, 2))];    
plot(tsx, tsy, 'r'); ylabel('ChAT');
subplot(4,1,2);
ydata = TE.Photometry.data(2).raw(trial, :);    
plot(TE.Photometry.xData, ydata, 'k'); hold on;
tsx = repmat(TE.Reward{trial}(:,1), 1, 2)';
tsy = [repmat(min(min(ydata)), 1, size(tsx, 2)); repmat(max(max(ydata)), 1, size(tsx, 2))];    
plot(tsx, tsy, 'r'); ylabel('DAT');
pupField = 'pupDiameter';
try
    subplot(4,1,3); plot(TE.pupil.xData, TE.pupil.(pupField)(trial, :)); ylabel('Pupil Diameter');
    set(gca, 'YLim', [percentile(TE.pupil.(pupField)(trial, :), 0.03), percentile(TE.pupil.(pupField)(trial, :), 0.97)]);
catch
end
subplot(4,1,4); plot(TE.Wheel.xData, TE.Wheel.data.V(trial, :)); ylabel('Velocity');

if saveOn
    saveas(gcf, fullfile(savepath, 'examples.fig'));
    saveas(gcf, fullfile(savepath, 'examples.jpg'));
end

%% McKnight special for 6/1 session, 
% good trials for 5/31 session,  1, 2, 3, 17
% good trials for 6/1 session 1, 4-  !!!! trial 1 is good for showing DAT
% and ChAT correlations with reward and without but doesn't have nice pupil
% diameter
% good trials with pupil traces that needed gap filling: 12
trial = 1;
ensureFigure('examples', 1);
subplot(2,1,1);
ydata = TE.Photometry.data(1).ZS(trial, :);    
plot(TE.Photometry.xData, ydata, 'g'); hold on;
tsx = repmat(TE.Reward{trial}(:,1), 1, 2)';
tsy = [repmat(min(min(ydata)), 1, size(tsx, 2)); repmat(max(max(ydata)), 1, size(tsx, 2))];    
plot(tsx, tsy, 'b'); ylabel('ChAT (ZScore)');
subplot(2,1,2);
ydata = TE.Photometry.data(2).ZS(trial, :);    
plot(TE.Photometry.xData, ydata, 'r'); hold on;
tsx = repmat(TE.Reward{trial}(:,1), 1, 2)';
tsy = [repmat(min(min(ydata)), 1, size(tsx, 2)); repmat(max(max(ydata)), 1, size(tsx, 2))];    
plot(tsx, tsy, 'b'); ylabel('DAT (ZScore)');
if saveOn
    saveas(gcf, fullfile(savepath, 'ChAT_vs_DAT_randomReward_example.fig'));
    saveas(gcf, fullfile(savepath, 'ChAT_vs_DAT_randomReward_example.jpg'));
    saveas(gcf, fullfile(savepath, 'ChAT_vs_DAT_randomReward_example.epsc'));
end