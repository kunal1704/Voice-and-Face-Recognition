clear all
close all
clc

num_users = 3; 
num_samples = 5; 



data_dir = '/home/interstellar/DSP_proj/'; % Add your file path where the program is running.


function record_sample(file_path)
    recObj = audiorecorder;
    disp('Start speaking.');
    recordblocking(recObj, 5); 
    disp('End of Recording.');
    y = getaudiodata(recObj);
    audiowrite(file_path, y, recObj.SampleRate);
end

for i = 1:num_users
    for j = 1:num_samples
        file_path = [data_dir 'user' num2str(i) '_sample' num2str(j) '.wav'];
        if ~exist(file_path, 'file')
            disp(['Recording sample: ' file_path]);
            record_sample(file_path);
        end
    end
end

features = [];
labels = [];

% Extract features from the recorded samples
for i = 1:num_users
    for j = 1:num_samples
        file_path = [data_dir 'user' num2str(i) '_sample' num2str(j) '.wav'];
        if exist(file_path, 'file')  
            [y, Fs] = audioread(file_path);
            coeffs = mfcc(y, Fs);
            meanCoeffs = mean(coeffs, 1);
            features = [features; meanCoeffs];
            labels = [labels; i];
        else
            disp(['File not found: ' file_path]);
        end
    end
end

if size(features, 1) <= size(features, 2)
    error('Not enough valid feature vectors to fit the model.');
end

% Trains the SVM model
SVMModel = fitcecoc(features, labels);

test_sample_path = [data_dir 'test_sample.wav'];
if exist(test_sample_path, 'file')
    delete(test_sample_path);
end

disp('Recording test sample:');
record_sample(test_sample_path);

% This extracts features from the test sample
[y, Fs] = audioread(test_sample_path);
coeffs = mfcc(y, Fs);
meanCoeffs = mean(coeffs, 1);

% This predicts which user it is
label = predict(SVMModel, meanCoeffs);

disp(['Identified User: ' num2str(label)]);
