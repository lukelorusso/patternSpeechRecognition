%% EXTRACTFEATURES
% Calculates Mel Frequency Cepstral Coefficients from WAV files and saves
% them to an Nx1 struct array as output (where N is the number of files in
% sample folder).
%
%  ARGUMENTS:
%  - samplesPath: [string] the path where sample WAV files are stored
%
%  OUTPUT:
%  - featuresList: a struct array Nx1 with fields {name, date, bytes,
%                  isdir, datenum, typeClass, MFCC} for each WAV file in
%                  "samplesPath"
%  - model:        a model struct array Nx1 with fields {typeClass, MFCC}
%                  for each word of the vocabulary
%
%% Copyright (C) Luca Lorusso 2014 - Sapienza Universita' di Roma
%
% DETECTVOICED is a MATLAB function from SILENCEREMOVAL, a method for
% silence removal and segmentation of audio streams that contain speech.
%   Home page: <http://www.mathworks.com/matlabcentral/fileexchange/28826-silence-removal-in-speech-signals>
%
% MELCEPST is a MATLAB function from VOICEBOX, a library for speech
% processing.
%   Home page: <http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html>
%

%% Initializing data
function [model, fileFeatures] = extractFeatures(samplesPath)
    if nargin == 0
        samplesPath = '';
    end
    fileFeatures = dir(fullfile(samplesPath, '*.wav'));
    if size(fileFeatures, 1) == 0
        error('No WAV files here. EXITING!');
    end
    typeClassArray{1} = ''; % creating cell array of strings
    typeClassCount = 1;
    
    %% Mel Frequency Cepstral Coefficient extraction: _fileFeatures_
    fprintf('Extracting MFCC feature matrices...\n');
    for fileCount = 1 : size(fileFeatures, 1)
        % filling _fileFeatures_ struct array
        tempFileName = fileFeatures(fileCount).name; % getting file name
        fileFeatures(fileCount).typeClass = tempFileName(4:size(tempFileName, 2)-4); % getting instances' class from file name
        [wavSignal,sampleRate] = audioread(fullfile(samplesPath, fileFeatures(fileCount).name)); % loading sound from WAV file
        wavSignal = detectVoiced(wavSignal, sampleRate); % removing silence from the signal
        fileFeatures(fileCount).MFCC = melcepst(wavSignal, sampleRate); % MFCC features extraction
        
        % filling _typeClass_ field of _model_
        [typeClassAns] = ismember(fileFeatures(fileCount).typeClass, typeClassArray);
        if typeClassAns == 0 % if the current typeClass still does NOT exists
            typeClassArray{typeClassCount} = fileFeatures(fileCount).typeClass; % CAN'T PREALLOCATE!
            typeClassCount = typeClassCount + 1;
        end
    end
    
    %% Dynamic Time Warping and Multivariate Gaussian Mixture Models calculation: _model_
    fprintf('Calculating DTW distances and Gaussian mixture models...\n');
    for typeClassCount = 1 : size(typeClassArray, 2)
        % for each word of the vocabulary creates a selection of _fileFeatures_
        typeClassIndices = find(strcmp({fileFeatures.typeClass}, typeClassArray(typeClassCount)));
        model(typeClassCount) = modelingR(fileFeatures(typeClassIndices)); % DIFFERENT MODELING ALGORITHMS: use _modelingS_ or _modelingR_
    end
    model = model';
    fprintf('OK, done!\n');
end
