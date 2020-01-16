%%//                            _ooOoo_  
%%//                           o8888888o  
%%//                           88" . "88  
%%//                           (| -_- |)  
%%//                            O\ = /O  
%%//                        ____/`---'\____  
%%//                      .   ' \\| |// `.  
%%//                       / \\||| : |||// \  
%%//                     / _||||| -:- |||||- \  
%%//                       | | \\\ - /// | |  
%%//                     | \_| ''\---/'' | |  
%%//                      \ .-\__ `-` ___/-. /  
%%//                   ___`. .' /--.--\ `. . __  
%%//                ."" '< `.___\_<|>_/___.' >'"".  
%%//               | | : `- \`.;`\ _ /`;.`/ - ` : | |  
%%//                 \ \ `-. \_ __\ /__ _/ .-` / /  
%%//         ======`-.____`-.___\_____/___.-`____.-'======  
%%//                            `=---='  
%This function is designed to be able to perform feature selection with breakpoints
%Input: 
%index is the index of the data used
%k is the number of feature selected
%threshold is the parameter used for FJMI
%boot is total rounds of bootstrapping
%Output: return the selected vector and time vector for JMI and FJMI respectively

%Set the parameters manually!!!
%22/dexter; 30/arcene; 24/gisette; 26/p53
index = 22; 
threshold = 20; 
boot = 48;


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
path = strcat('/home/hengl/FAMIR/data/', file_name{index}, '.mat');
data = struct2cell(load(path));
data = data{1};
[instances,f] = size(data);

%we are gonna select features step by step, k is the feature need to selection at the first time
k = 100;              



time1 = []; %The time final averaged time for JMI  %***this variable will be updated in the second run
selected1 = []; %The features selected for JMI   %***this variable will be updated in the second run

load('bootstrap.mat'); %This is the matrix storing the bootstrapping indices will be updated in the second run


delete(gcp('nocreate'));
parpool(48);
poolobj = gcp;
addAttachedFiles(poolobj,{'JMI.m', 'joint.m'});
parfor i=1:boot
    bo = bootstrap(i,:); 
    [selected_JMI,time_JMI] = JMI(index, k, bo);   
    
    
    selected1(i,:) = selected_JMI;
    time1(i,:) = time_JMI;
end

save threadJMI
