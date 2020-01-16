function [selected_JMI,time_JMI] = JMI_continue(index, b, para, para_JMI)
%This is the breakpoint enabled version
%input: index of the data that will be used
%and amount of features need to be selected
%b is the bootstrapping indices
%fe is the subset of feature space to be used
%@para is a matrix containing two elements: first one is feature number previously selected, 
%second one is feature number need to select in this step
%@para_FJMI is the previous record, first row is the previously selected feature vector
%second row is the previous time vector
%output: seleced features and time matrices

fid = fopen('/home/hengl/FAMIR/names2');
file_name = {};
for i=1:30
    line = fgets(fid);
    if ischar(line)
        file_name{i} = line;
    end
end
expression = '[A-Za-z0-9-_]*';
for i=1:30
    str = regexp(file_name{i}, expression);
    file_name{i} = file_name{i}(1: str(1,2)-2);
end
i = index;   %Which datasets want to use
path = strcat('/home/hengl/FAMIR/data/', file_name{i}, '.mat');
file = load(path);
data = struct2cell(file);
data = data{1};
f = size(data,2)-1;
data = data(b,:);
y = data(:, size(data,2));


k1 = para(1);  %previous amount of feature selected
k2 = para(2);  %amount of feature need to be selected in this run
selected_JMI = para_JMI(1,:); %keep the selected feature subset
time_JMI = para_JMI(2,:); %acquire the previous time vector
time_base = time_JMI(k1);  %The base of time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
feature_set = [1:f]; %To get rid of the all-zero columns
feature_set = setdiff(feature_set, selected_JMI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start = tic;
for q=(k1+1):k2  %select k features
    ma = 0;
    pin = 0;     %to keep track of the feature that is about to select
    for i=feature_set
        temp = 0;    %to keep track of the current sum of culmuative joint mutual information
        for j=selected_JMI
                    jo = joint([data(:,i),data(:,j)],[]);
                    temp = temp + mi(jo,y);
        end
        if ma < temp
            ma = temp;
            pin = i;
        end
    end
    selected_JMI = [selected_JMI pin];
    feature_set = feature_set(feature_set ~= pin);
    
    
    time_JMI = [time_JMI (toc(start)+time_base)];
end     


