close all;

% HOGs parameters
CellSize = [64 64];
BlockSize = [2 2];
BlockOverlap = ceil(BlockSize/2);
NumBins = 9;

I = imread('../data/leaf1/l1nr001.tif'); % the path to one image
I = square(I);
I = imresize(I,[512 512]);
I = rgb2gray(I);
features = extractHOGFeatures(I,'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap,'NumBins',NumBins);
hogFeatureSize = length(features);


%% feature extraction

files = dir('../data/leaf*/*.tif'); % all the image files
n = length(files);

inputs = zeros(hogFeatureSize,n);
targets = zeros(15,n);

tic
for i=1:n
    folder = files(i).folder;
    fn = files(i).name;
    
    I = imread(strcat(folder,'/',fn));
    I = square(I);
    I = imresize(I,[512 512]);
    I = rgb2gray(I);
    
    [featureVector,hogVisualization] = extractHOGFeatures(I,'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap,'NumBins',NumBins);
    inputs(:,i) = featureVector';
    plot(hogVisualization); drawnow;
    
    class = int32(str2num(fn(2:end-9)));
    targets(class,i) = 1;

    fprintf('Extracting features of %s\n',fn);
end
toc
close all;


%% train

% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainscg';  % Scaled conjugate gradient backpropagation.

% Create a Pattern Recognition Network
hiddenLayerSize = 20;
net = patternnet(hiddenLayerSize, trainFcn);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 0/100;

% Train the Network
[net,tr] = train(net,inputs,targets);
nntraintool('close');

% Test the Network
outputs = net(inputs);
[c,cm] = confusion(targets,outputs);
fprintf('\nTest confusion matrix:\n\n');
disp(cm);
fprintf('accuracy: %f\n',1-c);


%% test

files = dir('../data/test/*.tif');
n = length(files);

truelabels = zeros(15,n);
classout = zeros(15,n);

for i=1:n
    folder = files(i).folder;
    fn = files(i).name;
    
    I = imread(strcat(folder,'/',fn));
    I = square(I);
    I = imresize(I,[512 512]);
    I = rgb2gray(I);

    featureVector = extractHOGFeatures(I,'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap,'NumBins',NumBins);
    classout(:,i) = net(featureVector');
    
    class = int32(str2num(fn(2:end-9)));
    truelabels(class,i) = 1;
    
    fprintf('Predicting class of %s\n',fn);
end

[c,cm] = confusion(truelabels,classout);
fprintf('\nValidation confusion matrix:\n\n');
disp(cm);
fprintf('accuracy: %f\n',1-c);
plotroc(truelabels,classout);