function UISoundMatching11(parameter,parameterMin,parameterMax)

% Set parameters
x = parameterRef();
x.name = 'gain';
x.value = 1;
parameter = x;

TargetDB = 0;
fs = 44100;
amp_gain = [];
syms amp_gain;
amp = [];
trial = [];
loudSmoothing = 1;
gain_array = [0.7079 1.0 1.4125 1.9953];
% gain_array = [1.07965 1 0.921348 0.842697];
duration = 4;

voiceTargetIndex = 1;
voiceTargetGainList = [ ones(1,15) 2*ones(1,15) 3*ones(1,15) 4*ones(1,15) ];
voiceTargetGainList = voiceTargetGainList( randperm(length(voiceTargetGainList)) );

extTargetIndex = 1;
extTargetGainList = [ ones(1,15) 2*ones(1,15) 3*ones(1,15) 4*ones(1,15) ];
extTargetGainList = extTargetGainList( randperm(length(extTargetGainList)) );

recObj = audiorecorder(fs,16,1);

% Map slider position to specified range
rangeVector = linspace(parameterMin,parameterMax,1001);
[~,idx] = min(abs(rangeVector-parameter.value));
initialSliderPosition = idx/1000;

% Main figure
hMainFigure = figure( ...
    'Name', 'Parameter Tuning', ...
    'OuterPosition',[ 300 250 1400 800 ],...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'HandleVisibility','on', ...
    'NumberTitle','off', ...
    'IntegerHandle','off',...
    'WindowState','normal',...
    'DeleteFcn',@saveData);

for K = 1:4
    ax(K) = subplot(2,2,K);
    ax(K).Visible = 'off';
end

seconds = linspace(0,duration+1,fs*(duration+1));

    % Pause button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String','Pause', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,700,70,40], ...
        'BackgroundColor',[0.7 0.3 0.4], ...
        'Callback', @rest);
    % Sequence button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String','Sequence', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,640,70,40], ...
        'BackgroundColor',[0.3 0.8 0.1], ...
        'Callback', @Sequence);

    % Slider to tune parameter
    c = uicontrol('Parent',hMainFigure, ...
        'Style','slider', ...
        'Position',[80,20,400,23], ...
        'Value',initialSliderPosition, ...
        'SliderStep',[0.06 0.1],...
        'Callback',@slidercb, ...
        'BackgroundColor',[1 1 0]);
    
     % Save button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String','Save', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,580,70,40], ...
        'BackgroundColor',[0.7 0.3 0.4], ...
        'Callback', @saveData);
    
    % Record button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String','Record', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,460,70,40], ...
        'BackgroundColor',[0.7 0.3 0.4], ...
        'Callback', @recordstart);
    
    % Mic button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Mic', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,400,70,40], ...
        'BackgroundColor',[0.2 0.2 0.3], ...
        'Callback', @startMic);
    
    % Stop(s) button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Stop', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,340,70,40], ...
        'BackgroundColor',[0.7 0.1 0], ...
        'Callback', @stopS);
    
    % Externally generated sound button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Ext. target', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,280,70,40], ...
        'BackgroundColor',[0.2 0 0.4], ...
        'Callback', @extTarget);
    
    % Self-generated target button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Voice target', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,220,70,40], ...
        'BackgroundColor',[0.3 0.1 0.3], ...
        'Callback', @voiceTarget);
    
    % Dial match button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Dial match', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,160,70,40], ...
        'BackgroundColor',[0.9 0.5 0.1], ...
        'Callback', @dialMatch);
    
    % Voice match button
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String', 'Voice match', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,100,70,40], ...
        'BackgroundColor',[0.8 0.4 0], ...
        'Callback', @voiceMatch);
    
    % Compress button - to run without new record
    btn = uicontrol('Parent',hMainFigure, ...
        'Style', 'pushbutton', ...
        'String','Compress', ...
        'ForegroundColor', 'White', ...
        'FontWeight', 'Bold', ...
        'Position', [40,520,70,40], ...
        'BackgroundColor',[0.7 0.3 0.4], ...
        'Callback', @compress);
    
    % Label for slider
    uicontrol('Parent',hMainFigure, ...
        'Style','text',...
        'Position',[10,15,70,23],...
        'String',parameter.name);
    
    % Display current parameter value
    paramValueDisplay = uicontrol('Parent',hMainFigure, ...
        'Style','text',...
        'Position', [490,15,50,23],...
        'BackgroundColor','white',...
        'String',parameter.value);
    
    uicontrol(c);
    
    AAexpTrialList = [ ones(1,30) 2*ones(1,30) 3*ones(1,30) 4*ones(1,30) ];
    seq = AAexpTrialList(randperm(length(AAexpTrialList)));
    seq1 = seq(1:30); seq2 = seq(31:60);
    seq3 = seq(61:90); seq4 = seq(91:120);
    seq = [seq1 5 seq2 5 seq3 5 seq4 6];
            
    function Sequence(~,~)
        for n = (1:length(seq))
            switch (seq(n))
                case 1  % extTarget then dialMatch
                    extTarget
                    pause(2)
                    dialMatch
                    pause(2)
                case 2  % extTarget then voiceMatch
                    extTarget
                    pause(2)
                    voiceMatch
                    pause(2)
                case 3  % voiceTarget then dialMatch
                    voiceTarget
                    pause(2)
                    dialMatch
                    pause(2)
                case 4  % voiceTarget then voiceMatch
                    voiceTarget
                    pause(2)
                    dialMatch
                    pause(2)
                case 5 % break
                    rest
                    pause(2)
                case 6
                    disp('FINISHED!')
                otherwise
                    warning('Undefined!!')
            end
        end    
    end 
    
