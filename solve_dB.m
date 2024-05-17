% solve gain for -1.78 dB
% then work out gain for 3 other dB levels: -1.93, -1.78, -1.63, -1.48

% blue _ -1.48 _ loudest
% yellow _ -1.63 _ 
% green _ -1.78 _
% red _ -1.93 _ quietest

[amp,~] = audioread('RecordedAh.wav');

[~,dB] = loudMtr(amp)    

syms amp_gain;
eqn = log10( sqrt( mean( (amp(end-2*fs+1:end).*amp_gain).^2 ) ) ) == -1.78
g = solve(eqn,amp_gain)
g = abs(double(g))
g = g(1)

amp = amp*g;

[~,dB] = loudMtr(g*amp(end-2*fs+1:end)) % should = -1.78

%% write to file... AmpAh01.wav
% solve for -1.48

[amp,~] = audioread('AmpAh01.wav');

[~,dB] = loudMtr(amp(end-2*fs+1:end)) % should = -1.78

syms amp_gain;
eqn = log10( sqrt( mean( (amp(end-2*fs+1:end).*amp_gain).^2 ) ) ) == -1.48
g = solve(eqn,amp_gain)
g = abs(double(g))
g = g(1)

% g should = 1.9953

[~,dB] = loudMtr(g*amp(end-2*fs+1:end)) % should be -1.48

%% solve for -1.63

[amp,~] = audioread('AmpAh01.wav');

[~,dB] = loudMtr(amp(end-2*fs+1:end)) % should = -1.78

syms amp_gain;
eqn = log10( sqrt( mean( (amp(end-2*fs+1:end).*amp_gain).^2 ) ) ) == -1.63
g = solve(eqn,amp_gain)
g = abs(double(g))
g = g(1)

% g should = 1.4125

[~,dB] = loudMtr(g*amp(end-2*fs+1:end)) % should be -1.63

%% solve for -1.93

[amp,~] = audioread('AmpAh01.wav');

[~,dB] = loudMtr(amp(end-2*fs+1:end)) % should = -1.78

syms amp_gain;
eqn = log10( sqrt( mean( (amp(end-2*fs+1:end).*amp_gain).^2 ) ) ) == -1.93
g = solve(eqn,amp_gain)
g = abs(double(g))
g = g(1)

% g should = 0.7079

[~,dB] = loudMtr(g*amp(end-2*fs+1:end)) % should be -1.93
