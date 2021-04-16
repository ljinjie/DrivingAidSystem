%clear all;
data = load('my_dataset_8.mat');
pretrained = load('ourdetector6.mat');
detector = pretrained.vehicleDetector;
%detector = pretrained.detector;

%path = data.gTruth.DataSource.Source;
%vehicleDataset = data.gTruth.LabelData;

%label = table(path, vehicleDataset);

trainingDataTable = objectDetectorTrainingData(data.gTruth);
options = trainingOptions('sgdm',...
    'MaxEpochs',20,...
    'MiniBatchSize',32,...
    'InitialLearnRate',1e-6);

%modelfile = 'digitsDAGnet.h5';
%lgraph = importKerasNetwork(modelfile);

%vehicleDetector = trainFasterRCNNObjectDetector(label, lgraph, options, 'NegativeOverlapRange', [0 0.3]);
vehicleDetector = trainYOLOv2ObjectDetector(trainingDataTable, detector, options);