%     function StopSequence(~,~)
        
        function saveData(~,~)
            save(['TrialData_' strrep(strrep(char(datetime),' ','_'),':','') '.mat'],'trial');
        end  
    
        function rest(~,~)
            prompt = 'Rest. Press return to continue.'
            input(prompt)
            uicontrol(c)
        end
    % Update parameter value if slider value changed
    function slidercb(slider,~)
        val = get(slider,'Value');
        rangeVectorIndex = round(val*1000)+1;
        parameter.value = rangeVector(rangeVectorIndex);
        set(paramValueDisplay,'String',num2str(parameter.value));
%         vals = evalin('base','rangeVectorIndex');
        assignin('base','var',val);
    end

% Set up for recording
    addpath('C:\MATLAB\R2018a\examples\audio')
    
% Voice target button - T2
    function voiceTarget(~,~)
        colour_array = {'Blue' 'Yellow' 'Green' 'Red'};
        gain = gain_array( voiceTargetGainList(voiceTargetIndex) )
        target_colour = colour_array{ voiceTargetGainList(voiceTargetIndex) }
        
        text(ax(1),0.5,0.7,'TARGET','HorizontalAlignment','center','FontSize',14)
        text(ax(1),0.5,0.4,'Say AH!','HorizontalAlignment','center','FontSize',14)
        
        global Y
        [~,TdB_blue] = loudMtr(gain_array(4)*Y(end-2*fs+1:end))
        [~,TdB_yellow] = loudMtr(gain_array(3)*Y(end-2*fs+1:end))
        [~,TdB] = loudMtr(Y(end-2*fs+1:end))
        [~,TdB_red] = loudMtr(gain_array(1)*Y(end-2*fs+1:end))
        
        switch target_colour
            case 'Blue'
                text(ax(1),0.5,0.3,'Hit the blue bar','HorizontalAlignment','center','Color','blue','FontSize',14)
%                 tB = text(ax(3),1,TdB_blue,'Here','HorizontalAlignment','center')
            case 'Yellow'
                text(ax(1),0.5,0.3,'Hit the yellow bar','HorizontalAlignment','center','Color','yellow','FontSize',14)
%                 tY = text(ax(3),1,TdB_yellow,'Here','HorizontalAlignment','center')
            case 'Green'
                text(ax(1),0.5,0.3,'Hit the green bar','HorizontalAlignment','center','Color','green','FontSize',14)
