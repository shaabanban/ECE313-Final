%% Common setup code and variables.
% vim:expandtab tabstop=4
close all;
clear all;
PLOT_PRE_TASK3_FIGURES =  0;
patients=[];
% Open the result file
%fid = fopen('ECE313_Final_Project_group_zeta.txt', 'w');

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
%fprintf(fid, 'Task 0\n\n');
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
    patient.genAlarmsMl=[];
patient.genAlarmsMAP=[];
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
    
    patient.H1 = sum(patient.trainingLabels) / size(patient.trainingLabels, 2);
    % H1 is the probability that there is a patient abnomality.
    patient.H0 = 1.0 -  patient.H1;
    
    
    training_matrix=[];
    testing_matrix=[];
    
    for j=1:7
        training_matrix=[training_matrix,{ crosstab_f(patient.trainingGolden(j,:),patient.trainingNonGolden(j,:),patient.H0,patient.H1)}];
        testing_matrix=[testing_matrix,{crosstab_f(patient.testingGolden(j,:),patient.testingNonGolden(j,:),patient.H0,patient.H1)}];
    end;
    
    patient.testing_matrix=testing_matrix;
    patient.training_matrix=training_matrix;
    
    %calculate alarms
    alarms_ml=zeros(7,size(patient.testingData.area,2));
    alarms_map=zeros(7,size(patient.testingData.area,2));
    false_alarms_map=zeros(7,size(patient.testingData.area,2));
    missed_alarms_map=zeros(7,size(patient.testingData.area,2));
    false_alarms_ml=zeros(7,size(patient.testingData.area,2));
    missed_alarms_ml=zeros(7,size(patient.testingData.area,2));
    for j=1:7
        current_test_data=all_data(j,sizetesting:end);
        for k=1:size(patient.testingData.area,2)
            [~,idx]=ismember([current_test_data(k)],patient.training_matrix{j}(:,1),'rows');  %ML
            if idx~=0
                alarms_ml(j,k)=patient.training_matrix{j}(idx,4);
                alarms_map(j,k)=patient.training_matrix{j}(idx,5);
            end
            if patient.testingLabels(k) == 1
                if alarms_ml(j,k) == 0   %missed alaram ml
                    missed_alarms_ml(j,k)=1;
                end
                if alarms_map(j,k) == 0  %missed alaram map
                    missed_alarms_map(j,k)=1;
                end
            else
                if alarms_ml(j,k) == 1              %false alaram ml
                    false_alarms_ml(j,k)=1;
                end
                if alarms_map(j,k) == 1              %false alaram map
                    false_alarms_map(j,k)=1;
                end
            end;
        end;
    end;
    patient.alarms_ml=alarms_ml;
    patient.alarms_map=alarms_map;
    patient.false_alarms_map=false_alarms_map;
    patient.false_alarms_ml=false_alarms_ml;
    patient.missed_alarms_map=missed_alarms_map;
    patient.missed_alarms_ml=missed_alarms_ml;
    
    
    patients=[patients,patient];
    
end


%% Task 0 Cleanup
% Delete temporary variables from our loop.
clearvars patient trgolden trnongolden gcntr ngcntr sizetraining ...
    sizetesting sizetotal idx data_mean_area_per_file ...
    data_mean_r2r_per_file data_bpm_per_file data_p2p_per_file ...
    data_systolic_per_file data_diastolic_per_file ...
    data_pulse_per_file labels_per_file current_test_data i j k;

%% Task 1
% 1.1

p_H0 = (NUM_PATIENTS);
p_H1 = (NUM_PATIENTS);

HT_table_array = cell(9, 7);
Error_table_array = cell(9, 7);
all_map_err=cell(0,3);
all_ml_err=cell(0,3);
all_comb_corr=cell(0,4);
all_comb_corr2=cell(0,3);

