function [selected_FJMI,time_FJMI] = FJMI_continue(index, threshold, b, para, para_FJMI)
%This is the breakpoint enabled version
%Input: @index of the data that will be used
%and @k amount of features need to be selected
%and the @threshold will be used
%@b is the bootstrapping indices
%@fe is a subset of the feature space to be used
%@para is a matrix containing two elements: first one is feature number previously selected, 
%second one is feature number need to select in this step
%@para_FJMI is the previous record, first row is the previously selected feature vector
%second row is the previous time vector
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


k1 = para(1);  %previous amount of feature selected
k2 = para(2);  %amount of feature need to be selected in this run
selected_FJMI = para_FJMI(1,:); %keep the selected feature subset
time_FJMI = para_FJMI(2,:); %acquire the previous time vector

time_base = time_FJMI(k1);  %The base of time


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ma = 0;%keep track of the max of the mutual information regarding the label
rele = []; %store all the mutual information between feature and label

for i=1:f
    re = mi(data(:,i),y);
    rele = [rele re];
end
feature_set = [1:f]; %To get rid of the all-zero columns


feature_set = setdiff(feature_set, selected_FJMI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start = tic;  %start to count time

for q=(k1+1):k2      %select k2 features
    ma = 0;      %keep track of the max of the culmuative joint mutual information
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
    

    time_FJMI = [time_FJMI (toc(start)+time_base)];
end