%                 tG = text(ax(3),1,TdB,'Here','HorizontalAlignment','center')
            case 'Red'
                text(ax(1),0.5,0.3,'Hit the red bar','HorizontalAlignment','center','Color','red','FontSize',14)
%                 tR = text(ax(3),1,TdB_red,'Here','HorizontalAlignment','center')
            otherwise
                warning('No colour???')
        end
        
        pause(1)
        gain
        
        trial(end+1).type = 'voiceTarget';
        disp(['Trial ' num2str(length(trial))]);
        disp('Voice target')
                
        if ( voiceTargetIndex > length(voiceTargetGainList) )
            voiceTargetIndex = 1;
        end
        
        startMic
        record(recObj)
        pause(duration)
        stop(recObj)
        stopS
        voiceTargetIndex = voiceTargetIndex + 1;
        
        trial(end).gain = gain;
        [~,trial(end).voiceTargetDB] = loudMtr( gain*Y(end-2*fs:end) );
        
%         cla(ax(4)); legend(ax(4),'off')
%         hold(ax(4),'on');
%         plot(ax(4),seconds(1:length(Y)),(smooth(loudMtr(Y*gain),loudSmoothing)),'Visible','off');
%         set(ax(4),'Visible','off')
        cla(ax(1))
%         delete('tB','tY','tG','tR')
        assess_voiceTarget
    end

% assess voice target
    function assess_voiceTarget
        vt = getaudiodata(recObj);
%         hold(ax(2),'on');
%         plot(ax(2),seconds(1:length(vt)),(smooth(loudMtr(vt),loudSmoothing)),'Visible','off');
%         set(ax(2),'Visible','off')
        [~,trial(end).voice_target_check] = loudMtr(vt(end-fs*2+1:end));
    end

% Record button
    function recordstart(~,~)
        fileWriter = dsp.AudioFileWriter(...
            'RecordedAh.wav',...
            'FileFormat','WAV');
        disp('Say AAAHHH');
        figure; xdata = (1:(duration+2)*fs)/fs; ydata = nan(size(xdata)); k = 0;
        h = plot( xdata, ydata ); xlim([0 length(xdata)/fs]);
        deviceReader = audioDeviceReader('SamplesPerFrame',0.1*fs);
        setup(deviceReader);
        tic;
    while toc < (duration+2)
        acquiredAudio = deviceReader();
        [~,loudDB] = loudMtr( acquiredAudio );
        ydata(k+(1:length(acquiredAudio))) = loudDB;
        k = k + length(acquiredAudio);
        set(h,'ydata',ydata); drawnow;
        fileWriter(acquiredAudio);
    end
        release(deviceReader);
        release(fileWriter);
        disp('Recording complete.');
        %figure; plot(acquiredAudio);
        compress
    end 

% voiceMatch button - M2
    function voiceMatch(~,~)
        trial(end).type2 = 'voiceMatch';
        disp(['Trial ' num2str(length(trial))]);
        disp('Voice Match')
        
        text(ax(2),0.5,0.7,'TARGET','HorizontalAlignment','center','FontSize',14)
        text(ax(2),0.5,0.4,'Say AH! Match the previous volume','HorizontalAlignment','center','FontSize',14)
        
        fileWriter = dsp.AudioFileWriter(...
            'VoiceMatchAh.wav',...
            'FileFormat','WAV');
        disp('Match volume with voice: GO!');
        deviceReader = audioDeviceReader;
        setup(deviceReader);
        pause(1)
        tic;
    while toc < duration
        acquiredAudio = deviceReader();
        fileWriter(acquiredAudio);
    end
        release(deviceReader);
        release(fileWriter);
        disp('Match complete.');
        cla(ax(2))
        assess_voiceMatch
    end 

% Assess voice match
    function assess_voiceMatch
        [vm,~] = audioread('VoiceMatchAh.wav');
