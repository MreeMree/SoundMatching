% play recording for calibration

[y,freq] = audioread('RecordedAh.wav');

[~,fulldB] = loudMtr(y)
[~,halfdB] = loudMtr(y(end-(length(y)/2):end))


%% play back
fileReader = dsp.AudioFileReader( ...
        'RecordedAh.wav', ...
        'SamplesPerFrame',64, ...
        'PlayCount',1);

deviceWriter = audioDeviceWriter('SampleRate',freq);

    
            while ~isDone(fileReader)
                audioIn = fileReader();

                drawnow limitrate
                audioOut = audioIn;

                deviceWriter(audioOut);
            
            end
            
release(fileReader)
release(deviceWriter)