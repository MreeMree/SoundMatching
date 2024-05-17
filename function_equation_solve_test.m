y = @(x) sin(x)+cos(x)
z = @(x,y) -sin(y)+cos(x)
m = @(x) y(x)-z(x,y(x))
fzero(m,1)

%% 
loudMtr_27 = loudnessMeter('SampleRate',44100,...
    'UseRelativeScale',true,...
    'TargetLoudness',-27)

dRC = compressor(-60,7,...
        'KneeWidth',0,...
        'SampleRate',44100,...
        'AttackTime',0,...
        'MakeUpGain',24);

[y, freq] = audioread('RecordedAh.wav');
y = y(end-44100*8+1:end);

% compressed = dRC(y);

amp = y./sqrt(mean(y.^2));
gain = 1/27;
amp = amp * gain;

% m = @(gain) mean(loudMtr_27(amp*gain))
% fzero(m,gain-27)

% problem.objective = @(gain) abs(mean(loudMtr(amp*gain))+27);
% problem.x0 = 1;
% problem.solver = 'fminsearch'; % a required part of the structure
% problem.options = optimset(@fminsearch); % default options
% problem.options.Display = 'iter';


problem.objective = @(gain) mean(loudMtr(amp*gain))
problem.x0 = 1;
problem.solver = 'fzero';
problem.options = optimset(@fzero);
problem.options.Display = 'iter'



% this worked until loudMtr was replaced with loudMtr_27, 
% and it now takes forever to solve the problem 


%% 

[amp,freq] = audioread('RecordedAh.wav');

        syms amp_gain
        [loud,dB] = loudMtr(amp);
        eqn = dB*amp_gain == -1.7;  
        solve(eqn,'amp_gain')
        amp_gain

        
%%

syms x
eqn = -1.8*x == -1.7
solve(eqn,x)

%% 

syms amp_gain
eqn = dB*amp_gain == -1.7667
gain = solve(eqn,amp_gain)


sym amp_gain
        eqn = mean(loudMtr(amp*amp_gain)) == -1.78
        g = solve(eqn,amp_gain)
        g = double(g)
        
        amp = amp*g;
        
      


        