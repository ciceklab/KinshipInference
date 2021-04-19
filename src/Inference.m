clc;
clear;

mainPath = "";

% Read Family Data
Mothers = readtable(strcat(mainPath, "/kinship/Mothers.csv"));
Mothers = array2table(table2array(Mothers(:, 2:end)).', 'VariableNames', Mothers{:, 1}, 'RowNames', Mothers.Properties.VariableNames(2:end));

Fathers = readtable(strcat(mainPath, "/kinship/Fathers.csv"));
Fathers = array2table(table2array(Fathers(:, 2:end)).', 'VariableNames', Fathers{:, 1}, 'RowNames', Fathers.Properties.VariableNames(2:end));

Children = readtable(strcat(mainPath, "/kinship/Children.csv"));
Children = array2table(table2array(Children(:, 2:end)).', 'VariableNames', Children{:, 1}, 'RowNames', Children.Properties.VariableNames(2:end));

Remaining = readtable(strcat(mainPath,"/kinship/Remaining.csv"));
Remaining = array2table(table2array(Remaining(:, 2:end)).', 'VariableNames', Remaining{:, 1}, 'RowNames', Remaining.Properties.VariableNames(2:end));

% Load MAF, LD 
AFs = readtable(strcat(mainPath, "/AF_CEU_all_chromosomes.txt"), 'Delimiter', ',' );
AFs = sortrows(AFs, 3);

LDScore1 = readtable(strcat(mainPath, "/ld_new20_CEU_07_sortedM.txt"));
LDs = digraph(LDScore1{:,4},LDScore1{:,5},LDScore1{:,11});
LDs = addedge(LDs, LDScore1{:,5},LDScore1{:,4},LDScore1{:,12});

NN = 60;
test_size = 20;
query_count = 25;

% Case-Control selection
case_ind = randperm(size(Children, 1), test_size);
control_ind = randperm(size(Remaining, 1), test_size);  

% Outside control people
out_control = setdiff([1:size(Remaining, 1)], control_ind);
pos1 = randperm(size(out_control, 2), NN-2*test_size);

% Outside family members
out_case = setdiff([1:size(Children, 1)], case_ind);
pos2 = randperm(size(out_case, 2), NN-2*test_size);

for test_type=[0:3]

    if test_type == 0 % Only Mother
        Beacon = [Mothers(case_ind,:); Children(case_ind,:); Fathers(out_case(:, pos2(1:test_size/2)),:); Mothers(out_case(:, pos2(test_size/2 + 1:test_size)),:)];
    elseif test_type == 1 % Only Father
        Beacon = [Fathers(case_ind,:); Children(case_ind,:); Fathers(out_case(:, pos2(1:test_size/2)),:); Mothers(out_case(:, pos2(test_size/2 + 1:test_size)),:)];
    elseif test_type == 2 % Both Mother and Father
        Beacon = [Mothers(case_ind,:); Fathers(case_ind,:); Children(case_ind,:)];
    else % No one
        Beacon = [Children(case_ind,:); Remaining(out_control(:, pos1),:)];
        Beacon = [Beacon; Fathers(out_case(:, pos2(1:test_size/2)),:); Mothers(out_case(:, pos2(test_size/2 + 1:test_size)),:)];
    end
    for control=[0:1]
        if control == 0 % Case People
            test_group = Children(case_ind,:);
        else % Control People
            test_group = Remaining(control_ind,:);
        end
        Attack(Beacon, test_group, query_count, AFs, LDs, true, test_type, control);
        for t=["QI", "Optimal"]
            PlotPower(t, test_type, query_count);
        end
    end
end



