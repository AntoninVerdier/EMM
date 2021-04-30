function Launch_EMM()

%% Initilaize variables that are not user modifiables
global hand
hand.params.NStimPerEpoch = 10;
hand.params.NStim = 300;
hand.params.NRepPerStim = 1;
hand.params.BlockDelay = 1.5;
hand.params.piezoChan = 1;
hand.params.TTLChan = 1;
hand.params.cameraChan = 5;



%% Set up the GUI

% create the window
hand.mainfig = uifigure('position',[300 150 1500 1000],...
    'WindowState', 'maximized',...
    'numbertitle','off',...
    'name','Main',...
    'menubar','none',...
    'tag','fenetre depart');

hand.menu = uimenu(hand.mainfig, 'Text', 'Acquisition');
hand.acqSettingsMenu = uimenu(hand.menu, 'Text', 'Settings...',...
    'MenuSelectedFcn', @Change_daqSettings);

hand.mainGrid = uigridlayout(hand.mainfig);
hand.mainGrid.RowHeight = {30, 30, '1x', '1x', '1x', '1x'};
hand.mainGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', 200, 200};

% Create axes, main buttons
hand.expAxes = uiaxes(hand.mainGrid);
hand.expAxes.Layout.Row = [1 4];
hand.expAxes.Layout.Column = [1 5];

hand.LoadExp = uibutton(hand.mainGrid,'push',...
    'Text','Load experiment file',...
    'tag','init',...
    'ButtonPushedFcn', @Load_Exp_CSV);
hand.LoadExp.Layout.Row = 1;
hand.LoadExp.Layout.Column = 9;

hand.ExpName = uilabel(hand.mainGrid,...
    'Text','No experiment loaded');
hand.ExpName.Layout.Row = 1;
hand.ExpName.Layout.Column = 10;

hand.PlaySound = uibutton(hand.mainGrid,'push',...
    'Text','Sound',...
    'ButtonPushedFcn',@PlaySound);
hand.PlaySound.Layout.Row = 2;
hand.PlaySound.Layout.Column = 9;

% Tabbed panels for experiment info
hand.ExpInfo.TabGroup = uitabgroup(hand.mainGrid,...
    'TabLocation', 'top');
hand.ExpInfo.TabGroup.Layout.Row = [3 6];
hand.ExpInfo.TabGroup.Layout.Column = [9 10];

hand.StimInfo.Tab = uitab(hand.ExpInfo.TabGroup,...
    'Title', 'Stimulation info');

hand.StimInfo.TabGrid = uigridlayout(hand.StimInfo.Tab, [5 2]);

hand.BehaviourInfo.Tab = uitab(hand.ExpInfo.TabGroup,...
    'Title', 'Behaviour info');

hand.StimInfo.StimNb = uitextarea(hand.StimInfo.TabGrid,...
    'Value','',...
    'ValueChangedFcn',{@Change_Param, hand.params.NStim});
hand.StimInfo.StimNb.Layout.Row = 2;
hand.StimInfo.StimNb.Layout.Column = 1;

hand.StimInfo.StimNbTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Num of stims');
hand.StimInfo.StimNbTxt.Layout.Row = 2;
hand.StimInfo.StimNbTxt.Layout.Column = 2;

hand.StimInfo.StimPerEp = uitextarea(hand.StimInfo.TabGrid,...
    'Value','',...
    'ValueChangedFcn',{@Change_Param, hand.params.NStimPerEpoch});
hand.StimInfo.StimPerEp.Layout.Row = 3;
hand.StimInfo.StimPerEp.Layout.Column = 1;

hand.StimInfo.StimPerEpTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Num stims per ep');
hand.StimInfo.StimPerEpTxt.Layout.Row = 3;
hand.StimInfo.StimPerEpTxt.Layout.Column = 2;

hand.StimInfo.RepPerEp = uitextarea(hand.StimInfo.TabGrid,...
    'Value','',...
    'ValueChangedFcn',{@Change_Param, hand.params.NRepPerStim});
hand.StimInfo.RepPerEp.Layout.Row = 4;
hand.StimInfo.RepPerEp.Layout.Column = 1;

hand.StimInfo.RepPerEpTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Rep per ep');
hand.StimInfo.RepPerEpTxt.Layout.Row = 4;
hand.StimInfo.RepPerEpTxt.Layout.Column = 2;

hand.StimInfo.BlockDelay = uitextarea(hand.StimInfo.TabGrid,...
    'Value', '',...
    'ValueChangedFcn',{@Change_Param, hand.params.BlockDelay});
hand.StimInfo.BlockDelay.Layout.Row = 5;
hand.StimInfo.BlockDelay.Layout.Column = 1;

hand.StimInfo.BlockDelayTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Block delay (s)');
hand.StimInfo.BlockDelayTxt.Layout.Row = 5;
hand.StimInfo.BlockDelayTxt.Layout.Column = 2;

