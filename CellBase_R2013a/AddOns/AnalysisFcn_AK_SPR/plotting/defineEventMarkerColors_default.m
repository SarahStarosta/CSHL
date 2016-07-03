function event_marker_colors = defineEventMarkerColors_default
%
%  DEFINEEVENTMARKERCOLORS    Used to define color for event markers in
%  rasters

%SPR 2010-09-13

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         TRIGGEREVENT                     COLOR

%   0         0    0.6250
%          0         0    0.7500
%          0         0    0.8750
%          0         0    1.0000
%          0    0.1250    1.0000
%          0    0.2500    1.0000
%          0    0.3750    1.0000
%          0    0.5000    1.0000
%          0    0.6250    1.0000
%          0    0.7500    1.0000
%          0    0.8750    1.0000
%          0    1.0000    1.0000
%     0.1250    1.0000    0.8750
%     0.2500    1.0000    0.7500
%     0.3750    1.0000    0.6250
%     0.5000    1.0000    0.5000
%     0.6250    1.0000    0.3750
%     0.7500    1.0000    0.2500
%     0.8750    1.0000    0.1250
%     1.0000    1.0000         0
%     1.0000    0.8750         0
%     1.0000    0.7500         0
%     1.0000    0.6250         0
%     1.0000    0.5000         0
%     1.0000    0.3750         0
%     1.0000    0.2500         0
%     1.0000    0.1250         0
%     1.0000         0         0
%     0.8750         0         0
%     0.7500         0         0

event_marker_map=flipud(jet(30));

event_marker_map=flipud(hsv(30));

event_marker_colors = { ...
    'TriggerZoneIn',                                [0.75 0 0]; ...
    'TriggerZoneOut',                               [0.875 0 0]; ...
    'RewardCue',                                    [1 0 0]; ...
    'ReminderCue',                                  [1 0.125 0]; ...
    'Zone1FirstEntry',                              [1 0.375 0]; ...
    'Zone1FirstExit',                               [1 0.5 0]; ...
    'HomeZoneIn',                                   [1 0.625 0]; ...
    'HomeZoneOut',                                  [1 0.75 0]; ...
    'RewardZoneIn',                                 [1 0.875 0]; ...
    'RewardZoneOut',                                [1 1 0]; ...
    'WaterPortIn',                                  [0.875 1 0.125]; ...
    'WaterPortOut',                                 [0.75 1 0.25]; ...
    'WaterValveOn',                                 [0.625 1 0.375]; ...
    'WaterValveOff',                                [0.5 1 0.5]; ...
    'PreviousHomeZoneOut',                          [0.375 1 0.625]; ...
    'NextTriggerZoneIn',                            [0.25 1 0.75]; ...
    'TriggerZoneLastIn',                            [0.125 1 0.875]; ...
    'TriggerZoneFirstOut',                          [0 1 1]; ...
    'HomeZoneLastIn',                               [0 0.875 1]; ...
    'HomeZoneFirstOut',                             [0 0.75 1]; ...
    'RewardZoneLastIn',                             [0 0.625 1]; ...
    'RewardZoneFirstOut',                           [0 0.5 1]; ...
    'PulseOn',                                      [0 0.375 1]; ...
    'PulseOff',                                     [0 0.25 1]; ...
    'BurstOn',                                      [0 0.125 1];   ...
    'BurstOff',                                     [0 0 1];   ...
    'PrevPulseOff',                                 [0 0 0.875]; ...
    'NextPulseOn',                                  [0 0 0.75];   ...
    };

i=1;
    event_marker_colors(i,:)={'TriggerZoneIn',                                event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'TriggerZoneLastIn',                            event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'RewardCue',                                    event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'TriggerZoneFirstOut',                          event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'TriggerZoneOut',                               event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'Zone1FirstEntry',                              event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'Zone1FirstExit',                               event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'ReminderCue',                                  event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'HomeZoneIn',                                   event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'HomeZoneLastIn',                               event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'HomeZoneFirstOut',                             event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'HomeZoneOut',                                  event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'RewardZoneIn',                                 event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'RewardZoneLastIn',                             event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'RewardZoneFirstOut',                           event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'RewardZoneOut',                                event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'WaterPortIn',                                  event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'WaterValveOn',                                 event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'WaterValveOff',                                event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'WaterPortOut',                                 event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'PreviousHomeZoneOut',                          event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'NextTriggerZoneIn',                            event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'PulseOn',                                      event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'PulseOff',                                     event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'BurstOn',                                      event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'BurstOff',                                     event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'PrevPulseOff',                                 event_marker_map(i,:)};  i=i+1; ...
    event_marker_colors(i,:)={'NextPulseOn',                                  event_marker_map(i,:)};  i=i+1; ...
    
%         'OdorRatio=68',                   '68/32',             [0.25 0.35 0.65],  [],       '-';   ...
%         'OdorRatio=100',                  '100/0',             [0.15 0.1 0.9],    [],       '-'; ...
%         'OdorRatio=0&Correct',            '0/100 corr',        [0.15 0.9 0.1],    [],       '-'; ...
%         'OdorRatio=32&Correct',           '32/68 corr',        [0.25 0.65 0.25],  [],       '-';   ...
%         'OdorRatio=44&Correct',           '44/56 corr',        [0.25 0.55 0.45],  [],       '-';   ...
%         'OdorRatio=56&Correct',           '56/44 corr',        [0.25 0.45 0.55],  [],       '-';   ...
%         'OdorRatio=68&Correct',           '68/32 corr',        [0.25 0.35 0.65],  [],       '-';   ...
%         'OdorRatio=100&Correct',          '100/0 corr',        [0.15 0.1 0.9],    [],       '-';   ...
%         'OdorRatio=0&Error',              '0/100 err',         [0.15 0.9 0.1],    [1 0 0],  '-';  ...
%         'OdorRatio=32&Error',             '32/68 err',         [0.25 0.65 0.25],  [1 0 0],  '-';  ...
%         'OdorRatio=44&Error',             '44/56 err',         [0.25 0.55 0.45],  [1 0 0],  '-';  ...
%         'OdorRatio=56&Error',             '56/44 err',         [0.25 0.45 0.55],  [1 0 0],  '-';  ...
%         'OdorRatio=68&Error',             '68/32 err',         [0.25 0.35 0.65],  [1 0 0],  '-';  ...
%         'OdorRatio=100&Error',            '100/0 err',         [0.15 0.1
%         0.9],    [1 0 0],  '-'; ...
