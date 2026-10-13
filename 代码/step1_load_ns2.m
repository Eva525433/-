%% 数据读取和减少放大倍数
% 2020.7.14 claire

clear;clc;
file_name='F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\1_RawData\1_before\';% SZ-27
savepath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\2_loadData\1_before\';
if ~isdir(savepath), mkdir(savepath);  end

dataname=dir([file_name,'*.ns2']);
for k=1:length(dataname)
    str = fullfile(file_name,dataname(k).name);
    fid=fopen(str,'r');
    fseek(fid,10,'bof');           % 'bof'是指针从文档开头开
    lenhead1=fread(fid,1,'int16'); % 读取第一行，第一行为数据所在行
    lenhead=lenhead1+9;            % 数据所在行+9
    fseek(fid,lenhead,'bof');      % 定位到数据所在行
    data=fread(fid,'int16');       % 读取数据所在行数据
    data=data./4;                  % 放大器放大了4倍，故此处除以4
    l=length(data);
    % 每隔64读取一个数字，共64通道数据
    num=0;
    for i=[1 37 41 13 49 21 57 61 2 38 42 14 50 22 58 62 33 5 9 45 17 53 25 29 34 ...
            6 10 46 18 54 26 30 3 39 43 15 51 23 59 63 4 40 44 16 52 24 60 64 35 7 ...
            11 47 19 55 27 31 36 8 12 48 20 56 28 32] % 将采集通道 与 电极帽 电极相互对应
        num=num+1;
        EEGdata(num,:)=data(i:64:l); % i表示一个电极
    end
    
    save([savepath,'sub',dataname(k).name(1:end-4),'_pre.mat'],'EEGdata');
    clear data EEGdata
end

