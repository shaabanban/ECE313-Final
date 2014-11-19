%% Common setup code and variables.
% vim:noexpandtab tabstop=4
close all;
clear all;
patients=[];
% Open the result file
fid = fopen('ECE313_Final_Project_group_zeta.txt', 'w');

% Definitions of all_data rows. From slide 5.
DATA_MEAN_HEART_BEAT_AREA =     1;
DATA_MEAN_R2R_PEAK_INTERVAL =   2;
DATA_BPM_HEART_RATE =           3;
DATA_P2P_BLOOD_PRESSURE =       4;
DATA_SYSTOLIC_BLOOD_PRESSURE =  5;
DATA_DIASTOLIC_BLOOD_PRESSURE = 6;
DATA_PULSE_PRESSURE =           7;

% Indices into the array of cells.
DATA_CELL_RAW =         1; % The data read in from the files.
DATA_CELL_TRAINING =    2; % The portion of data used in training.
DATA_CELL_TESTING =     3; % The portion of data used in testing.
NUM_DATA_CELLS =        3;

% All 9 data files.
filenames = {'1_a41178.mat', '2_a42126.mat', '3_a40076.mat', ...
    '4_a40050.mat', '5_a41287.mat', '6_a41846.mat', '7_a41846.mat', ...
    '8_a42008.mat', '9_a41846.mat'};
NUM_PATIENTS =          9;

% The data labels are put into one cell of these cell arrays.
data_mean_area_per_file = cell(NUM_DATA_CELLS,9);
data_mean_r2r_per_file = cell(NUM_DATA_CELLS,9);
data_bpm_per_file = cell(NUM_DATA_CELLS,9);
data_p2p_per_file = cell(NUM_DATA_CELLS,9);
data_systolic_per_file = cell(NUM_DATA_CELLS,9);
data_diastolic_per_file = cell(NUM_DATA_CELLS,9);
data_pulse_per_file = cell(NUM_DATA_CELLS,9);
labels_per_file = cell(1, NUM_PATIENTS);


%% Task 0.
% Load all data files.
fprintf(fid, 'Task 0\n\n');
for i = 1:NUM_PATIENTS
load(filenames{i});
all_data=floor(all_data);
sizetraining=int32(size(all_data,2)*2./3.);
sizetesting=sizetraining+1;
sizetotal=size(all_data);


patient=struct('all',all_data,'labels',all_labels,'trainingData', ...
    struct('area', all_data(1,1:sizetraining),'rr',all_data(2,1:sizetraining), ...
    'bpm',all_data(3,1:sizetraining),'p2p_bp',all_data(4,1:sizetraining), ...
    'systolic',all_data(5,1:sizetraining),'diastolic',all_data(6,1:sizetraining)...
    ,'pulse_pr',all_data(7,1:sizetraining),'golden',all_labels(1,1:sizetraining)),'trainingLabels',all_labels(1,1:sizetraining), ...
    'testingData',struct('area', all_data(1,sizetesting:end),'rr',all_data(2,sizetesting:end), ...
    'bpm',all_data(3,sizetesting:end),'p2p_bp',all_data(4,sizetesting:end), ...
    'systolic',all_data(5,sizetesting:end),'diastolic',all_data(6,sizetesting:end)...
    ,'pulse_pr',all_data(7,sizetesting:end),'golden',all_labels(1,sizetesting:end)),'testingLabels',all_labels(1,sizetesting:end));
trgolden = [];
trnongolden = [];
gcntr=1;
ngcntr=1;
for j=1:sizetraining
    if patient.trainingData.golden(j)==1
        trgolden(1:7,gcntr)=patient.all(1:7,j);
                        gcntr=gcntr+1;
    else
                trnongolden(1:7,ngcntr)=patient.all(1:7,j);
                ngcntr=ngcntr+1;
    end;
end;
    patient.trainingGolden=trgolden;
   patient.trainingNonGolden=trnongolden;

  trgolden = [];
trnongolden = [];
gcntr=1;
ngcntr=1;
for j=1:size(patient.testingData.golden,2)
    k=(j+sizetesting-1);
    if patient.testingData.golden(j)==1
        trgolden(1:7,gcntr)=patient.all(1:7,k);
          gcntr=gcntr+1;
    else
                trnongolden(1:7,ngcntr)=patient.all(1:7,k);
                ngcntr=ngcntr+1;
    end;
end;
    patient.testingGolden=trgolden;
   patient.testingNonGolden=trnongolden;
   training_matrix=[];
testing_matrix=[];

for j=1:7
    training_matrix=[training_matrix,{ crosstab_f(patient.trainingGolden(j,:),patient.trainingNonGolden(j,:))}];
    testing_matrix=[testing_matrix,{crosstab_f(patient.testingGolden(j,:),patient.testingNonGolden(j,:))}];
end;

   patient.testing_matrix=testing_matrix;
   patient.training_matrix=training_matrix;
   
patients=[patients,patient];
[data_mean_area, data_mean_r2r, data_bpm, data_p2p, data_systolic, ...
    data_diastolic, data_pulse] = extract_data(all_data);

% Store the raw data.
data_mean_area_per_file{DATA_CELL_RAW,i} = data_mean_area;
data_mean_r2r_per_file{DATA_CELL_RAW,i} = data_mean_r2r;
data_bpm_per_file{DATA_CELL_RAW,i} = data_bpm;
data_p2p_per_file{DATA_CELL_RAW,i} = data_p2p;
data_systolic_per_file{DATA_CELL_RAW,i} = data_systolic;
data_diastolic_per_file{DATA_CELL_RAW,i} = data_diastolic;
data_pulse_per_file{DATA_CELL_RAW,i} = data_pulse;
labels_per_file{1, i} = all_labels;

