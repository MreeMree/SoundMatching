d = daq.getDevices

%% 
dev = d(2)

%% 

s = daq.createSession('directsound');
addAudioInputChannel(s, dev.ID, 1:2);

freq = s.Rate;
loudMtr = loudnessMeter('SampleRate',freq/2);
s.UserData.loudMtr = loudMtr

s.IsContinuous = true;

f = figure; %('DeleteFcn',@(x) stop(src));
subplot(211);
    s.UserData.sh1 = plot(zeros(1000,1));
subplot(212);
    s.UserData.sh2 = bar( 0 ); ylim([-80 -70]);
momentary = [];

hl = addlistener(s, 'DataAvailable', @plotData);
% wl = addlistener(f, 'Visible', 'PostSet', @stopS );

startBackground(s);

function plotData(src,event)
    subplot(2,1,1);
    % hold on; 
    plot(event.TimeStamps,event.Data); %xlim([0 10])
    set(src.UserData.sh2,'ydata',nanmean(src.UserData.loudMtr(event.Data(:,1))));
end