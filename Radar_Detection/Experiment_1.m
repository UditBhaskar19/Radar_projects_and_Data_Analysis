clear all; clc; close all;

% Extract 1 Radar Frame
path_get_frame = 'Radar_frame_samples/three_ped_walking_in_circle/';
frameID = 100;
Frame = load(strcat(path_get_frame, 'Frame_',num2str(frameID), '.mat'));
Frame = Frame.FRAME;  %(sampleIdx, virtualantennaIdx, chirpIdx)  (128, 8, 128)

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

% Initialize Datastructures for Range-Doppler FFT
Range_Doppler_FFT_all = complex(zeros(nADCsamples, nVirtualAntenna, nChirps), zeros(nADCsamples, nVirtualAntenna, nChirps));
Range_Doppler_FFT_sum = complex(zeros(nADCsamples, nChirps), zeros(nADCsamples, nChirps));

% Initialize Datastructures for Range FFT
Range_FFT_all = complex(zeros(nADCsamples, nVirtualAntenna, nChirps), zeros(nADCsamples, nVirtualAntenna, nChirps));
Range_FFT_sum = complex(zeros(nADCsamples, nChirps), zeros(nADCsamples, nChirps));

% Initialize Datastructures for Doppler FFT
Doppler_FFT_all = complex(zeros(nADCsamples, nVirtualAntenna, nChirps), zeros(nADCsamples, nVirtualAntenna, nChirps));
Doppler_FFT_sum = complex(zeros(nADCsamples, nChirps), zeros(nADCsamples, nChirps));

% Training Cell and Gauard Cell Parameters for CFAR
nTr = 5;  % Number of Training Cells for Range bins
nGr = 2;  % Number of Guard Cells for Range bins
nTd = 5;  % Number of Training Cells for Doppler bins
nGd = 2;  % Number of Guard Cells for Doppler bins
kernalSizeRange = 2*(nTr + nGr) + 1; % Compute Kernel size along Range bins
kernalSizeDoppler = 2*(nTd + nGd) + 1; % Compute Kernel size along Range bins

% CFAR 1D (2 CFAR Kernals each for range and doppler )
CA_CFAR_Kernal_Range = ones(kernalSizeRange,1);
CA_CFAR_Kernal_Range((nTr + 1):(nTr + 2*nGr + 1),1) = 0;
CA_CFAR_Kernal_Range = CA_CFAR_Kernal_Range/(2*nTr);
CA_CFAR_Kernal_Doppler = ones(kernalSizeDoppler,1);
CA_CFAR_Kernal_Doppler((nTd + 1):(nTd + 2*nGd + 1),1) = 0;
CA_CFAR_Kernal_Doppler = CA_CFAR_Kernal_Doppler/(2*nTd);

% CFAR 2D (CFAR Kernal for range and doppler )
CA_CFAR_Kernal_2D = ones(kernalSizeRange,kernalSizeDoppler);
CA_CFAR_Kernal_2D((nTr + 1):(nTr + 2*nGr + 1), (nTd + 1):(nTd + 2*nGd + 1)) = 0;
n = sum(sum(CA_CFAR_Kernal_2D,1),2);
CA_CFAR_Kernal_2D = CA_CFAR_Kernal_2D/n;

% START PROCESSING THE FRAME
% ==============================================================================================================================================================
% perform DC-Offset Removal along the range bins
for i = 1:nVirtualAntenna
    for chirpIdx = 1:nChirps
        sumFrameSample = sum(Frame(:,i,chirpIdx),1);
        avgSumFrameSample = sumFrameSample/nADCsamples;
        Frame(:,i,chirpIdx) = Frame(:,i,chirpIdx) - avgSumFrameSample;
    end
end
% ==============================================================================================================================================================
% Range Doppler FFT (2D-FFT)
for i = 1:nVirtualAntenna
    for chirpIdx = 1:nChirps
        Range_Doppler_FFT_all(:,i,chirpIdx) = fft(Frame(:,i,chirpIdx));
    end
    for sampleIdx = 1:nADCsamples
        Range_Doppler_FFT_all(sampleIdx,i,:) = fft(Range_Doppler_FFT_all(sampleIdx,i,:));
    end
end
for i = 1:nVirtualAntenna
    Range_Doppler_FFT_sum(:,:) = Range_Doppler_FFT_sum(:,:) + reshape(Range_Doppler_FFT_all(:,i,:), [nADCsamples, nChirps]);
end
% ==============================================================================================================================================================
% CFAR-1D-Range
% CFAR-1D-Doppler
% CFAR-2D-Range_doppler
% ==============================================================================================================================================================
% Angle of Arrival Estimation (AOA)
% Capon, Barlette, MUSIC
% ==============================================================================================================================================================
% 5D Clustering (x,y,z,doppler,rcs)
% ==============================================================================================================================================================
% Track Clusters (use data association and filtering techniques)
% ==============================================================================================================================================================
% estimate other high level information 
% target classification by rcs
% micro-doppler signatures
% target trajectory
% etc
% ==============================================================================================================================================================
% Range FFT (1D-FFT)
for i = 1:nVirtualAntenna
    for chirpIdx = 1:nChirps
        Range_FFT_all(:,i,chirpIdx) = fft(Frame(:,i,chirpIdx));
    end
end
for i = 1:nVirtualAntenna
    Range_FFT_sum(:,:) = Range_FFT_sum(:,:) + reshape(Range_FFT_all(:,i,:), [nADCsamples, nChirps]);
end
% ==============================================================================================================================================================
% Doppler FFT (1D-FFT)
for i = 1:nVirtualAntenna
    for sampleIdx = 1:nADCsamples
        Doppler_FFT_all(sampleIdx,i,:) = fft(Frame(sampleIdx,i,:));
    end
end
for i = 1:nVirtualAntenna
    Doppler_FFT_sum(:,:) = Doppler_FFT_sum(:,:) + reshape(Doppler_FFT_all(:,i,:), [nADCsamples, nChirps]);
end
% ==============================================================================================================================================================



virtualAntennaIdx = 1;
%DopplerSpectrum = abs(fftshift(reshape(Doppler_FFT_all(:,virtualAntennaIdx,:), [128,128])));
DopplerSpectrum = abs(fftshift(Doppler_FFT_sum));
%DopplerSpectrum(:,size(DopplerSpectrum,2)/2 + 1) = 0;  % removing the doppler center line
figure(1);
imagesc(Doppler_from_doppler_bins, 1:1:length(Range_from_range_bins), (DopplerSpectrum));

RangeSpectrum = abs(reshape(Range_FFT_all(:,virtualAntennaIdx,:), [128,128]));
figure(2);imagesc(Doppler_from_doppler_bins, Range_from_range_bins, (RangeSpectrum));

figure(3);
for chirpIdx = 1:nChirps  %Plot of all of the range bins
    plot(Range_from_range_bins, abs(Range_FFT_all(:,virtualAntennaIdx,chirpIdx)));hold on;
end
hold off;

figure(4);
for sampleIdx = 1:nADCsamples  %Plot of all of the doppler bins 
    fftShiftedData = fftshift(Doppler_FFT_all(sampleIdx,virtualAntennaIdx,:));
    fftShiftedData = reshape(fftShiftedData, size(Doppler_from_doppler_bins));
    plot(Doppler_from_doppler_bins, abs(fftShiftedData));hold on;
end
hold off;