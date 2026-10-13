clc
clear all
close all

file_name = 'F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\2_loadData\1_before\'; % 原始数据路径
savepath = 'F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\3_EEGData\1_before\'; % 保存路径
if ~isfolder(savepath)
    mkdir(savepath);
end
low_cutoff = 0.5;
high_cutoff = 45; %滤波范围
Fs = 1000; % 采样频率
dataname = dir([file_name, '*.mat']);

% 所有64导通道标签
Channel_64 = {'FP1','FPz','FP2','AF3','AF4','F7','F5','F3','F1','Fz',...
    'F2','F4','F6','F8','FT7','FC5','FC3','FC1','FCz','FC2',...
    'FC4','FC6','FT8','T7','C5','C3','C1','Cz','C2','C4',...
    'C6','T8','M1','TP7','CP5','CP3','CP1','CPz','CP2','CP4',...
    'CP6','TP8','M2','P7','P5','P3','P1','Pz','P2','P4',...
    'P6','P8','PO7','PO5','PO3','POz','PO4','PO6','PO8','CB1',...
    'O1','Oz','O2','OB2'};

% 需要保留的21导名称
Channel_21 = {'FP1','FPz','FP2','F7','F3','Fz','F4','F8','T7','C3',...
              'Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2','Oz'};
load('matlab.mat')
n_channels = 21;
for k = 1:length(dataname)
    filepath = fullfile(file_name, dataname(k).name);
    load(filepath);  % 假设加载出的变量名为 EEGdata，维度为 64×时间点

    % 找出21通道在64通道中的索引
    idx_21 = find(ismember(Channel_64, Channel_21));

    % 提取21通道数据
    EEG.data = EEGdata(idx_21, :);
    EEG.chan = Channel_21;
    CC = load('F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\21.txt');
    EEG.chanlocs = struct( ...
        'theta',      cell(1, n_channels), ...
        'radius',     cell(1, n_channels), ...
        'labels',     cell(1, n_channels), ...
        'sph_theta',  cell(1, n_channels), ...
        'sph_phi',    cell(1, n_channels), ...
        'X',          cell(1, n_channels), ...
        'Y',          cell(1, n_channels), ...
        'Z',          cell(1, n_channels), ...
        'sph_radius', cell(1, n_channels), ...
        'type',       cell(1, n_channels), ...
        'ref',        cell(1, n_channels), ...
        'urchan',     cell(1, n_channels));


    %% 构建XYZ坐标
    for m = 1:21
        EEG.chanlocs(m).labels = Channel_21(m);
        EEG.chanlocs(m).X = CC(m,1);
        EEG.chanlocs(m).Y = CC(m,2);
        EEG.chanlocs(m).Z = CC(m,3);
        EEG.chanlocs(m).theta = CC(m,4);
        EEG.chanlocs(m).radius = CC(m,5);
    end
    EEG.srate = Fs;    EEG.trials = 1;    EEG.pnts = size(EEG.data,2);    EEG.setname = [];         EEG.icachansind = [];
    EEG.nbchan = size(EEG.data,1);  EEG.icawinv = [];  EEG.icaact = [];                EEG.icasphere = [];       EEG.icaweights = [];
    EEG.xmax = length(EEG.data)/EEG.srate;             EEG.xmin = 1/EEG.srate;         EEG.filename = [];        EEG.filepath = [];
    EEG.subject = dataname(k).name(1:end-8);EEG.event = [];

    EEG = pop_eegfiltnew(EEG,low_cutoff, high_cutoff);
    eegplot(EEG.data, 'srate', 1000,'spacing',50)
    % run indpendent component analysis
    EEG = pop_runica( EEG, 'icatype', 'runica');
    % 保存为新的 .mat 文件
    save(fullfile(savepath, ['sub', dataname(k).name(1:end-8), '.mat']), 'EEG');
    close all;
    clear EEG EEGdata
end



%% 挑选ica成分
clear all;close all;clc
path = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\3_EEGData\3_control\';
savepath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\3_EEGData\3_control\';  mkdir(savepath);
foldername = data_load(path,'.mat');
for sub = 20:length(foldername)
    load([path,foldername{sub}]);
    eegplot(EEG.data,'srate', 1000,'spacing',50);
%     find artefact compponents wiht adjust toolbox
    report_filename = sprintf( '%s_adjreport.txt',[foldername{sub}(1:end-4)]);
    EEG = interface_ADJ(EEG ,report_filename);
    % remove bad components
    bad_comps = [1 2];
    EEG = pop_subcomp( EEG, bad_comps, 0);
    eegplot(EEG.data, 'srate', 1000,'spacing',50);
    save([savepath,foldername{sub}(1:end-4),'.mat'], 'EEG');
end