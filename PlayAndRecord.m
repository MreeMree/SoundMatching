
fileReader = dsp.AudioFileReader( ...
        'AmpAh01.wav', ...
        'SamplesPerFrame',64, ...
        'PlayCount',1);
fileWriter = dsp.AudioFileWriter(...
            'ExtTargetCheck.wav',...
            'FileFormat','WAV');
deviceReader = audioDeviceReader('SamplesPerFrame',fileReader.SampleRate);
setup(deviceReader);
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);

% Mic prep
d = daq.getDevices;
dev = d(2);

s = daq.createSession('directSound');
addAudioInputChannel(s, dev.ID, 1:2);

s.IsContinuous = true;
addlistener(s, 'DataAvailable', @PlayRecord);
startBackground(s);
function PlayRecord
    
 while ~isDone(fileReader)
            acquiredAudio = deviceReader();
            audioIn = fileReader();

            drawnow limitrate
            audioOut = audioIn;

            deviceWriter(audioOut);
            fileWriter(acquiredAudio);
            
 end
    release(fileReader);
    release(deviceWriter);
    release(deviceReader);
    release(fileReader);
h=1
stop(s)
end