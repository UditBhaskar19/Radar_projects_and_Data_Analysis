clear all; close all;

% Radar settings for data set "one_ped_walking"
path_get_frame = 'Radar_frame_samples/three_ped_walking_in_circle/';

% Radar Frame Structure Details for Radar Cube
nFrames = 300;
nADCsamples = 128;
nTx = 2;
nRx = 4;
nVirtualAntenna = nTx*nRx;
nChirps = 128;
nChirpsAllantenna = nChirps*nTx;

% Data sampling configuration
c = 299792458;               % Speed of light (m/s)
sampleRate = 2500;           % Rate at which the radar samples from ADC (ksps - kilosamples per second)
freqSlope = 60.012;          % Frequency slope of the chirp (MHz/us)
startFreq = 77.4201;         % Starting frequency of the chirp (GHz)
idleTime = 30;               % Time before starting next chirp (us)
rampEndTime = 62;            % Time after sending each chirp (us)

% Range Resolution
freqSlope_hz_per_sec = (freqSlope * 1e6)/(1e-6);
sampleRate_sps = sampleRate*1e3;
ChirpBandwidth = (freqSlope_hz_per_sec)*nADCsamples/sampleRate_sps;
range_res = c/(2*ChirpBandwidth); % m
Range_from_range_bins = (1:1:nADCsamples)*range_res - range_res;

% Doppler Resolution
startFreq_hz = startFreq * 1e9;
idleTime_s = idleTime * 1e-6;
rampEndTime_s = rampEndTime * 1e-6;
doppler_res = c/(2 * startFreq_hz * (idleTime_s + rampEndTime_s) * nChirps * nTx);  % m/s
Doppler_from_doppler_bins = ((1:1:nChirps) - nChirps/2)*doppler_res - doppler_res;