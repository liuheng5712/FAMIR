% % test to varify the bounds
% clear;clc
% start = tic;
% fid = fopen('/home/hengl/matlab/bin/scripts/FJMI/names2');
% file_name = {};
% for i=1:30
%     line = fgets(fid);
%     if ischar(line)
%         file_name{i} = line;
%     end
% end
% 
% expression = '[A-Za-z0-9-_]*';
% for i=1:30
%     str = regexp(file_name{i}, expression);
%     file_name{i} = file_name{i}(1: str(1,2)-2);
% end
% 
% response = [];
% control = [];
% for i = 25
%         path = strcat('/home/hengl/matlab/bin/scripts/FJMI/data/', file_name{i}, '.mat');
%         file = load(path);
%         data = struct2cell(file);
%         data = data{1};
%         f = size(data,2);
% 	
%         y = data(:, f);
%         table = [];
%         delete(gcp('nocreate'));
%         parpool(4);
%         poolobj = gcp;
%         addAttachedFiles(poolobj,{'joint.m', 'mi.m'});
%         parfor k = 1:f-1
%             for j = (k+1):f-1
%                 x_1 = data(:, k);
%                 x_2 = data(:, j);
%                 jo = joint([x_1, x_2],[]);
% 
%                 merged = mi(jo, y);
%                 
%                 item1 = mi(x_1, x_2);
%                 item2 = mi(x_1, y);
%                 item3 = mi(x_2, y);
%                 
% 
%                 low = item2 + item3 - item1;
%                 high = item2 + item3 + max([item1, item2, item3]) + min([item1, item2, item3]);
% 
%                 table = [table; [low, merged, high]];
%             end
%         end
%         
%         reject = size(find(table(:,2) > table(:,3)),1);
%         r = reject/size(table,1)
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compare the cost of the unit operation
% clear;clc
% %clearvars -except dexter
% data = load('/home/hengl/matlab/bin/scripts/FAMIR/data/p53.mat');
% data = struct2cell(data);
% data = data{1};
% 
% y = data(:,size(data,2));
% [n,f] = size(data);
% feature_set = 1:f-1;
% 
% %Reforming the data to make it denser
% %Simply discarding the unused bins for each feature individually
% data2 = data;
% for i = 1:f-1
%     current_feature = data(:,i);
%     uv = unique(current_feature);
%     for j = 1:numel(uv)
%         current_feature(current_feature == uv(j)) = j;
%     end
%     data2(:,i) = current_feature;
% end
% 
% 
% start = tic;
% for j=feature_set
%     x1 = data2(:,j);
%     x2 = data2(:,randsample(feature_set,1));  
%     mi(x1,x2);  %FJMI
% end
% time_FJMI = toc(start);
% 
% start = tic;
% for j=feature_set
%     x1 = data2(:,j);
%     x2 = data2(:,randsample(feature_set,1));  
%     jo = joint([x1,x2],[]); %JMI
%     mi(jo,y); %JMI
% end
% time_JMI = toc(start);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The objective of this function is to find the linearity of the joint
%mutual information involved in 3 variables where 2 of them are given
clear;clc
fid = fopen('/home/hengl/matlab/bin/scripts/FJMI/names2');
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

index = 20;
path = strcat('/home/hengl/matlab/bin/scripts/FJMI/data/', file_name{index}, '.mat');
file = load(path);
data = struct2cell(file);
data = data{1};

f = size(data,2)-1;	
y = data(:, f+1);
table = [];
control = [];
threshold = 20;

n = [];
d = [];



for j = 45
    for k = 1:f
        if j ~= k
            x_1 = data(:, j);
            x_2 = data(:, k);
            jo = joint([x_1, x_2],[]);

            merged = mi(jo, y);
                
            item1 = mi(x_1, x_2);
            item2 = mi(x_1, y);
            item3 = mi(x_2, y);
                

            low = item2 + item3 - item1;
            high = item2 + item3 + max([item1, item2, item3]) + min([item1, item2, item3]);

            table = [table; [low, high, merged]];
            n = [n  condh(x_1,y) - condh(x_1,joint([x_2,y],[]))];
            d = [d  item1 + min([item1, item2, item3]) + max([item1, item2, item3])];
        end
    end
end


target = table(:,3);
%scatter3(table(:,1), table(:,2), target, 'filled');
ratio = [];
for i=1:f-1
    ratio = [ratio sum(n(1:i))/sum(d(1:i))];
end
plot(ratio);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is used to calculate the difference between C_Fi and
%C_Hat_Fi, each dataset will be used to generate the error rate when
%different \lambda's are used
% clear;clc
% fid = fopen('/home/hengl/matlab/bin/scripts/FAMIR/names2');
% file_name = {};
% for i=1:14
%     line = fgets(fid);
%     if ischar(line)
%         file_name{i} = line;
%     end
% end
% 
% expression = '[A-Za-z0-9-_]*';
% for i=1:14
%     str = regexp(file_name{i}, expression);
%     file_name{i} = file_name{i}(1: str(1,2)-2);
% end
% 
% index = 11; %choosing the dataset that is used
% path = strcat('/home/hengl/matlab/bin/scripts/FAMIR/data/', file_name{index}, '.mat');
% file = load(path);
% data = struct2cell(file);
% data = data{1};
% f = size(data,2)-1;	
% y = data(:, f+1);
% 
% 
% numthreshold = 10;
% base_threshold = 20;
% 
% result = [];
% 
% parpool(4);
% poolobj = gcp;
% addAttachedFiles(poolobj,{'mi.m','joint.m'});
% parfor i = 1:numthreshold %try different thresholds
%     threshold = base_threshold + i;
%     temp = [];
%     for first = 1:f   %iterate all features
%         count = 1; %indicator when to start estimation
%         sum_true = 0;
%         sum_estimate = 0;
%         table1 = [];
%         table2 = [];
%         table3 = [];
%         
%         for second = 1:f
%             if first ~= second
%                 x_1 = data(:, first);
%                 x_2 = data(:, second);
%                 jo = joint([x_1, x_2],[]);
%                 
%                 target = mi(jo, y); 
%                 
%                 item1 = mi(x_1, y);
%                 item2 = mi(x_2, y);
%                 item3 = mi(x_1,x_2);
%                 
%                 sum_true = sum_true + target;
%                 
%                 table1 = [table1;item1+item2-item3];
%                 table2 = [table2;item1+item2+max([item1, item2, item3])+min([item1, item2, item3])];
%                 table3 = [table3;target];
%                 if count <= threshold
%                     sum_estimate = sum_estimate + target;
%                 end
%                 if count == threshold
%                     x = [ones(threshold,1) table1 table2];
%                     para = (x'*x)\x'*table3;
%                     beta0 = para(1);
%                     beta = para(2:3);
%                 end
%                 if count > threshold
%                     bounds = [item1+item2-item3  item1+item2+max([item1, item2, item3])+min([item1, item2, item3])];
%                     sum_estimate = sum_estimate + (bounds*beta+beta0);
%                 end
%                 count = count + 1;
%             end
%         end
%         temp = [temp abs((sum_true - sum_estimate)/sum_true)];
%     end
%     result(i,:) = temp;
% 
% end
% delete(gcp('nocreate'));

                
                
