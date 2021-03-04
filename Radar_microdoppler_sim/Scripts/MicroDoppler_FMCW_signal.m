clear all; close all;

Zero_padding = 1;   %to enable zeo padding
FFT_plot = 0;       %to display the fft plot
STFT_plot = 0;      %to display the stft plot
CVD_plot = 1;       %to display the cvd plot
Example1 = 1;
j = sqrt(-1);       %imaginary 'j'
nChirps = 256;

frequency_list_1 = [800, 750, 700, 650, 600, 550, 500, 450, 400, 350, 300, 250];
frequency_list_2 = [250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800];
frequency_list_3 = [650, 600, 550, 500, 450, 400, 400, 450, 500, 550, 600, 650];
frequency_list_4 = [200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750];

% 5 frames STFT output are concatenated to give a single TVD Spectrum
STFT_11 = STFT_on_256_points(0,frequency_list_1,Zero_padding,FFT_plot,STFT_plot);
STFT_21 = STFT_on_256_points(1,frequency_list_2,Zero_padding,FFT_plot,STFT_plot);
STFT_31 = STFT_on_256_points(2,frequency_list_1,Zero_padding,FFT_plot,STFT_plot);
STFT_41 = STFT_on_256_points(3,frequency_list_2,Zero_padding,FFT_plot,STFT_plot);
STFT_51 = STFT_on_256_points(4,frequency_list_1,Zero_padding,FFT_plot,STFT_plot);
Spectrum_STFT_curr = [STFT_11 STFT_21 STFT_31 STFT_41 STFT_51];

STFT_12 = STFT_on_256_points(0,frequency_list_3,Zero_padding,FFT_plot,STFT_plot);
STFT_22 = STFT_on_256_points(1,frequency_list_3,Zero_padding,FFT_plot,STFT_plot);
STFT_32 = STFT_on_256_points(2,frequency_list_3,Zero_padding,FFT_plot,STFT_plot);
STFT_42 = STFT_on_256_points(3,frequency_list_3,Zero_padding,FFT_plot,STFT_plot);
STFT_52 = STFT_on_256_points(4,frequency_list_3,Zero_padding,FFT_plot,STFT_plot);
Spectrum_STFT_prev = [STFT_12 STFT_22 STFT_32 STFT_42 STFT_52];

STFT_13 = STFT_on_256_points(0,frequency_list_2,Zero_padding,FFT_plot,STFT_plot);
STFT_23 = STFT_on_256_points(1,frequency_list_2,Zero_padding,FFT_plot,STFT_plot);
STFT_33 = STFT_on_256_points(2,frequency_list_2,Zero_padding,FFT_plot,STFT_plot);
STFT_43 = STFT_on_256_points(3,frequency_list_2,Zero_padding,FFT_plot,STFT_plot);
STFT_53 = STFT_on_256_points(4,frequency_list_2,Zero_padding,FFT_plot,STFT_plot);
Spectrum_STFT_next = [STFT_13 STFT_23 STFT_33 STFT_43 STFT_53];

Spectrum_STFT_sum = Spectrum_STFT_curr + Spectrum_STFT_prev + Spectrum_STFT_next;

figure(3)
imagesc(0:1:(size(Spectrum_STFT_curr,2)-1),0:1:size(Spectrum_STFT_curr,1)-1,Spectrum_STFT_curr);
xlabel('Time (bins)');
ylabel('Frequency (bin)');
axis('xy')

figure(4)
imagesc(0:1:(size(Spectrum_STFT_prev,2)-1),0:1:size(Spectrum_STFT_prev,1)-1,Spectrum_STFT_prev);
xlabel('Time (bins)');
ylabel('Frequency (bin)');
axis('xy')

figure(5)
imagesc(0:1:(size(Spectrum_STFT_next,2)-1),0:1:size(Spectrum_STFT_next,1)-1,Spectrum_STFT_next);
xlabel('Time (bins)');
ylabel('Frequency (bin)');
axis('xy')

figure(6)
imagesc(0:1:(size(Spectrum_STFT_sum,2)-1),0:1:size(Spectrum_STFT_sum,1)-1,Spectrum_STFT_sum);
xlabel('Time (bins)');
ylabel('Frequency (bin)');
axis('xy')


