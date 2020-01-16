function [selected_JMI,time_JMI] = JMI(index, k, b)

%input: index of the data that will be used
%and amount of features need to be selected
%b is the bootstrapping indices
%fe is the subset of feature space to be used
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


selected_JMI = []; %keep the selected feature subset
current = 0; %keep track of the current selected feature 
start = tic;  %start to count time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ma = 0;
rele = []; %store all the mutual information between feature and label

for i=1:f
    re = mi(data(:,i),y);
    rele = [rele re];
    if ma < re
        ma = re;
        current = i;
    end
end
feature_set = [1:f]; %To get rid of the all-zero columns

selected_JMI = [selected_JMI current];
feature_set = feature_set(feature_set ~= current);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ma = 0; %keep track of the max of the culmuative joint mutual information
% k = 100; %k is the number desired to select
time_JMI = [0];

start = tic;
for q=1:k-1  %select k features
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
    
    
    time_JMI = [time_JMI toc(start)];
end     


