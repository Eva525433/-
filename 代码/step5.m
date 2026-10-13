%% 利用滑动窗对静息态数据进行相干计算，设定窗长为2s，重叠率98%，
%% 仅处理前20秒，19~20s的保留全段，低于19s跳过
% clear all; close all; clc;
% 
% File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\5_Data\1_before\0.5-4\';
% savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\6_利用PLV的时间变异性研究\1_before\0.5-4\';
% mkdir(savePath);
% 
% window_length = 2;  % 滑窗长度（秒）
% Fs = 1000;          % 采样率（Hz）
% dataname = data_load(File, '.mat');  % 获取所有文件名
% 
% for sub = 17:20  % 只处理前20个被试
%     load([File, dataname{sub}]);  % 加载数据（假设变量名为 Data）
%     data_len = size(Data, 2);
% 
%     if data_len < Fs * 19
%     disp(['第', num2str(sub), '个被试时长 < 19s，跳过。']);
%     continue;
% 
%     elseif data_len < Fs * 20
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前19秒']);
%         Data = Data(:, 1:Fs*19);  % 截取前19秒
%     
%     elseif data_len < Fs * 23
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前20秒']);
%         Data = Data(:, 1:Fs*20);  % 截取前20秒
%     
%     else
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取3–23秒']);
%         Data = Data(:, Fs*3+1 : Fs*23);  % 从第5秒开始取20秒
%     end
% 
% 
%     %% 滑动窗口切分（98% 重叠）
%     data_sect = [1, Fs * window_length]; 
%     step_size = fix((window_length * Fs) * 0.02);  % 每步滑动 2% 的窗口长度
%     max_win = floor((size(Data, 2) - data_sect(2)) / step_size) + 1;
% 
%     data_seg = [];
%     for k1 = 1 : max_win
%         Point = step_size * (k1 - 1);
%         data_seg(:, :, k1) = Data(:, Point + data_sect(1) : Point + data_sect(2));
%     end
% 
%     %% 计算 PLV
%     Re_Plv = [];
%     for k2 = 1 : size(data_seg, 3)
%         AAA = data_seg(:, :, k2);
%         Re_Plv(:, :, k2) = Connect_PLV(AAA);
%     end
% 
%     % 保存结果
%     save([savePath, dataname{sub}(1:end-4), '.mat'], 'Re_Plv');
%     disp(['第', num2str(sub), '个被试计算结束！']);
% end
% 
% 
% clear all; close all; clc;
% 
% File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\5_Data\1_before\4-8\';
% savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\6_利用PLV的时间变异性研究\1_before\4-8\';
% mkdir(savePath);
% 
% window_length = 2;  % 滑窗长度（秒）
% Fs = 1000;          % 采样率（Hz）
% dataname = data_load(File, '.mat');  % 获取所有文件名
% 
% for sub = 1:20  % 只处理前20个被试
%     load([File, dataname{sub}]);  % 加载数据（假设变量名为 Data）
%     data_len = size(Data, 2);
% 
%     % 情况 1：小于19s的跳过
%     if data_len < Fs * 19
%         disp(['第', num2str(sub), '个被试时长 < 19s，跳过。']);
%         continue;
%     
%     elseif data_len < Fs * 20
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前19秒']);
%         Data = Data(:, 1:Fs*19);  % 截取前19秒
%     
%     elseif data_len < Fs * 25
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前20秒']);
%         Data = Data(:, 1:Fs*20);  % 截取前20秒
%     
%     else
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取5–25秒']);
%         Data = Data(:, Fs*5+1 : Fs*25);  % 从第5秒开始取20秒
%     end
% 
% 
%     %% 滑动窗口切分（98% 重叠）
%     data_sect = [1, Fs * window_length]; 
%     step_size = fix((window_length * Fs) * 0.02);  % 每步滑动 2% 的窗口长度
%     max_win = floor((size(Data, 2) - data_sect(2)) / step_size) + 1;
% 
%     data_seg = [];
%     for k1 = 1 : max_win
%         Point = step_size * (k1 - 1);
%         data_seg(:, :, k1) = Data(:, Point + data_sect(1) : Point + data_sect(2));
%     end
% 
%     %% 计算 PLV
%     Re_Plv = [];
%     for k2 = 1 : size(data_seg, 3)
%         AAA = data_seg(:, :, k2);
%         Re_Plv(:, :, k2) = Connect_PLV(AAA);
%     end
% 
%     % 保存结果
%     save([savePath, dataname{sub}(1:end-4), '.mat'], 'Re_Plv');
%     disp(['第', num2str(sub), '个被试计算结束！']);
% end


clear all; close all; clc;

File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\5_Data\1_before\8-13\';
savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\6_利用PLV的时间变异性研究\1_before\8-13\';
mkdir(savePath);

window_length = 2;  % 滑窗长度（秒）
Fs = 1000;          % 采样率（Hz）
dataname = data_load(File, '.mat');  % 获取所有文件名

