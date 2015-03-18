% Load the specified model into memory and returns a "key" to that file.
m = MOTIF_if('AD9625_2500.pmf');

if (~m.isLoaded())
    disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
    return
end

% Simulation parameters
% NOTE: Product configuration is found in AD9680_Configuration.m
fclk = 2500e6;  % Converter sample rate
numOfSamples = 2^17;
latency = 1024;
infreq = 241.1e6;
    
% Return the relevant properties of the current ADC
props = m.queryPropValues();

% Make sure the clock frequency doesn't exceed maximum allowable value
max_fclk = str2double(props('settings.clkmax'));
if (fclk > max_fclk)
   fclk = max_fclk;
   disp('Warning: fclk(i) too fast.  It will be coerced to maximum sample rate of converter');
end

nBits = str2double(props('settings.nbits'));
commonMode = str2double(props('settings.offset'));
inputSpan = str2double(props('settings.range'));
extJitter = str2double(props('settings.extjitter'));
outputMode = props('settings.outputmode');

% Sweep parameters
inAmpStart = -1;
inAmpStop = -90;
Nsteps = 64;
deltaInAmp = (inAmpStop - inAmpStart) / Nsteps;

SFDRresults = zeros(1,Nsteps);
range = 1:Nsteps;
for i = range
    % Calculate coherent frequency (assumes numOfSamples is a power of 2)
    nCycles = floor(infreq * numOfSamples / fclk / 2) * 2 + 1;
    spectrumCenter = nCycles / numOfSamples * fclk;

    % Create a normalized frequency to generate the sinewave.
    frequency = spectrumCenter / fclk * numOfSamples;

    % Convert spectrumLevel_dB into a peak amplitude voltage.
    spectrumLevel_dB = inAmpStart + deltaInAmp * (i-1);
    amplitude = (inputSpan / 2) * 10 ^ (spectrumLevel_dB / 20);

    % Generate a sinewave voltage input to the model.
    n = 0:(numOfSamples+latency-1);
    sinewave = amplitude * exp(1i * 2 * pi * frequency * n / numOfSamples) + commonMode * (1 + 1i);

    % Configure the simulation.
    AD9625_Configure(m, fclk, spectrumCenter, extJitter);

    % Run the model
    [codes, interface] = m.runSamples(sinewave);

    % Trim the output data to ignore startup transients
    codes = codes(latency*interface.r+1:numOfSamples*interface.r+latency*interface.r);
    SFDRresults(i) = sfdr(codes);
end

xaxis = inAmpStart + deltaInAmp * (range - 1);
plot(xaxis, SFDRresults, xaxis, SFDRresults-xaxis);
ylim([0 100]);  
xlabel('Amplitude (dB)');
ylabel('SFDR (dBFS)');