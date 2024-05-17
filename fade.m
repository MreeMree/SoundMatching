% fade in
[amp,~] = audioread('AmpAh01.wav');

ampEnvelope = linspace(0,1,88200);
ampEnvelope(88201:352800) = 1;
ampEnvelope = ampEnvelope';

fade_amp = amp.*ampEnvelope;

figure; plot(fade_amp)


%% something else
% mean loudMtr of second half of signal 

mean(loudMtr(vm(end-length(vm)/2:end)))

% mean loudMtr of last 2 seconds

mean(loudMtr(vm(end-88200:end)))