for sub = 1:20  % 只处理前20个被试
    load([File, dataname{sub}]);  % 加载数据（假设变量名为 Data）
    data_len = size(Data, 2);

    % 情况 1：小于19s的跳过
    if data_len < Fs * 19
        disp(['第', num2str(sub), '个被试时长 < 19s，跳过。']);
        continue;
    
    elseif data_len < Fs * 20
        disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
              's，截取前19秒']);
        Data = Data(:, 1:Fs*19);  % 截取前19秒
    
    elseif data_len < Fs * 25
        disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
              's，截取前20秒']);
        Data = Data(:, 1:Fs*20);  % 截取前20秒
    
    else
        disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
              's，截取5–25秒']);
        Data = Data(:, Fs*5+1 : Fs*25);  % 从第5秒开始取20秒
    end


    %% 滑动窗口切分（98% 重叠）
    data_sect = [1, Fs * window_length]; 
    step_size = fix((window_length * Fs) * 0.02);  % 每步滑动 2% 的窗口长度
    max_win = floor((size(Data, 2) - data_sect(2)) / step_size) + 1;

    data_seg = [];
    for k1 = 1 : max_win
        Point = step_size * (k1 - 1);
        data_seg(:, :, k1) = Data(:, Point + data_sect(1) : Point + data_sect(2));
    end

    %% 计算 PLV
    Re_Plv = [];
    for k2 = 1 : size(data_seg, 3)
        AAA = data_seg(:, :, k2);
        Re_Plv(:, :, k2) = Connect_PLV(AAA);
    end

    % 保存结果
    save([savePath, dataname{sub}(1:end-4), '.mat'], 'Re_Plv');
    disp(['第', num2str(sub), '个被试计算结束！']);
end


% clear all; close all; clc;
% 
% File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\5_Data\1_before\13-30\';
% savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\6_利用PLV的时间变异性研究\1_before\13-30\';
% mkdir(savePath);
% 
% window_length = 2;  % 滑窗长度（秒）
% Fs = 1000;          % 采样率（Hz）
% dataname = data_load(File, '.mat');  % 获取所有文件名
% 
% for sub = 1:20  % 只处理前20个被试
%     load([File, dataname{sub}]);  % 加载数据（假设变量名为 Data）
%     data_len = size(Data, 2);
% 
%     % 情况 1：小于19s的跳过
%     if data_len < Fs * 19
%         disp(['第', num2str(sub), '个被试时长 < 19s，跳过。']);
%         continue;
%     
%     elseif data_len < Fs * 20
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前19秒']);
%         Data = Data(:, 1:Fs*19);  % 截取前19秒
%     
%     elseif data_len < Fs * 25
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前20秒']);
%         Data = Data(:, 1:Fs*20);  % 截取前20秒
%     
%     else
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取5–25秒']);
%         Data = Data(:, Fs*5+1 : Fs*25);  % 从第5秒开始取20秒
%     end
% 
% 
%     %% 滑动窗口切分（98% 重叠）
%     data_sect = [1, Fs * window_length]; 
%     step_size = fix((window_length * Fs) * 0.02);  % 每步滑动 2% 的窗口长度
%     max_win = floor((size(Data, 2) - data_sect(2)) / step_size) + 1;
% 
%     data_seg = [];
%     for k1 = 1 : max_win
%         Point = step_size * (k1 - 1);
%         data_seg(:, :, k1) = Data(:, Point + data_sect(1) : Point + data_sect(2));
%     end
% 
%     %% 计算 PLV
%     Re_Plv = [];
%     for k2 = 1 : size(data_seg, 3)
%         AAA = data_seg(:, :, k2);
%         Re_Plv(:, :, k2) = Connect_PLV(AAA);
%     end
% 
%     % 保存结果
%     save([savePath, dataname{sub}(1:end-4), '.mat'], 'Re_Plv');
%     disp(['第', num2str(sub), '个被试计算结束！']);
% end
% 
% 
% clear all; close all; clc;
% 
% File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\5_Data\1_before\30-45\';
% savePath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\6_利用PLV的时间变异性研究\1_before\30-45\';
% mkdir(savePath);
% 
% window_length = 2;  % 滑窗长度（秒）
% Fs = 1000;          % 采样率（Hz）
% dataname = data_load(File, '.mat');  % 获取所有文件名
% 
% for sub = 1:20  % 只处理前20个被试
%     load([File, dataname{sub}]);  % 加载数据（假设变量名为 Data）
%     data_len = size(Data, 2);
% 
%     % 情况 1：小于19s的跳过
%     if data_len < Fs * 19
%         disp(['第', num2str(sub), '个被试时长 < 19s，跳过。']);
%         continue;
%     
%     elseif data_len < Fs * 20
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前19秒']);
%         Data = Data(:, 1:Fs*19);  % 截取前19秒
%     
%     elseif data_len < Fs * 25
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取前20秒']);
%         Data = Data(:, 1:Fs*20);  % 截取前20秒
%     
%     else
%         disp(['第', num2str(sub), '个被试长度为 ', num2str(data_len/Fs, '%.2f'), ...
%               's，截取5–25秒']);
%         Data = Data(:, Fs*5+1 : Fs*25);  % 从第5秒开始取20秒
%     end
% 
% 
%     %% 滑动窗口切分（98% 重叠）
%     data_sect = [1, Fs * window_length]; 
%     step_size = fix((window_length * Fs) * 0.02);  % 每步滑动 2% 的窗口长度
%     max_win = floor((size(Data, 2) - data_sect(2)) / step_size) + 1;
% 
%     data_seg = [];
%     for k1 = 1 : max_win
%         Point = step_size * (k1 - 1);
%         data_seg(:, :, k1) = Data(:, Point + data_sect(1) : Point + data_sect(2));
%     end
% 
%     %% 计算 PLV
%     Re_Plv = [];
%     for k2 = 1 : size(data_seg, 3)
%         AAA = data_seg(:, :, k2);
%         Re_Plv(:, :, k2) = Connect_PLV(AAA);
%     end
% 
%     % 保存结果
%     save([savePath, dataname{sub}(1:end-4), '.mat'], 'Re_Plv');
%     disp(['第', num2str(sub), '个被试计算结束！']);
% end
% 