%% Button functions
    function Load_Exp_CSV(obj,event)
        % load the csv file and parse paramters
        % load the file
        [Protocol, ProtocolPath] = uigetfile('.csv');
        if ~isequal(ProtocolPath, 0)
            csvTab = readtable([ProtocolPath filesep Protocol], 'ReadRowNames',true,'ReadVariableNames',false,'Delimiter',';');
        else
            uialert(hand.mainfig, 'No protocol file selected', 'No protocol')
            return
        end

        soundsTable = readtable(csvTab{'SoundListFile',1}{1},'ReadVariableNames',false);

        [dirSounds, ~, ~] = fileparts(csvTab{'SoundListFile',1}{1});

        nStims = str2double(cell2mat(csvTab.Var1('NStim')));
        nRepPerStim = str2double(cell2mat(csvTab.Var1('NRepPerStim')));
        idxPerm = repmat(1:nStims, [1,nRepPerStim]);
        perms = randperm(nStims*nRepPerStim);
        StimsVector = idxPerm(perms);

        TrialInterval = str2double(cell2mat(csvTab.Var1('TrialInterval')));


        % set new values
        hand.params.NStimPerEpoch = 20;
        hand.params.NStim = 100;
        hand.params.NRepPerStim = 1;
        hand.params.BlockDelay = 2;

        % update the buttons
        set(hand.StimInfo.StimNb,'Text', num2str(hand.params.NStimPerEpoch))
        set(hand.StimInfo.StimPerEp,'Text', num2str(hand.params.NStim))
        set(hand.StimInfo.RepPerEp,'Text', num2str(hand.params.NRepPerStim))
        set(hand.StimInfo.BlockDelay,'Text', num2str(hand.params.BlockDelay))

    end

    function Change_Param(obj,event, param)
      param = eval(event.Value);
    end

    function PlaySound(obj,event)
        disp('sound')
    end

    function Change_daqSettings(obj, event)
        hand.daqFig = uifigure('position', [400, 300, 200, 120],...
        'numbertitle','off',...
        'name','Acquisition settings',...
        'menubar','none',...
        'tag','fenetre daq');
    
        hand.daqSettings.Grid = uigridlayout(hand.daqFig);
        hand.daqSettings.Grid.RowHeight = {25, 25, 25};
        hand.daqSettings.Grid.ColumnWidth = {50, '1x'};
        
        hand.daqSettings.TTL = uitextarea(hand.daqSettings.Grid,...
            'Value',num2str(hand.params.TTLChan),...
            'ValueChangedFcn',{@Change_Param, hand.params.TTLChan});
        hand.daqSettings.TTL.Layout.Row = 1;
        hand.daqSettings.TTL.Layout.Column = 1;
        
        hand.daqSettings.TTLTxt = uilabel(hand.daqSettings.Grid,...
            'Text','TTL Output Channel');
        hand.daqSettings.TTLTxt.Layout.Row = 1;
        hand.daqSettings.TTLTxt.Layout.Column = 2;
        
        hand.daqSettings.piezo = uitextarea(hand.daqSettings.Grid,...
            'Value',num2str(hand.params.piezoChan),...
            'ValueChangedFcn',{@Change_Param, hand.params.piezoChan});
        hand.daqSettings.piezo.Layout.Row = 2;
        hand.daqSettings.piezo.Layout.Column = 1;
        
        hand.daqSettings.piezoTxt = uilabel(hand.daqSettings.Grid,...
            'Text','Piezo Input Channel');
        hand.daqSettings.piezoTxt.Layout.Row = 2;
        hand.daqSettings.piezoTxt.Layout.Column = 2;
        
        hand.daqSettings.camera = uitextarea(hand.daqSettings.Grid,...
            'Value','',...
            'ValueChangedFcn',{@Change_Param, hand.params.cameraChan});
        hand.daqSettings.camera.Layout.Row = 3;
        hand.daqSettings.camera.Layout.Column = 1;
        
        hand.daqSettings.cameraTxt = uilabel(hand.daqSettings.Grid,...
            'Text','Camera Channel');
        hand.daqSettings.cameraTxt.Layout.Row = 3;
        hand.daqSettings.cameraTxt.Layout.Column = 2;
    end

% 
% Stims = cell([nStims 1]);
% for i=1:nStims
% 	[Stims{i,1},~] = audioread([dirSounds filesep cell2mat(soundsTable.Var1(i))]);
% end


% %% Create the daq session that will be used to stim
% fs=192000;
% s = daq.createSession('ni');
% stimChan=s.addAnalogOutputChannel('dev4', 0, 'Voltage');
% piezoChan = s.addAnalogInputChannel('dev4', 7, 'Voltage');
% 
% 
% stimChan.TerminalConfig = 'SingleEnded';
% piezoChan.TerminalConfig = 'SingleEnded';
% s.Rate = fs;
% 
% s.addDigitalChannel('dev4', 'port0/line7', 'OutputOnly');
% %TTLChan = s.addCounterInputChannel('dev4','ctr1','EdgeCount');
% TTLChan = s.addDigitalChannel('dev4', 'Port0/Line6', 'InputOnly');
% 
% %% Split the data into bunch of blocks
% 
% nStimPerEp = str2double(cell2mat(csvTab.Var1('NStimPerEp')));
% stepTrial = int32(TrialInterval*fs/1000);
% 
% 
% 
% for ii=1:1
% 	dataOutput = zeros(nStimPerEp*stepTrial,1);
% 	DigitalTTL = zeros(nStimPerEp*stepTrial,1);
% 	for jj = 0:nStimPerEp-1
% 		dataOutput(1+jj*stepTrial:jj*stepTrial+length(Stims{jj+1,1})) = Stims{jj+1,1};
% 		DigitalTTL(1+jj*stepTrial:jj*stepTrial+0.1*fs) = 1;
%     end
%     s.queueOutputData([dataOutput,DigitalTTL])
%     s.prepare()
% 	[data,time] = s.startForeground();
%     pause(TrialInterval*nStimPerEp/1000)
% end
% 	



%  Change_RepPerEp Change_BlockDelay

end