%         vm = amp_gain*vm(end-fs*8+1:end);
%         vmplot = [seconds(1:length(vm)),loudMtr(vm)]
%         
%         cla(ax(2)); plot(ax(2),seconds(1:length(vm)),vm)
%         set(ax(2),'Visible','off')

%         plot(ax(4),seconds(1:length(vm)),smooth(loudMtr(vm),loudSmoothing)); 
%         legend(ax(4),'Target','Voice Match','Location','southeast'); 
%         set(ax(4),'Visible','off'); hold(ax(4),'off')
%         
        [~,voice_match] = loudMtr(vm(end-fs*2+1:end))
        trial(end).voice_match = voice_match;
    end


% Compress
    function compress(~,~)
        [amp,~] = audioread('RecordedAh.wav');
        amp = amp(end-fs*duration+1:end);
        
        [~,dB] = loudMtr(amp)
                
        eqn = log10( sqrt( mean( (amp(end-2*fs+1:end).*amp_gain).^2 ) ) ) == -1.78
        g = solve(eqn,amp_gain)
        g = abs(double(g))
        g = g(1)
        
        amp = amp*g;
        
        ampEnvelope = linspace(0,1,fs);
        ampEnvelope(fs+1:fs*duration) = 1;
        ampEnvelope = ampEnvelope';

        amp = amp.*ampEnvelope;
        
        fileWriter = dsp.AudioFileWriter(...
            'AmpAh01.wav',...
            'FileFormat','WAV');
        fileWriter(amp);
        release(fileWriter);
        
        [~,TdB_blue] = loudMtr(gain_array(4)*amp(end-2*fs+1:end))
        [~,TdB_yellow] = loudMtr(gain_array(3)*amp(end-2*fs+1:end))
        [~,TdB] = loudMtr(amp(end-2*fs+1:end))
        [~,TdB_red] = loudMtr(gain_array(1)*amp(end-2*fs+1:end))
        
        ax(3); hold on; line(ax(3),[0 2],[TargetDB TargetDB]+(TdB_blue),'Color','b'); 
             line(ax(3),[0 2],[TargetDB TargetDB]+TdB_yellow,'Color','y');
             line(ax(3),[0 2],[TargetDB TargetDB]+(TdB),'Color','g');
             line(ax(3),[0 2],[TargetDB TargetDB]+(TdB_red),'Color','r'); 
             ylim(ax(3),[ TdB-0.4 TdB+0.5 ]);
             set(ax(3),'Visible','on'); hold(ax(3),'off')

        range_max_min = [range(loudMtr(amp(end-fs*2:end))),max(loudMtr(amp(end-fs*2:end))),min(loudMtr(amp(end-fs*2:end)))]
        
        global Y
        [Y,~] = audioread('AmpAh01.wav');
    end


% Mic prep
d = daq.getDevices;
dev = d(2);

s = daq.createSession('directSound');
addAudioInputChannel(s, dev.ID, 1:2);

freq = s.Rate;
%loudMtr = loudnessMeter('SampleRate',freq);
s.UserData.loudMtr = @loudMtr;

s.IsContinuous = true;
addlistener(s, 'DataAvailable', @plotMic);
 
% ax(4); 
subplot(224); s.UserData.sp1 = plot(zeros(1000,1));
s.UserData.sp2 = bar( ax(3), 0 ); ylim(ax(3),[TargetDB-2.2 TargetDB-1.4]); 

    function startMic(~,~)
        disp('startMic works')
        startBackground(s);
    end

    function plotMic(~,event)
%         ax(4);
        subplot(224);
        plot(event.TimeStamps,event.Data);
        [~,loudDB] = loudMtr(event.Data(:,1));
        set(s.UserData.sp2,'ydata',loudDB);
    end

    function stopS(~,~)
        stop(s);
        disp('Listener stopped.')
    end

% output object for playback
    deviceWriter = audioDeviceWriter('SampleRate',freq);
% T1
    function extTarget(~,~)
        trial(end+1).type = 'extTarget';
        disp(['Trial ' num2str(length(trial))]);
        disp('External target')
        text(ax(1),0.5,0.7,'TARGET','HorizontalAlignment','center','FontSize',14)
        text(ax(1),0.5,0.4,'Listen.','HorizontalAlignment','center','FontSize',14)
        
        global gain
