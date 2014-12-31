%% SPEECHRECOGNITION
% A MATLAB simulation of speech recognition based on Mel Frequency 
% Cepstral Coefficients as extracted feature and Dynamc Time Warping as
% similarity measurement
%
%  ARGUMENTS:
%  - featuresList: a struct array Nx1 with fields {name, date, bytes,
%                  isdir, atenum, mfcc} for each WAV sample file
%  - audioFile: (optional) [string] the path of WAV file to process; if not
%               specified an audio signal will be recorded
%
%  OUTPUT:
%  - class:       [string] the recognised class of "audioFile"
%  - minDistance: minimal Dynamc Time Warping distance from a sample file
%  - indexOfMin:  index of the sample file with minimal DTW distance in
%                 "fileList"
%
%% Copyright (C) Luca Lorusso 2014 - Sapienza Universita' di Roma
%
% DETECTVOICED is a MATLAB function from SILENCEREMOVAL, a method for
% silence removal and segmentation of audio streams that contain speech.
%   Home page: <http://www.mathworks.com/matlabcentral/fileexchange/28826-silence-removal-in-speech-signals>
%
% DTW is a MATLAB function from MATCHBOX, a prototype which applies Dynamic
% Time Warping on MFCC features in order to compare two spoken words for
% similarity.
%   Home page: <https://github.com/hfink/matchbox/tree/master/matlab>
%
% MELCEPST is a MATLAB function from VOICEBOX, a library for speech
% processing.
%   Home page: <http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html>
%

%% Initializing data
function [class, minDistance, indexOfMin] = speechRecognition(model, audioFile)
    if nargin > 1 % open audio file
        if exist(audioFile, 'file')
            [targetSignal,sampleRate] = audioread(audioFile);
        else
            error('Audio file does not exist. EXITING!');
        end
    else % record a sound if no file is specified
        sampleRate = 22050;
        localRecorder = audiorecorder(sampleRate, 16, 1);
        localRecorder.StartFcn = 'disp(''SPEAK NOW!!!'')';
        localRecorder.StopFcn = 'disp(''End of recording.'')';

        % recording sound from local recorder sound system
        seconds = 2;
        fprintf('Press a key when you want to speak! (%i sec)\n', seconds);
        pause;
        recordblocking(localRecorder, seconds);
        targetSignal = getaudiodata(localRecorder);
    end
    window_size = 15; % WHAT IS THE BEST VALUE?
    % at this point we have an audio signal... otherwise the function is already terminated!
    
    %% WAV file Mel Frequency Cepstral Coefficient calculation
    targetSignal = detectVoiced(targetSignal, sampleRate); % removing silence from the signal
    if size(targetSignal, 1) > 1 % if it is not a silence signal
        MFCC = melcepst(targetSignal, sampleRate); % MFCC features extraction
    else
        error('No voice detected. EXITING!');
    end
    
    %% Processing samples with Dynamic Time Warping algorithm
    fprintf('Calculating Dynamic Time Warping... ');
    for fileCount = 1 : size(model, 1)
        allDistances(fileCount) = dtw(model(fileCount).MFCC', MFCC', window_size);
    end
    
    %% Finding result
    [minDistance, indexOfMin] = min(allDistances);
    class = model(indexOfMin).typeClass;
    %soundsc(targetSignal, sampleRate); % uncomment this to listen input file
    fprintf('OK, done!\n');
end