% Split the data into training and testing data.
% 2/3 of the data is for training. 1/3 is for testing.
size_data = int32(size(data_mean_area,2));
size_training = 2. / 3. * size_data;
data_mean_area_per_file{DATA_CELL_TRAINING,i} = data_mean_area(:,1:size_training);
data_mean_r2r_per_file{DATA_CELL_TRAINING,i} = data_mean_r2r(:,1:size_training);
data_bpm_per_file{DATA_CELL_TRAINING,i} = data_bpm(:,1:size_training);
data_p2p_per_file{DATA_CELL_TRAINING,i} = data_p2p(:,1:size_training);
data_systolic_per_file{DATA_CELL_TRAINING,i} = data_systolic(:,1:size_training);
data_diastolic_per_file{DATA_CELL_TRAINING,i} = data_diastolic(:,1:size_training);
data_pulse_per_file{DATA_CELL_TRAINING,i} = data_pulse(:,1:size_training);

% Create the testing data.
data_mean_area_per_file{DATA_CELL_TESTING,i} = data_mean_area(:,size_training:size_data);
data_mean_r2r_per_file{DATA_CELL_TESTING,i} = data_mean_r2r(:,size_training:size_data);
data_bpm_per_file{DATA_CELL_TESTING,i} = data_bpm(:,size_training:size_data);
data_p2p_per_file{DATA_CELL_TESTING,i} = data_p2p(:,size_training:size_data);
data_systolic_per_file{DATA_CELL_TESTING,i} = data_systolic(:,size_training:size_data);
data_diastolic_per_file{DATA_CELL_TESTING,i} = data_diastolic(:,size_training:size_data);
data_pulse_per_file{DATA_CELL_TESTING,i} = data_pulse(:,size_training:size_data);
end

% For easier access, we take the 9 cells of our "per_file" cell arrays
% and concatenate them into one massive "collective" matrix.
%
% The "collective" variables store all of our patient data in one matrix
% per data type.
data_mean_area_collective = floor([data_mean_area_per_file{:}]);
data_mean_r2r_collective = floor([data_mean_r2r_per_file{:}]);
data_bpm_collective = floor([data_bpm_per_file{:}]);
data_p2p_collective = floor([data_p2p_per_file{:}]);
data_systolic_collective = floor([data_systolic_per_file{:}]);
data_diastolic_collective = floor([data_diastolic_per_file{:}]);
data_pulse_collective = floor([data_pulse_per_file{:}]);

% Split the data into training and testing data.
% 2/3 of the data is for training. 1/3 is for testing.
%
% Note: This is old code. It is the collective set of training and testing
% data, but that is not used in our project afaik.
size_data = int32(size(data_mean_area_collective,2));
size_training = 2. / 3. * size_data;
data_mean_area_training = data_mean_area_collective(:,1:size_training);
data_mean_r2r_training = data_mean_r2r_collective(:,1:size_training);
data_bpm_training = data_bpm_collective(:,1:size_training);
data_p2p_training = data_p2p_collective(:,1:size_training);
data_systolic_training = data_systolic_collective(:,1:size_training);
data_diastolic_training = data_diastolic_collective(:,1:size_training);
data_pulse_training = data_pulse_collective(:,1:size_training);

% Create the testing data.
data_mean_area_testing = data_mean_area_collective(:,size_training:size_data);
data_mean_r2r_testing = data_mean_r2r_collective(:,size_training:size_data);
data_bpm_testing = data_bpm_collective(:,size_training:size_data);
data_p2p_testing = data_p2p_collective(:,size_training:size_data);
data_systolic_testing = data_systolic_collective(:,size_training:size_data);
data_diastolic_testing = data_diastolic_collective(:,size_training:size_data);
data_pulse_testing = data_pulse_collective(:,size_training:size_data);


%% Task 0 Cleanup
% Delete temporary variables from our loop.
clearvars data_mean_area data_mean_r2r data_bpm data_p2p data_systolic ...
    data_diastolic data_pulse size_data size_training;


%% Task 1
% 1.1

p_H0 = (NUM_PATIENTS);
p_H1 = (NUM_PATIENTS);

H1 = {};
H0 = {};

for i = 1:NUM_PATIENTS
    % Calculate H0 and H1.
    % H0 is the probability that there is no patient abnomality.
    p_H0(i) = sum(patients(i).trainingLabels) / size(patients(i).trainingLabels, 2);
    % H1 is the probability that there is a patient abnomality.
    p_H1(i) = 1.0 - p_H0(i);
    
    % Tabulate a feature to get its frequency data.
    %[freq_mean_area_h1, freq_mean_area_h0] = get_likelihood_h1(patients(i), DATA_MEAN_HEART_BEAT_AREA);
    [H1{i,1}, H0{i,1}] = get_likelihood_h1(patients(i), 1);
    [H1{i,2}, H0{i,2}] = get_likelihood_h1(patients(i), 2);
    [H1{i,3}, H0{i,3}] = get_likelihood_h1(patients(i), 3);
    [H1{i,4}, H0{i,4}] = get_likelihood_h1(patients(i), 4);
    [H1{i,5}, H0{i,5}] = get_likelihood_h1(patients(i), 5);
    [H1{i,6}, H0{i,6}] = get_likelihood_h1(patients(i), 6);
    [H1{i,7}, H0{i,7}] = get_likelihood_h1(patients(i), 7);

    subplot(7,i,1);
    plot(H1{i,1});
    hold on;
    plot(H0{i,1});
    legend('H1 pmf','H0 pmf');
    figure;
    
    
    
end % i to NUM_PATIENTS





%% Task 1.1 Cleanup
clearvars max_val min_val diff lower_bound_zeros upper_bound_zeros;


fclose(fid);