%         gain = randi([1 4])
%         gain_array = [1.07965 1 0.921348 0.842697];
%         gain = gain_array(randi(length(gain_array)))
        gain = gain_array( extTargetGainList(extTargetIndex) )
%         gain = 1;

        fileReader = dsp.AudioFileReader( ...
        'AmpAh01.wav', ...
        'SamplesPerFrame',64, ...
        'PlayCount',1);
    
            while ~isDone(fileReader)
            audioIn = fileReader();

            drawnow limitrate
            audioOut = audioIn*gain;

            deviceWriter(audioOut);
            record(recObj)
            end
            stop(recObj)
        global Y
        [~,external_target] = loudMtr(gain*Y(end-2*fs+1:end))
        [~,t1] = loudMtr(Y)
        trial(end).external_target = external_target;
        
        et = getaudiodata(recObj);
        lengthRecSecs = length(et)/44100
        
        [~,trial(end).external_target_check] = loudMtr(et(end-2*fs+1:end));
        
        extTargetIndex = extTargetIndex + 1;
        
        release(fileReader);
        release(deviceWriter);
        
        cla(ax(1))
%         legend(ax(4),'off')
%         cla(ax(4)); 
%         hold(ax(4),'on');
%         plot(ax(4),seconds(1:length(Y)),smooth(loudMtr(Y*gain),loudSmoothing));
%         set(ax(4),'Visible','off')
    end

% Dial match  - M1

    function dialMatch(~,~)
        x.value = 0;
        c.Value = 0;
        
        trial(end).type2 = 'dialMatch';
        disp(['Trial ' num2str(length(trial))]);
        disp('Dial match')
        text(ax(2),0.5,0.7,'MATCH','HorizontalAlignment','center','FontSize',14)
        text(ax(2),0.5,0.4,'Turn the dial to match the previous volume','HorizontalAlignment','center','FontSize',14)
        
%         dial_gain = 0.960674;
        
        uicontrol(c);
        global Y
        
        fileReader = dsp.AudioFileReader( ...
        'AmpAh01.wav', ...
        'SamplesPerFrame',64, ...
        'PlayCount',1);
    
        while ~isDone(fileReader)
            audioIn = fileReader();
            
            drawnow limitrate
            audioOut = audioIn*x.value;
            
            deviceWriter(audioOut);
            record(recObj)    
        end
        stop(recObj)
        dial_adjusted = Y*x.value;
%         cla(ax(2)); plot(ax(2),seconds(1:length(dial_adjusted)),dial_adjusted);
%         set(ax(2),'Visible','off')
        
        [~,mean_dial] = loudMtr(dial_adjusted(end-2*fs+1:end))
        trial(end).mean_dial = mean_dial;
        
        dm = getaudiodata(recObj);
        [~,trial(end).mean_dial_check] = loudMtr(dm(end-2*fs+1:end));
        
%         plot(ax(4),seconds(1:length(dial_adjusted)),smooth(loudMtr(dial_adjusted),loudSmoothing));
%         plot(ax(4),seconds(1:length(dm)),smooth(loudMtr(dm),loudSmoothing));
%         legend(ax(4),'Target','Dial Match','Dial Match check','Location','southeast');
%         set(ax(4),'Visible','off')
%         hold(ax(4),'off')
        
        release(fileReader);
        release(deviceWriter);
        cla(ax(2))
    end

trial.mysettings.micLevel = '100';
trial.mysettings.micBoost = '+12.0 dB';
trial.mysettings.NoiseSupression = 'off';
trial.mysettings.ImmediateMode = 'off';
trial.mysettings.Advanced = 'CD quality 44100 Hz';
trial.mysettings.ComputerVolume = 50;
trial.mysettings.SpeakerVolume = '100%';
trial.mysettings.SliderLimits = [parameterMin parameterMax];
trial.mysettings.GainArray = gain_array;

settings = trial.mysettings

end