function [STFT] = STFT_on_256_points(frame_no , frequencylist, zeroPadding, FFT_plot, STFT_plot)

    nChirps = 256;
    NOISE = 0.3;
    window_length = nChirps/4;               %stft doppler resolution 
    step_dist = 4;                           %stft time resolution parameters to be changed by the power of 2
    time_offset = nChirps*frame_no; 
    time  = (0+time_offset):1:(255+time_offset); 
    
    time1 = (0+time_offset):1:(5+time_offset);
    time2 = (246+time_offset):1:(255+time_offset);   
    t10   = (6+time_offset):1:(25+time_offset);
    t11   = (26+time_offset):1:(45+time_offset);
    t12   = (46+time_offset):1:(65+time_offset);
    t13   = (66+time_offset):1:(85+time_offset);
    t14   = (86+time_offset):1:(105+time_offset);
    t15   = (106+time_offset):1:(125+time_offset);
    t16   = (126+time_offset):1:(145+time_offset);
    t17   = (146+time_offset):1:(165+time_offset);
    t18   = (166+time_offset):1:(185+time_offset);
    t19   = (186+time_offset):1:(205+time_offset);
    t20   = (206+time_offset):1:(225+time_offset);
    t21   = (226+time_offset):1:(245+time_offset);
   
    signal10_I = cos(frequencylist(1)*t10);
    signal10_Q = sin(frequencylist(1)*t10); 
     
    signal11_I = cos(frequencylist(2)*t11);
    signal11_Q = sin(frequencylist(2)*t11); 

    signal12_I = cos(frequencylist(3)*t12);
    signal12_Q = sin(frequencylist(3)*t12); 
    
    signal13_I = cos(frequencylist(4)*t13);
    signal13_Q = sin(frequencylist(4)*t13);
   
    signal14_I = cos(frequencylist(5)*t14);
    signal14_Q = sin(frequencylist(5)*t14); 
   
    signal15_I = cos(frequencylist(6)*t15);
    signal15_Q = sin(frequencylist(6)*t15);  
    
    signal16_I = cos(frequencylist(7)*t16);
    signal16_Q = sin(frequencylist(7)*t16); 
    
    signal17_I = cos(frequencylist(8)*t17);
    signal17_Q = sin(frequencylist(8)*t17); 
   
    signal18_I = cos(frequencylist(9)*t18);
    signal18_Q = sin(frequencylist(9)*t18);  
    
    signal19_I = cos(frequencylist(10)*t19);
    signal19_Q = sin(frequencylist(10)*t19); 

    signal20_I = cos(frequencylist(11)*t20);
    signal20_Q = sin(frequencylist(11)*t20); 

    signal21_I = cos(frequencylist(12)*t21);
    signal21_Q = sin(frequencylist(12)*t21); 

    signal_I = [zeros(size(time1)), ...
                signal10_I , signal11_I , signal12_I , signal13_I, ...
                signal14_I , signal15_I , signal16_I , ...
                signal17_I , signal18_I , signal19_I , signal20_I , signal21_I , ...
                zeros(size(time2))] + NOISE*randn(1,length(time));
                
    signal_Q = [zeros(size(time1)), ...
                signal10_Q , signal11_Q , signal12_Q , signal13_Q, ...
                signal14_Q , signal15_Q , signal16_Q , ...
                signal17_Q , signal18_Q , signal19_Q , signal20_Q , signal21_Q , ...
                zeros(size(time2))] + NOISE*randn(1,length(time));
                 
    signal   = signal_I + 1i.*signal_Q;
    % FFT plot
    if FFT_plot == 1
         figure(10*(frame_no+10))
         plot(time,abs(fftshift(fft(signal))));
         xlabel('frequency (bins)');
         ylabel('fft magnitude');
    end
     % STFT computation
     LENX = nChirps;               %size of the input signal
     IMGX = ceil(LENX/step_dist);  %time axis
     IMGY = (window_length);       %frequency axis

     stft_plot = zeros(IMGX,IMGY); %initialize for the spectrogram plot
     
     if zeroPadding == 1
          X = [zeros(1,window_length/2)  signal  zeros(1,window_length/2)]; % 0 padding the input signal
     end
     
     iter = 0;
     for i = 1:step_dist:LENX                         %loop through time
	       iter = iter + 1;                           %time bin
	       windowing = X(i:(i + window_length - 1));  % making window: slide the window accordingly 
	       signal_window = windowing;                 %y(t)=h(t)*w(n-t) -> if window is used , hamming , hanning etc 
	       signalout = abs((fft(signal_window, window_length))); %fft of y(t) gives us stft
	       stft_plot(iter,:) = signalout(1:IMGY);
     end
     
     % STFT visualization (sprectrogram)
     stft_plot_1 = stft_plot';
     row = size(stft_plot_1,1);
     row_mid_1 = row/2;
     
     for index = 1:1:row_mid_1
         swap_1 = stft_plot_1(index,:);
         swap_2 = stft_plot_1(row-index+1,:);
         stft_plot_1(index,:) = swap_2;
         stft_plot_1(row-index+1,:) = swap_1; 
     end 
     
     if STFT_plot == 1
         figure(20*(frame_no+10))
         imagesc(0:1:(IMGX-1),0:1:IMGY,stft_plot_1);
         xlabel('Time (bins)');
         ylabel('Frequency (bin)');
         axis('xy')
     end
     
     STFT = stft_plot_1;
end









