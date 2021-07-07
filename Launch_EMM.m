function Launch_EMM()

%% Initilaize variables that are not user modifiables
global hand
%daqCard = daq.getDevices;
%hand.params.Dev = daqCard.ID;
hand.params.Dev = 'dev4';
hand.params.NStimPerEpoch = 10;
hand.params.NStim = 300;
hand.params.NRepPerStim = 15;
hand.params.BlockDelay = 1.5;
hand.params.TrialInterval = 1;
hand.params.DoRandomizeStims = 1;
hand.params.piezoChan = 1;
hand.params.TTLChan = 1;
hand.params.soundVChan = 7;
hand.params.cameraChan = 5;
hand.params.stimChan = 0;
hand.AskStop = false;

%% Set up the GUI

% create the window
hand.mainfig = uifigure('position',[50 100 1000 700],...
    'WindowState', 'normal',...
    'numbertitle','off',...
    'name','Main',...
    'menubar','none',...
    'tag','fenetre depart');

hand.menu = uimenu(hand.mainfig, 'Text', 'Acquisition');
hand.acqSettingsMenu = uimenu(hand.menu, 'Text', 'Settings...',...
    'MenuSelectedFcn', @Change_daqSettings);

hand.mainGrid = uigridlayout(hand.mainfig, [6,10]);
hand.mainGrid.RowHeight = {150, '1x', 30, 30, 200};
hand.mainGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', 120, 120};

% Create axes, main buttons
hand.ExpAxes = uiaxes(hand.mainGrid);
hand.ExpAxes.Layout.Row = [1 2];
hand.ExpAxes.Layout.Column = [1 6];

hand.ExpPan = uipanel(hand.mainGrid);
hand.ExpPan.Layout.Row = 1;
hand.ExpPan.Layout.Column = [9 10];

hand.ExpGroup.Grid = uigridlayout(hand.ExpPan, [5 1],...
    'RowSpacing', 0,...
    'Padding', [0 0 0 0]);
hand.ExpGroup.Grid.RowHeight = {22, 22, 22, 22, 22};


hand.ExpName = uilabel(hand.ExpGroup.Grid,...
    'Text','No experiment loaded',...
    'HorizontalAlignment', 'center');

hand.ExpGroup.LoadExp = uibutton(hand.ExpGroup.Grid,'push',...
    'Text','Reload experiment',...
    'tag','init',...
    'ButtonPushedFcn', @Load_Exp_CSV);

hand.ExpGroup.LoadExp = uibutton(hand.ExpGroup.Grid,'push',...
    'Text','Load experiment...',...
    'tag','init',...
    'ButtonPushedFcn', {@Load_Exp_CSV, 1});

hand.ExpGroup.SaveExp = uibutton(hand.ExpGroup.Grid,'push',...
    'Text','Save experiment',...
    'tag','init',...
    'ButtonPushedFcn', @Save_Exp_CSV);

hand.ExpGroup.SaveExpAs = uibutton(hand.ExpGroup.Grid,'push',...
    'Text','Save experiment as...',...
    'tag','init',...
    'ButtonPushedFcn', {@Save_Exp_CSV, 1});

hand.PlaySound = uibutton(hand.mainGrid,'push',...
    'Text','Test sounds',...
    'ButtonPushedFcn',@PlaySound);
hand.PlaySound.Layout.Row = 3;
hand.PlaySound.Layout.Column = 9;

hand.SoundListFilename = uilabel(hand.mainGrid,...
    'Text', '');
hand.SoundListFilename.Layout.Row = 3;
hand.SoundListFilename.Layout.Column = 10;


% THE LORD OF THE BUTTONS, ALMIGHTY CREATOR OF SOUND AND DATA, IT WHICH
% DISCUSSES WITH DAQ CARDS, THOU SHALL PLEASE IT NOT TO GET ERRORS.
hand.StartExp = uibutton(hand.mainGrid, 'push',...
    'Text', 'Start',...
    'ButtonPushedFcn', @StartExperiment);
hand.StartExp.Layout.Row = 4;
hand.StartExp.Layout.Column = 9;

% Ok maybe sometimes we fail, so let's have a button for that as well
hand.StopExp = uibutton(hand.mainGrid, 'push',...
    'Text', 'Stop',...
    'ButtonPushedFcn', @StopExperiment);
hand.StopExp.Layout.Row = 4;
hand.StopExp.Layout.Column = 10;

% Tabbed panels for experiment info
hand.ExpInfo.TabGroup = uitabgroup(hand.mainGrid,...
    'TabLocation', 'top');
hand.ExpInfo.TabGroup.Layout.Row = 2;
hand.ExpInfo.TabGroup.Layout.Column = [9 10];

hand.StimInfo.Tab = uitab(hand.ExpInfo.TabGroup,...
    'Title', 'Stimulation info');

