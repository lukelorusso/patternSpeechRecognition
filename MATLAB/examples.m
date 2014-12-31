%% EXAMPLES
% Test drive for functions.

%% Silence removal
[wavSignal, sampleRate] = audioread('example.wav');
[wavSignal, segments] = detectVoiced(wavSignal, sampleRate, 1);

%% Compare similarities of two WAV files
[minimumDistance, d, g, path, mfccA, mfccB] = wavCompare('it_wave/00_modifica.wav', 'it_wave/05_modifica.wav', 1);

%% Calculating DTW and mGMM from two MFCCs
[mfccReshaped, mfccC] = gaussMM(mfccA, mfccB, 1);

%% Extracting features and building model
model = extractFeatures('it_wave');

%% Speech Recognition
selection = [1, 4, 6, 7, 8, 10]; % words to be recognized
[class, minDistance] = speechRecognition(model(selection), 'it_wave/01_sposta.wav');
selection = [2, 3, 5, 9]; % words to be recognized
[class, minDistance] = speechRecognition(model(selection), 'it_wave/04_cubo.wav');
