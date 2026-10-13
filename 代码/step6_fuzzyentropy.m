%%此部分利用频段进行模糊熵的计算
clear all;close all;clc;
File  = 'F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\6_利用PLV的时间变异性研究\3_control\0.5-4\';
savePath = 'F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\1_before\0.5-4\';
mkdir(savePath);
dataname = data_load(File,'.mat');
for sub = 1:length(dataname)   
    swData =[];
    load([File,dataname{sub}]);
    swData = Re_Plv;
    data =[];
    for i1 = 1:size(swData,1)-1
        for i2 = i1+1:size(swData,2)
            data = squeeze(swData(i1,i2,:));
            r_factor = 0.2*std(data);
            T_data(i1,i2) = Fuzzy_Entropy1(2,r_factor,data,1);
        end
    end
    T_data(i1+1,:) = zeros(i1+1,1);
    T_time(:,:,sub) = T_data;
    clear Re_Plv T_data
end
T_mean = mean(T_time,3);
save([savePath,'fuzzyEntropy.mat'],'T_mean','T_time');

clear all;close all;clc;
File  = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\6_利用PLV的时间变异性研究\1_before\4-8\';
savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\1_before\4-8\';
mkdir(savePath);
dataname = data_load(File,'.mat');
for sub = 1:length(dataname)   
    swData =[];
    load([File,dataname{sub}]);
    swData = Re_Plv;
    data =[];
    for i1 = 1:size(swData,1)-1
        for i2 = i1+1:size(swData,2)
            data = squeeze(swData(i1,i2,:));
            r_factor = 0.2*std(data);
            T_data(i1,i2) = Fuzzy_Entropy1(2,r_factor,data,1);
        end
    end
    T_data(i1+1,:) = zeros(i1+1,1);
    T_time(:,:,sub) = T_data;
    clear Re_Plv T_data
end
T_mean = mean(T_time,3);
save([savePath,'fuzzyEntropy.mat'],'T_mean','T_time');

clear all;close all;clc;
File  = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\6_利用PLV的时间变异性研究\1_before\8-13\';
savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\1_before\8-13\';
mkdir(savePath);
dataname = data_load(File,'.mat');
for sub = 1:length(dataname)   
    swData =[];
    load([File,dataname{sub}]);
    swData = Re_Plv;
    data =[];
    for i1 = 1:size(swData,1)-1
        for i2 = i1+1:size(swData,2)
            data = squeeze(swData(i1,i2,:));
            r_factor = 0.2*std(data);
            T_data(i1,i2) = Fuzzy_Entropy1(2,r_factor,data,1);
        end
    end
    T_data(i1+1,:) = zeros(i1+1,1);
    T_time(:,:,sub) = T_data;
    clear Re_Plv T_data
end
T_mean = mean(T_time,3);
save([savePath,'fuzzyEntropy.mat'],'T_mean','T_time');

clear all;close all;clc;
File  = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\6_利用PLV的时间变异性研究\1_before\13-30\';
savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\1_before\13-30\';
mkdir(savePath);
dataname = data_load(File,'.mat');
for sub = 1:length(dataname)   
    swData =[];
    load([File,dataname{sub}]);
    swData = Re_Plv;
    data =[];
    for i1 = 1:size(swData,1)-1
        for i2 = i1+1:size(swData,2)
            data = squeeze(swData(i1,i2,:));
            r_factor = 0.2*std(data);
            T_data(i1,i2) = Fuzzy_Entropy1(2,r_factor,data,1);
        end
    end
    T_data(i1+1,:) = zeros(i1+1,1);
    T_time(:,:,sub) = T_data;
    clear Re_Plv T_data
end
T_mean = mean(T_time,3);
save([savePath,'fuzzyEntropy.mat'],'T_mean','T_time');

clear all;close all;clc;
File  = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\6_利用PLV的时间变异性研究\1_before\30-45\';
savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\1_before\30-45\';
mkdir(savePath);
dataname = data_load(File,'.mat');
for sub = 1:length(dataname)   
    swData =[];
    load([File,dataname{sub}]);
    swData = Re_Plv;
    data =[];
    for i1 = 1:size(swData,1)-1
        for i2 = i1+1:size(swData,2)
            data = squeeze(swData(i1,i2,:));
            r_factor = 0.2*std(data);
            T_data(i1,i2) = Fuzzy_Entropy1(2,r_factor,data,1);
        end
    end
    T_data(i1+1,:) = zeros(i1+1,1);
    T_time(:,:,sub) = T_data;
    clear Re_Plv T_data
end
T_mean = mean(T_time,3);
save([savePath,'fuzzyEntropy.mat'],'T_mean','T_time');