hand.StimInfo.TabGrid = uigridlayout(hand.StimInfo.Tab);
hand.StimInfo.TabGrid.RowHeight = {22, 22, 22, 22, 22, 22, '1x'};
hand.StimInfo.TabGrid.ColumnWidth = {'1x', '1x'};

hand.BehaviourInfo.Tab = uitab(hand.ExpInfo.TabGroup,...
    'Title', 'Behaviour info');

hand.StimTypeText = uilabel(hand.StimInfo.TabGrid,...
    'Text', 'Experiment type');
hand.StimTypeText.Layout.Row = 1;
hand.StimTypeText.Layout.Column = 1;

hand.StimType = uidropdown(hand.StimInfo.TabGrid,...
    'Items', {'Stim only', 'Microscope triggering', 'Behaviour'},...
    'Value', 'Stim only');
hand.StimType.Layout.Row = 1;
hand.StimType.Layout.Column = 2;

hand.StimInfo.StimNb = uieditfield(hand.StimInfo.TabGrid,...
    'Value','',...
    'ValueChangedFcn',{@Change_Param, hand.params.NStim});
hand.StimInfo.StimNb.Layout.Row = 2;
hand.StimInfo.StimNb.Layout.Column = 1;

hand.StimInfo.StimNbTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Num of stims');
hand.StimInfo.StimNbTxt.Layout.Row = 2;
hand.StimInfo.StimNbTxt.Layout.Column = 2;

hand.StimInfo.StimPerEp = uieditfield(hand.StimInfo.TabGrid,...
    'Value','',...
    'ValueChangedFcn',{@Change_Param, hand.params.NStimPerEpoch});
hand.StimInfo.StimPerEp.Layout.Row = 3;
hand.StimInfo.StimPerEp.Layout.Column = 1;

hand.StimInfo.StimPerEpTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Num stims per ep');
hand.StimInfo.StimPerEpTxt.Layout.Row = 3;
hand.StimInfo.StimPerEpTxt.Layout.Column = 2;

hand.StimInfo.RepPerStim = uieditfield(hand.StimInfo.TabGrid,...
    'Value','',...
    'ValueChangedFcn',{@Change_Param, hand.params.NRepPerStim});
hand.StimInfo.RepPerStim.Layout.Row = 4;
hand.StimInfo.RepPerStim.Layout.Column = 1;

hand.StimInfo.RepPerEpTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Rep per stim');
hand.StimInfo.RepPerEpTxt.Layout.Row = 4;
hand.StimInfo.RepPerEpTxt.Layout.Column = 2;

hand.StimInfo.BlockDelay = uieditfield(hand.StimInfo.TabGrid,...
    'Value', '',...
    'ValueChangedFcn',{@Change_Param, hand.params.BlockDelay});
hand.StimInfo.BlockDelay.Layout.Row = 5;
hand.StimInfo.BlockDelay.Layout.Column = 1;

hand.StimInfo.BlockDelayTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Block delay (s)');
hand.StimInfo.BlockDelayTxt.Layout.Row = 5;
hand.StimInfo.BlockDelayTxt.Layout.Column = 2;

hand.StimInfo.TrialInterval = uieditfield(hand.StimInfo.TabGrid,...
    'Value', '',...
    'ValueChangedFcn',{@Change_Param, hand.params.BlockDelay});
hand.StimInfo.TrialInterval.Layout.Row = 6;
hand.StimInfo.TrialInterval.Layout.Column = 1;

hand.StimInfo.TrialIntervalTxt = uilabel(hand.StimInfo.TabGrid,...
    'Text','Block delay (s)');
hand.StimInfo.TrialIntervalTxt.Layout.Row = 6;
hand.StimInfo.TrialIntervalTxt.Layout.Column = 2;

