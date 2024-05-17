d = daq.getDevices

%% 
dev = d(2)

%% 

s = daq.createSession('directsound');
addAudioInputChannel(s, dev.ID, 1:2);

s.IsContinuous = true

f = figure;
p = plot(zeros(1000,1));

hl = addlistener(s, 'DataAvailable', @plotData);

startBackground(s);

function plotData(src, event)
plot(event.TimeStamps,event.Data);
length(event.Data)
end