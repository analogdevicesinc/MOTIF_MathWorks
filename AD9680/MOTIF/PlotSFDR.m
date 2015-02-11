% Load the specified model into memory and returns a "key" to that file.
m = MOTIF_if('AD9680_1000.pmf');

if (~m.isLoaded())
    disp('Error: Could not open file!  Check to see if you have the model file downloaded in your path.');
    return
end

% Simulation parameters
% NOTE: Product configuration is found in AD9680_Configuration.m
spectrumLevel_dB = -1;
numOfSamples = 2^16;
latency = 256;
    
% Set the input tone frequency (Fin)
infreq = 170.3e6;

for i =1:31
fclk(i) = (7+(i-1)*0.1)*1e8; % converter sample rate

% Calculate coherent frequency (assumes numOfSamples is a power of 2)
nCycles = floor(infreq * numOfSamples / fclk(i) / 2) * 2 + 1;
spectrumCenter = nCycles / numOfSamples * fclk(i);

% Return the relevant properties of the current ADC
props = m.queryPropValues();

% Make sure the clock frequency doesn't exceed maximum allowable value
max_fclk = str2double(props('settings.clkmax'));
if (fclk(i) > max_fclk)
   fclk(i) = max_fclk;
   disp('Warning: fclk(i) too fast.  It will be coerced to maximum sample rate of converter');
end

nBits = str2double(props('settings.nbits'));
commonMode = str2double(props('settings.offset'));
inputSpan = str2double(props('settings.range'));
extJitter = str2double(props('settings.extjitter'));
outputMode = props('settings.outputmode');

% Create a normalized frequency to generate the sinewave.
frequency = spectrumCenter / fclk(i) * numOfSamples;

% Convert spectrumLevel_dB into a peak amplitude voltage.
amplitude = (inputSpan / 2) * 10 ^ (spectrumLevel_dB / 20);

% Generate a sinewave voltage input to the model.
n = 0:(numOfSamples+latency-1);
sinewave = amplitude * exp(1i * 2 * pi * frequency * n / numOfSamples) + commonMode * (1 + 1i);

% Configure the simulation.
AD9680_Configure(m, fclk(i), spectrumCenter, extJitter);

% Run the model
[codes, interface] = m.runSamples(sinewave);

% Trim the output data to ignore startup transients
codes = codes(latency*interface.r+1:numOfSamples*interface.r+latency*interface.r);
sfdrresults(i) = sfdr(codes);
end

plot(fclk,sfdrresults);
ylim([80 90]);  
xlabel('Sample Rate (Hz)');
ylabel('SFDR (dBFS)');