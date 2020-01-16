function [selected_FJMI,time_FJMI] = FJMI(index, k, threshold, b)

%Input: index of the data that will be used
%and amount of features need to be selected
%and the threshold will be used
%b is the bootstrapping indices
%fe is a subset of the feature space to be used
%Output: seleced features and time matrices


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

%Which datasets want to use
i = index;
path = strcat('/home/hengl/FAMIR/data/', file_name{i}, '.mat');
file = load(path);
data = struct2cell(file);
data = data{1};
f = size(data,2)-1;
data = data(b,:);
y = data(:, size(data,2));


selected_FJMI = []; %keep the selected feature subset
current = 0; %keep track of the current selected feature 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ma = 0;%keep track of the max of the mutual information regarding the label
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

selected_FJMI = [selected_FJMI current];
feature_set = feature_set(feature_set ~= current);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start = tic;  %start to count time
ma = 0; %keep track of the max of the culmuative joint mutual information
% k = 100; %k is the number desired to select
time_FJMI = [0];

for q=1:k-1  %select k features
    ma = 0;
    pin = 0;     %to keep track of the feature that is about to select
    
    for i=feature_set 
        temp = 0;    %to keep track of the current sum of culmuative joint mutual information
        
        if size(selected_FJMI,2) <= threshold %we select threshold+1 features
            for j=selected_FJMI
                    jo = joint([data(:,i),data(:,j)],[]);
                    temp = temp + mi(jo,y);
            end
        else
            table1 = []; %Samples Using to train: variable1
            table2 = []; %Samples Using to train: variable2
            table3 = []; %Samples Using to train: response 
            count = 0;
            for j=selected_FJMI
                item1 = rele(i);
                item2 = rele(j);
                item3 = mi(data(:,i),data(:,j));
                count = count + 1;
                if count <= threshold
                    table1 = [table1;item1+item2-item3];          %lower bound
                    table2 = [table2;item1+item2+max([item1, item2, item3])+min([item1, item2, item3])]; %higher bound
                    table3 = [table3;mi(joint([data(:,i),data(:,j)],[]),y)];
                end
                if count == threshold
                    temp = sum(table3);   %THE measurement of joint mututal infor that needs to be updated
                    x = [ones(threshold,1) table1 table2];
                    para = (x'*x)\x'*table3;
                    beta0 = para(1);
                    beta = para(2:3);
                end
                if count > threshold
                    bounds = [item1+item2-item3  item1+item2+max([item1, item2, item3])+min([item1, item2, item3])];
                    temp = temp + (bounds*beta+beta0);
                end
            end
        end
        if ma < temp
            ma = temp;
            pin = i;
        end
    end

    selected_FJMI = [selected_FJMI pin];
    feature_set = feature_set(feature_set ~= pin);
    

    time_FJMI = [time_FJMI toc(start)];
end