all_p_dat=zeros(7,0);
for i = 1:NUM_PATIENTS
    % Calculate H0 and H1.
    
    if PLOT_PRE_TASK3_FIGURES == 1
        figure
    end
    for j = 1:7
        HT_table_array(i, j) = {patients(i).training_matrix{j}};
        etable=zeros(2,3);
        etable(1,1)=sum(patients(i).false_alarms_ml(j,:))/(size(patients(i).testingLabels,2)-sum(patients(i).testingLabels));
        etable(1,2)=sum(patients(i).missed_alarms_ml(j,:))/(sum(patients(i).testingLabels));
        etable(1,3)=(sum(patients(i).false_alarms_ml(j,:))+sum(patients(i).missed_alarms_ml(j,:)))/size(patients(i).testingLabels,2);
        
        etable(2,1)=sum(patients(i).false_alarms_map(j,:))/(size(patients(i).testingLabels,2)-sum(patients(i).testingLabels));
        etable(2,2)=sum(patients(i).missed_alarms_map(j,:))/(sum(patients(i).testingLabels));
        etable(2,3)=(sum(patients(i).false_alarms_map(j,:))+sum(patients(i).missed_alarms_map(j,:)))/(size(patients(i).testingLabels,2));
        
        Error_table_array(i, j)={etable};
        all_map_err(size(all_map_err,1)+1,:)={i,j,etable(2,3)};
        all_ml_err(size(all_ml_err,1)+1,:)={i,j,etable(1,3)};
        
        if PLOT_PRE_TASK3_FIGURES == 1
            %h0
            subplot(7,1,j)
            plot(patients(i).training_matrix{j}(:,1), ...
                patients(i).training_matrix{j}(:,2), 'r');
            %h1
            hold on
            plot(patients(i).training_matrix{j}(:,1), ...
                patients(i).training_matrix{j}(:,3), 'b');
            
            switch j
                case 1
                    title('Mean Area under the heart beat');
                case 2
                    title('Mean R-to-R peak interval');
                case 3
                    title('Number of beats per minute');
                case 4
                    title('Peak to peak interval for blood pressure');
                case 5
                    title('Systolic Blood Pressure');
                case 6
                    title('Diastolic Blood Pressure');
                case 7
                    title('Pulse Pressure');
            end
            legend('H1 pmf','H0 pmf');
        end % PLOT_PRE_TASK3_FIGURES == 1
    end
    % H0 is the probability that there is no patient abnomality
    all_p_dat=[all_p_dat,patients(i).all];
    % Tabulate a feature to get its frequency data.
    for j=1:7
        for k=j:7
            if k~=j
                
                corr1 = corrcoef(patients(i).all(j,:), patients(i).all(k,:));
                all_comb_corr(size(all_comb_corr,1)+1,:)={i,j,k,corr1(1,2)};
                
                %fprintf('Patient %i, Properties %i %i : %f \n',i,j,k, corr1(1,2));
            end;
        end;
    end;
    %fprintf('\n\n\n\n');
end % i to NUM_PATIENTS
%fprintf('ML\n');

for j=1:7
    for k=j:7
        if k~=j
            
            corr1 = corrcoef(all_p_dat(j,:), all_p_dat(k,:));
            all_comb_corr2(size(all_comb_corr2,1)+1,:)={j,k,corr1(1,2)};
            
            % fprintf('Patient %i, Properties %i %i : %f \n',i,j,k, corr1(1,2));
        end;
    end;
end;

all_ml_err=sortrows(all_ml_err,3);
%fprintf('MAP\n');
all_map_err=sortrows(all_map_err,3);


%% Task 1.1 Cleanup
clearvars corr1 i j k;


%% Task 3.1
% We will work with some stuff related to features 1 and 5.
[Joint_HT_table_p1,patient] = doTask3dot1abc( HT_table_array(1,:),patients(1));
patients(1)=patient;
[Joint_HT_table_p3,patient] = doTask3dot1abc( HT_table_array(3,:),patients(3));
patients(3)=patient;
[Joint_HT_table_p5,patient] = doTask3dot1abc( HT_table_array(5,:),patients(5));
patients(5)=patient;

Joint_HT_table={Joint_HT_table_p1,Joint_HT_table_p3,Joint_HT_table_p5};


%% Task 3.1 Cleanup
clearvars Joint_HT_table_p1 Joint_HT_table_p3 Joint_HT_table_p5


%% Final Cleanup
% Remove variables used in the code that do not help us interpret output.
clearvars PLOT_PRE_TASK3_FIGURES filenames NUM_DATA_CELLS NUM_PATIENTS
%fclose(fid);
