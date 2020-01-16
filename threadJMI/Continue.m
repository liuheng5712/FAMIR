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
%This function performs the comparision between JMI and FJMI using bootstrapping
%This function is designed to be able to perform feature selection with breakpoints
%Input: 
%index is the index of the data used
%k is the number of feature selected
%threshold is the parameter used for FJMI
%boot is total rounds of bootstrapping
%Output: return the selected vector and time vector for JMI and FJMI respectively

%Set the parameters manually!!!
load('threadJMI.mat')
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%'bootstap' is the bootstarpping indices obtained from preivous step
%'selected1, selected2' is the selected features from previous step
%'time1, time2' is the time consumed from previous step

k1 = 400; % features selected in first step
k2 = 100; % features selected in second step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            


%delete(gcp('nocreate'));
parpool(48);
poolobj = gcp;
addAttachedFiles(poolobj,{'JMI_continue.m', 'joint.m'});

selected_this = [];
time_this = [];
parfor i=1:boot
    bo = bootstrap(i,:); 
    para = [k1, k2+k1];
    para_JMI = [selected1(i,:); time1(i,:)];  
    
    [selected_JMI,time_JMI] = JMI_continue(index, bo, para, para_JMI);   
    
    
    selected_this(i,:) = selected_JMI;
    time_this(i,:) = time_JMI;

end
selected1 = selected_this;
time1 = time_this;
delete(gcp('nocreate'))

save threadJMI