%% Button functions
    function Load_Exp_CSV(obj,event, varargin)
        % load the csv file and parse paramters
        % load the file
        if nargin == 2
            queryfile=0;
        else
            queryfile = varargin{1};
        end
        if queryfile || strcmp(hand.Expfile, '')
            [Protocol, ProtocolPath] = uigetfile('.csv');
            hand.ExpFile = [ProtocolPath filesep Protocol];
        end
        opts = detectImportOptions([ProtocolPath filesep Protocol]);
        opts.VariableNamesLine=0;
        opts.RowNamesColumn = 1;
        opts.DataLine = [1 Inf];
        opts = setvartype(opts, 2, 'string');
        opts.VariableNames = {'RowNames','Var'};
        opts.SelectedVariableNames = 'Var';
        
        if ~isequal(ProtocolPath, 0)
            hand.csvTab = readtable([ProtocolPath filesep Protocol], opts);
        else
            uialert(hand.mainfig, 'No protocol file selected', 'No protocol')
            return
        end
        
        %hand.params.SoundListFile = hand.csvTab{'SoundListFile',1}{1};
        hand.params.NStim = str2double(hand.csvTab.Var('NStim'));
        hand.params.NRepPerStim = str2double(hand.csvTab.Var('NRepPerStim'));
        hand.params.NStimPerEpoch = str2double(hand.csvTab.Var('NStimPerEp'));
        hand.params.BlockDelay = str2double(hand.csvTab.Var('BlockDelay'));

        hand.params.TrialInterval = str2double(hand.csvTab.Var('TrialInterval'));
        hand.params.SoundListFile = hand.csvTab.Var('SoundListFile');
        
        hand.ExpFile = [ProtocolPath filesep Protocol];


        % update the buttons
        hand.StimInfo.StimNb.Value = num2str(hand.params.NStim);
        hand.StimInfo.StimPerEp.Value = num2str(hand.params.NStimPerEpoch);
        hand.StimInfo.RepPerStim.Value = num2str(hand.params.NRepPerStim);
        hand.StimInfo.BlockDelay.Value = num2str(hand.params.BlockDelay);
        hand.StimInfo.TrialInterval.Value = num2str(hand.params.TrialInterval);
        [~, hand.SoundListFilename.Text, ~] = fileparts(hand.params.SoundListFile);
        hand.ExpName.Text = Protocol;
        
        LoadSounds()
        
        function LoadSounds()
            soundsTable = readtable(hand.params.SoundListFile,'Delimiter', ';','ReadVariableNames',false);
            [dirSounds, ~, ~] = fileparts(hand.params.SoundListFile);
            hand.params.Sounds = cell([hand.params.NStim 1]);
            rateErrorRaise = 0;
            for i=1:hand.params.NStim
                [hand.params.Sounds{i,1},rate] = audioread(strcat(dirSounds, filesep, soundsTable.Var1{i}));
                if rate ~= 192000
                    rateErrorRaise = 1;
                end
            end
            if rateErrorRaise
                uialert(hand.mainfig, 'One of more files were not at a 192kHz audio rate. They will be played as 192kHz audio file.', 'Wrong audio rate detected')
            end
        end

    end

    function Save_Exp_CSV(obj, event, varargin)
        disp(nargin)
        if nargin == 2
            queryfile=0;
        else
            queryfile = varargin{1};
        end
        paramNames = fieldnames(hand.params);
        paramCell = cell(length(paramNames),2);
        
        for fn=1:numel(paramNames)
            paramCell{fn,1} = paramNames{fn};
            paramCell{fn,2} = hand.params.(paramNames{fn});
        end
        paramTab = cell2table(paramCell);
        
        if queryfile
            [path, file] = uigetfile('.csv');
            writetable(paramTab, [path filesep file])
        else
            writetable(paramTab, hand.ExpFile)
        end
        
    end

    function Change_Param(obj, event, param)
      param = eval(event.Value);
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

    function PlaySound(obj,event)
        %% Create the daq session that will be used to stim
        hand.params.Stimfs = 192000;
        hand.params.Testrecfs = 250000;
        
        % Stimulation session with 192kHz Rate and output channels
        Stimsession = daq('ni');
        stimChan = addoutput(Stimsession, hand.params.Dev, hand.params.stimChan, 'Voltage');
        
        stimChan.TerminalConfig = 'SingleEnded';
        
        addoutput(Stimsession, hand.params.Dev, 'Port0/line7', 'Digital');
        Stimsession.Rate = hand.params.Stimfs;
        
        % Recording sessions with higher rate (250kHz) to prevent aliasing
        % in the mic
        Recsession = daq('ni');
        micChan = addinput(Recsession, hand.params.Dev, hand.params.micChan, 'Voltage');
        
        micChan.TerminalConfig = 'SingleEnded';
        
        Recsession.Rate = hand.params.Testrecfs;
        
        for ii=1:hand.params.NStim
            if hand.AskStop
                hand.AskStop = false;
                disp('Acquisition stopped')
                return
            end
            
            dataOutput = zeros(stepTrial,1);
            DigitalTTL = zeros(stepTrial,1);
            dataOutput(1:length(hand.params.Sounds{jj+1,1})) = hand.params.Sounds{jj+1,1};
            DigitalTTL(1:0.1*hand.params.Stimfs) = 1;
            preload(Stimsession, [dataOutput,DigitalTTL])
            start(Recsession, 'Duration', hand.params.TrialInterval/1000+0.1)
            start(Stimsession)
            pause(hand.params.TrialInterval/1000+0.1)
            stop(Stimsession)
            stop(Recsession)
        end
    end

    function Equalize(obj, event)
        %placeholder for when I've figured out how to implement this
        
    end

    function StartExperiment(obj, event)
        [saveFile, savePath] = uiputfile('.mat');
        
        if hand.params.DoRandomizeStims
            idxPerm = repmat(1:hand.params.NStim, [1,hand.params.NRepPerStim]);
            perms = randperm(hand.params.NRepPerStim*hand.params.NStim);
            StimsVector = idxPerm(perms);
        end
        
        %% Create the daq session that will be used to stim
        hand.params.Stimfs = 192000;
        hand.params.Recfs = 1000;
        
        % Stimulation session with 192kHz Rate and output channels
        Stimsession = daq('ni');
        stimChan = addoutput(Stimsession, hand.params.Dev, hand.params.stimChan, 'Voltage');
        
        stimChan.TerminalConfig = 'SingleEnded';
        
        addoutput(Stimsession, hand.params.Dev, 'Port0/line7', 'Digital');
        Stimsession.Rate = hand.params.Stimfs;
        
        % Recording sessions with lower rate (10kHz) and input channels
        Recsession = daq('ni');
        soundV = addinput(Recsession, hand.params.Dev, ['ai' num2str(hand.params.soundVChan)], 'Voltage');
        soundV.TerminalConfig = 'SingleEnded';
        addinput(Recsession, hand.params.Dev, ['Port0/Line' num2str(hand.params.TTLChan)], 'Digital');
        piezoChan = addinput(Recsession, hand.params.Dev, hand.params.piezoChan, 'Voltage');
        
        piezoChan.TerminalConfig = 'SingleEnded';
        
        Recsession.Rate = hand.params.Recfs;
        Recsession.ScansAvailableFcnCount = hand.params.Recfs/10;

        blockDelay = int32(hand.params.BlockDelay*hand.params.Stimfs/1000);
        stepTrial = int32(hand.params.TrialInterval*hand.params.Stimfs/1000);
        
        %expe = struct('StimsVector', StimsVector, 'time', [], 'TTL', [], 'envelopes', []);
        
        hand.plots.soundPlot = animatedline(hand.ExpAxes);
        hand.plots.TTLPlot = animatedline(hand.ExpAxes);
        hand.plots.piezoPlot = animatedline(hand.ExpAxes);
        plotsHandles = {hand.plots.soundPlot, hand.plots.TTLPlot, hand.plots.piezoPlot};
        
        Recsession.ScansAvailableFcn = @(src, event) PlotNewData(src, plotsHandles);
        
        

        %% Split the data into bunch of blocks
        
        for ii=1:hand.params.NStim*hand.params.NRepPerStim/hand.params.NStimPerEpoch
            if hand.AskStop
                hand.AskStop = false;
                disp('Acquisition stopped')
                return
            end
            
            for handle=1:length(plotsHandles)
                clearpoints(plotsHandles{handle})
                addpoints(plotsHandles{handle}, 0, 0)
                drawnow
            end
            dataOutput = zeros(blockDelay+hand.params.NStimPerEpoch*stepTrial,1);
            DigitalTTL = zeros(blockDelay+hand.params.NStimPerEpoch*stepTrial,1);
            for jj = 0:hand.params.NStimPerEpoch-1
                dataOutput(1+blockDelay+jj*stepTrial:blockDelay+jj*stepTrial+length(hand.params.Sounds{jj+1,1})) = hand.params.Sounds{jj+1,1};
                DigitalTTL(1+blockDelay+jj*stepTrial:blockDelay+jj*stepTrial+0.1*hand.params.Stimfs) = 1;
            end
            disp(['Start of ', num2str(ii), 'th block'])
            preload(Stimsession, [dataOutput,DigitalTTL])
            start(Recsession, 'Duration', (hand.params.BlockDelay+hand.params.TrialInterval*hand.params.NStimPerEpoch)/1000+0.1)
            start(Stimsession)
            pause((hand.params.BlockDelay+hand.params.TrialInterval*hand.params.NStimPerEpoch)/1000+0.1)
            stop(Stimsession)
            stop(Recsession)
            %[data,time] = read(Recsession, 'all');
            %[env, ~] = data(:,1);
            %expe.envelopes = [expe.envelops env];
            %expe.time = [expe.time time];
            %expe.TTL = [expe.TTL data(2)];
        end
        
        %save([savePath filesep saveFile], 'expe')
        
        function PlotNewData(src, plotsHandles)
            dataIn = read(src, src.ScansAvailableFcnCount, 'OutputFormat', 'Matrix');
            Fs = src.Rate;

            for h=1:length(plotsHandles)
                [X, ~] = getpoints(plotsHandles{h});
                addpoints(plotsHandles{h}, X(end)+(1:double(src.ScansAvailableFcnCount))/Fs, dataIn(:,h)-h)
                drawnow limitrate
            end
        end
    end

    function StopExperiment(src, event)
        hand.AskStop = true;
    end

end
