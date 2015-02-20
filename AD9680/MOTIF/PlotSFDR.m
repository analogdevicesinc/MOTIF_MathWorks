% Load the specified model into memory and returns a "key" to that file.
m = MOTIF_if('AD9680_1000.pmf');

if (~m.isLoaded())
    disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
    return
end

% Simulation parameters
% NOTE: Product configuration is found in AD9680_Configuration.m
spectrumLevel_dB = -1;
fclk = 1000e6;  % Converter sample rate
numOfSamples = 2^18;
latency = 256;

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
infreqStart = 10.3e6;
infreqStop = 497.3e6;
Nsteps = 32;
SFDRresults = zeros(Nsteps);
deltaInfreq = (infreqStop - infreqStart) / Nsteps;
range = 1:Nsteps;
for i = range
    % Calculate input frequency
    infreq = infreqStart + deltaInfreq * (i-1);

    % Calculate coherent frequency (assumes numOfSamples is a power of 2)
    nCycles = floor(infreq * numOfSamples / fclk / 2) * 2 + 1;
    spectrumCenter = nCycles / numOfSamples * fclk;

    % Create a normalized frequency to generate the sinewave.
    frequency = spectrumCenter / fclk * numOfSamples;

    % Convert spectrumLevel_dB into a peak amplitude voltage.
    amplitude = (inputSpan / 2) * 10 ^ (spectrumLevel_dB / 20);

    % Generate a sinewave voltage input to the model.
    n = 0:(numOfSamples+latency-1);
    sinewave = amplitude * exp(1i * 2 * pi * frequency * n / numOfSamples) + commonMode * (1 + 1i);

    % Configure the simulation.
    AD9680_Configure(m, fclk, spectrumCenter, extJitter);

    % Run the model
    [codes, interface] = m.runSamples(sinewave);

    % Trim the output data to ignore startup transients
    codes = codes(latency*interface.r+1:numOfSamples*interface.r+latency*interface.r);
    SFDRresults(i) = sfdr(codes);
end

plot(infreqStart + deltaInfreq * (range - 1), SFDRresults);
ylim([50 90]);  
xlabel('Sample Rate (Hz)');
ylabel('SFDR (dBFS)');