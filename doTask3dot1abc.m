% vim:expandtab tabstop=4

% Does all things related to Task 3.1 parts (a) through (c).
% It creates the decision rules for ML and MAP using the training data.
function [Joint_HT_table, patient,res] = doTask3dot1abc(HT_table_array,patient,par1,par2,bluewaters)
% We will be working with features 1 and 5.
% The columns of Joint_HT_table are as follows:
% 1: X = i; Feature 1's values put in rows.
% 2: Y = j; Feature 5's values put in rows. Must match rows with row 1.
% 3: P(X=i,Y=j | H1); Prob. that X=i & Y=j where a golden alarm was at.
% 4: P(X=i,Y=j | H0); Prob. that X=i & Y=j where a golden alarm was not at.
% 5: ML Predicted Label.
% 6: MAP Predicted Label.
meanarea=HT_table_array{par1};
pararr=[{patient.testingData.area},{patient.testingData.rr},{patient.testingData.bpm},...
    patient.testingData.p2p_bp,patient.testingData.systolic,patient.testingData.diastolic,...
    patient.testingData.pulse_pr];
systolic=HT_table_array{par2};
Joint_HT_table = cell(0, 6);
for i=1:size(meanarea,1)
    for j=1:size(systolic,1)
        ph1=meanarea(i,2)*systolic(j,2);
        ph0=meanarea(i,3)*systolic(j,3);
        ml=0;
        map=0;
        if ph1>=ph0
            map=1;
        end;
           if ph1/(patient.H1*patient.H1)>=ph0/(patient.H0 * patient.H0)
            ml=1;
        end;
Joint_HT_table(size(Joint_HT_table,1)+1,:)=[{meanarea(i,1)},{systolic(j,1)},{ph1},{ph0},{ml},{map}];
end
end


%H1

%H1
if bluewaters==0
figure
subplot(2,1,1)
[jj,j2,j2] = unique(cell2mat(Joint_HT_table(:,2)));
[ii,i2,i2] = unique(cell2mat(Joint_HT_table(:,1)));
out = [[NaN,ii'];
[jj,accumarray([j2,i2],cell2mat(Joint_HT_table(:,3)),[],[],NaN)]];
mesh(out(1,2:end),out(2:end,1),out(2:end,2:end));
ylabel('Pulse Pressure')
xlabel('Mean Area under the heart beat')
zlabel('P(X,Y|H1)')

title(['Patient',' ',int2str(patient.pnum)])

%H0
subplot(2,1,2)
out = [[NaN,ii'];
[jj,accumarray([j2,i2],cell2mat(Joint_HT_table(:,4)),[],[],NaN)]];
mesh(out(1,2:end),out(2:end,1),out(2:end,2:end));
ylabel('Pulse Pressure ')
xlabel('Mean Area under the heart beat')
zlabel('P(X,Y|H0)')
end;
testing_area=cell2mat(pararr(par1));
testing_systolic=cell2mat(pararr(par2));
alarms_ml=zeros(length(testing_area));
alarms_map=zeros(length(testing_area));
missed_ml=0;
missed_map=0;
false_ml=0;
false_map=0;

for i=1:length(testing_area)
     [~,idx]=ismember([testing_area(i),testing_systolic(i)],cell2mat(Joint_HT_table(:,1:2)),'rows');
        if idx ~=0
            talarms_ml(i)=Joint_HT_table(idx,5);
            talarms_map(i)=Joint_HT_table(idx,6);
            if patient.testingLabels(i)==1          %golden alarm
                if talarms_ml{i} == 0           %miss ml
                     missed_map=missed_map+1;
                end;
                 if talarms_map{i} == 0          %miss map
                     missed_ml=missed_ml+1;
                 end;
            else
                 if talarms_ml{i} == 1           %false ml
                       false_ml=false_ml+1;
                 end;
                 if talarms_map{i} == 1          %false map
                     false_map=false_map+1;
                 end;
            end;
        end;
end;
patient.genAlarmsMl=cell2mat(talarms_ml);
patient.genAlarmsMAP=cell2mat(talarms_map);

patient.testingLabels

figure
subplot(3,1,1)
bar(patient.genAlarmsMl)

subplot(3,1,2)
bar(patient.genAlarmsMAP)

subplot(3,1,3)
bar(patient.testingLabels)


res=zeros(2,3);
res(1,1)=false_ml/(length(patient.testingLabels)-sum(patient.testingLabels));
res(1,2)=missed_ml/(sum(patient.testingLabels));
res(1,3)=(missed_ml+false_ml)/length(patient.testingLabels);
res(2,1)=false_map/(length(patient.testingLabels)-sum(patient.testingLabels));
res(2,2)=missed_map/(sum(patient.testingLabels));
res(2,3)=(missed_map+false_map)/length(patient.testingLabels);
end