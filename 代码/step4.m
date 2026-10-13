%% 对静息态数据分段滤波
clear all;close all;clc;
File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\4_restData\1_before\';
SaveFile = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\5_Data\1_before\0.5-4\';mkdir(SaveFile);
freqband = [0.5 4];
keyword = data_load(File,'.mat');
for sub = 1:length(keyword) 
    load([File,keyword{sub}]);  
    %% 滤波
    EEG = pop_eegfiltnew(EEG,freqband(1),v c      freqband(2));
   
%      %% ICA
% %      EEG = pop_runica( EEG, 'icatype', 'runica');
% %     % find artefact compponents wiht adjust toolbox
% %     report_filename = sprintf( '%s_adjreport.txt','kkk');
% %     EEG = interface_ADJ(EEG ,report_filename);
% %     %% =====================    后续手动剔除 眼电=======================
% %     bad_comps = [1 2];     
% %     rej_EEG= pop_subcomp(EEG, bad_comps, 0);  
% %     eegplot(rej_EEG.data, 'srate', 500); 
% % 
% %     EEG.data=rej_EEG.data;
%     
%     EEG = pop_runica( EEG, 'icatype', 'runica');
% %     EEG=pop_runica(EEG, 'icatype', 'sobi');
%     EEG = iclabel(EEG);
%     [~, icVector] = max(EEG.etc.ic_classification.ICLabel.classifications, [], 2);
%     icProbVector = zeros(length(icVector),1);
%     for icIdx = 1:length(icVector)
%         icProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, icVector(icIdx));
%         icMuscleProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, 2); % muscle prob
%     end
%     artifactLabelProbThresh = 0.3; % [0-1]
%     rejICs = find((icVector==2 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==3 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==4 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==5 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==6 & icProbVector>=artifactLabelProbThresh));
%     disp(rejICs)
%     EEG = pop_subcomp( EEG, rejICs, 0 );
%     EEG = eeg_checkset( EEG ); 
    eegplot(EEG.data, 'srate', 1000,'spacing',50); 
    Data = EEG.data;
%     %% 每5秒分段
%     data_sect = [1 EEG.srate*5];
%     Data_sect = [];
%     for time = 1:fix(length(EEG.data)/(5*EEG.srate))
%         Point = 5*EEG.srate*(time-1);
%         Data_sect{time}(:,:) = EEG.data(:,Point+data_sect(1):Point+data_sect(2));
%     end
%     %% 静息态删除大于80的数据
%     threshold = 80;
%     for j = 1:length(Data_sect)
%         if max(max(abs(Data_sect{j})))>=threshold
%             Data_sect{j} = [];
%         else
%             Data_sect{j} = Data_sect{j};
%         end
%     end
%     Data_sect(cellfun(@isempty,Data_sect)) = [];%将函数应用于单元数组中的每个单元格
%     Data_num(sub) = size(Data_sect,2);
%     Data_srate(sub) = EEG.srate;
    save([SaveFile,keyword{sub}(1:end-4),'.mat'],'Data');
    clear Data_sect data EEG
    close all;
end

clear all;close all;clc;
File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\4_restData\1_before\';
SaveFile = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\5_Data\1_before\4-8\';mkdir(SaveFile);
freqband = [4 8];
keyword = data_load(File,'.mat');
for sub = 1:length(keyword) 
    load([File,keyword{sub}]);  
    %% 滤波
    EEG = pop_eegfiltnew(EEG,freqband(1),freqband(2));
   
%      %% ICA
% %      EEG = pop_runica( EEG, 'icatype', 'runica');
% %     % find artefact compponents wiht adjust toolbox
% %     report_filename = sprintf( '%s_adjreport.txt','kkk');
% %     EEG = interface_ADJ(EEG ,report_filename);
% %     %% =====================    后续手动剔除 眼电=======================
% %     bad_comps = [1 2];     
% %     rej_EEG= pop_subcomp(EEG, bad_comps, 0);  
% %     eegplot(rej_EEG.data, 'srate', 500); 
% % 
% %     EEG.data=rej_EEG.data;
%     
%     EEG = pop_runica( EEG, 'icatype', 'runica');
% %     EEG=pop_runica(EEG, 'icatype', 'sobi');
%     EEG = iclabel(EEG);
%     [~, icVector] = max(EEG.etc.ic_classification.ICLabel.classifications, [], 2);
%     icProbVector = zeros(length(icVector),1);
%     for icIdx = 1:length(icVector)
%         icProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, icVector(icIdx));
%         icMuscleProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, 2); % muscle prob
%     end
%     artifactLabelProbThresh = 0.3; % [0-1]
%     rejICs = find((icVector==2 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==3 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==4 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==5 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==6 & icProbVector>=artifactLabelProbThresh));
%     disp(rejICs)
%     EEG = pop_subcomp( EEG, rejICs, 0 );
%     EEG = eeg_checkset( EEG ); 
    eegplot(EEG.data, 'srate', 1000,'spacing',50); 
    Data = EEG.data;
%     %% 每5秒分段
%     data_sect = [1 EEG.srate*5];
%     Data_sect = [];
%     for time = 1:fix(length(EEG.data)/(5*EEG.srate))
%         Point = 5*EEG.srate*(time-1);
%         Data_sect{time}(:,:) = EEG.data(:,Point+data_sect(1):Point+data_sect(2));
%     end
%     %% 静息态删除大于80的数据
%     threshold = 80;
%     for j = 1:length(Data_sect)
%         if max(max(abs(Data_sect{j})))>=threshold
%             Data_sect{j} = [];
%         else
%             Data_sect{j} = Data_sect{j};
%         end
%     end
%     Data_sect(cellfun(@isempty,Data_sect)) = [];%将函数应用于单元数组中的每个单元格
%     Data_num(sub) = size(Data_sect,2);
%     Data_srate(sub) = EEG.srate;
    save([SaveFile,keyword{sub}(1:end-4),'.mat'],'Data');
    clear Data_sect data EEG
    close all;
end

clear all;close all;clc;
File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\4_restData\1_before\';
SaveFile = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\5_Data\1_before\8-13\';mkdir(SaveFile);
freqband = [8 13];
keyword = data_load(File,'.mat');
for sub = 1:length(keyword) 
    load([File,keyword{sub}]);  
    %% 滤波
    EEG = pop_eegfiltnew(EEG,freqband(1),freqband(2));
   
%      %% ICA
% %      EEG = pop_runica( EEG, 'icatype', 'runica');
% %     % find artefact compponents wiht adjust toolbox
% %     report_filename = sprintf( '%s_adjreport.txt','kkk');
% %     EEG = interface_ADJ(EEG ,report_filename);
% %     %% =====================    后续手动剔除 眼电=======================
% %     bad_comps = [1 2];     
% %     rej_EEG= pop_subcomp(EEG, bad_comps, 0);  
% %     eegplot(rej_EEG.data, 'srate', 500); 
% % 
% %     EEG.data=rej_EEG.data;
%     
%     EEG = pop_runica( EEG, 'icatype', 'runica');
% %     EEG=pop_runica(EEG, 'icatype', 'sobi');
%     EEG = iclabel(EEG);
%     [~, icVector] = max(EEG.etc.ic_classification.ICLabel.classifications, [], 2);
%     icProbVector = zeros(length(icVector),1);
%     for icIdx = 1:length(icVector)
%         icProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, icVector(icIdx));
%         icMuscleProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, 2); % muscle prob
%     end
%     artifactLabelProbThresh = 0.3; % [0-1]
%     rejICs = find((icVector==2 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==3 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==4 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==5 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==6 & icProbVector>=artifactLabelProbThresh));
%     disp(rejICs)
%     EEG = pop_subcomp( EEG, rejICs, 0 );
%     EEG = eeg_checkset( EEG ); 
    eegplot(EEG.data, 'srate', 1000,'spacing',50); 
    Data = EEG.data;
%     %% 每5秒分段
%     data_sect = [1 EEG.srate*5];
%     Data_sect = [];
%     for time = 1:fix(length(EEG.data)/(5*EEG.srate))
%         Point = 5*EEG.srate*(time-1);
%         Data_sect{time}(:,:) = EEG.data(:,Point+data_sect(1):Point+data_sect(2));
%     end
%     %% 静息态删除大于80的数据
%     threshold = 80;
%     for j = 1:length(Data_sect)
%         if max(max(abs(Data_sect{j})))>=threshold
%             Data_sect{j} = [];
%         else
%             Data_sect{j} = Data_sect{j};
%         end
%     end
%     Data_sect(cellfun(@isempty,Data_sect)) = [];%将函数应用于单元数组中的每个单元格
%     Data_num(sub) = size(Data_sect,2);
%     Data_srate(sub) = EEG.srate;
    save([SaveFile,keyword{sub}(1:end-4),'.mat'],'Data');
    clear Data_sect data EEG
    close all;
end

clear all;close all;clc;
File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\4_restData\1_before\';
SaveFile = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\5_Data\1_before\13-30\';mkdir(SaveFile);
freqband = [13 30];
keyword = data_load(File,'.mat');
for sub = 1:length(keyword) 
    load([File,keyword{sub}]);  
    %% 滤波
    EEG = pop_eegfiltnew(EEG,freqband(1),freqband(2));
   
%      %% ICA
% %      EEG = pop_runica( EEG, 'icatype', 'runica');
% %     % find artefact compponents wiht adjust toolbox
% %     report_filename = sprintf( '%s_adjreport.txt','kkk');
% %     EEG = interface_ADJ(EEG ,report_filename);
% %     %% =====================    后续手动剔除 眼电=======================
% %     bad_comps = [1 2];     
% %     rej_EEG= pop_subcomp(EEG, bad_comps, 0);  
% %     eegplot(rej_EEG.data, 'srate', 500); 
% % 
% %     EEG.data=rej_EEG.data;
%     
%     EEG = pop_runica( EEG, 'icatype', 'runica');
% %     EEG=pop_runica(EEG, 'icatype', 'sobi');
%     EEG = iclabel(EEG);
%     [~, icVector] = max(EEG.etc.ic_classification.ICLabel.classifications, [], 2);
%     icProbVector = zeros(length(icVector),1);
%     for icIdx = 1:length(icVector)
%         icProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, icVector(icIdx));
%         icMuscleProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, 2); % muscle prob
%     end
%     artifactLabelProbThresh = 0.3; % [0-1]
%     rejICs = find((icVector==2 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==3 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==4 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==5 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==6 & icProbVector>=artifactLabelProbThresh));
%     disp(rejICs)
%     EEG = pop_subcomp( EEG, rejICs, 0 );
%     EEG = eeg_checkset( EEG ); 
    eegplot(EEG.data, 'srate', 1000,'spacing',50); 
    Data = EEG.data;
%     %% 每5秒分段
%     data_sect = [1 EEG.srate*5];
%     Data_sect = [];
%     for time = 1:fix(length(EEG.data)/(5*EEG.srate))
%         Point = 5*EEG.srate*(time-1);
%         Data_sect{time}(:,:) = EEG.data(:,Point+data_sect(1):Point+data_sect(2));
%     end
%     %% 静息态删除大于80的数据
%     threshold = 80;
%     for j = 1:length(Data_sect)
%         if max(max(abs(Data_sect{j})))>=threshold
%             Data_sect{j} = [];
%         else
%             Data_sect{j} = Data_sect{j};
%         end
%     end
%     Data_sect(cellfun(@isempty,Data_sect)) = [];%将函数应用于单元数组中的每个单元格
%     Data_num(sub) = size(Data_sect,2);
%     Data_srate(sub) = EEG.srate;
    save([SaveFile,keyword{sub}(1:end-4),'.mat'],'Data');
    clear Data_sect data EEG
    close all;
end

clear all;close all;clc;
File = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\4_restData\1_before\';
SaveFile = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\5_Data\1_before\30-45\';mkdir(SaveFile);
freqband = [30 45];
keyword = data_load(File,'.mat');
for sub = 1:length(keyword) 
    load([File,keyword{sub}]);  
    %% 滤波
    EEG = pop_eegfiltnew(EEG,freqband(1),freqband(2));
   
%      %% ICA
% %      EEG = pop_runica( EEG, 'icatype', 'runica');
% %     % find artefact compponents wiht adjust toolbox
% %     report_filename = sprintf( '%s_adjreport.txt','kkk');
% %     EEG = interface_ADJ(EEG ,report_filename);
% %     %% =====================    后续手动剔除 眼电=======================
% %     bad_comps = [1 2];     
% %     rej_EEG= pop_subcomp(EEG, bad_comps, 0);  
% %     eegplot(rej_EEG.data, 'srate', 500); 
% % 
% %     EEG.data=rej_EEG.data;
%     
%     EEG = pop_runica( EEG, 'icatype', 'runica');
% %     EEG=pop_runica(EEG, 'icatype', 'sobi');
%     EEG = iclabel(EEG);
%     [~, icVector] = max(EEG.etc.ic_classification.ICLabel.classifications, [], 2);
%     icProbVector = zeros(length(icVector),1);
%     for icIdx = 1:length(icVector)
%         icProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, icVector(icIdx));
%         icMuscleProbVector(icIdx) = EEG.etc.ic_classification.ICLabel.classifications(icIdx, 2); % muscle prob
%     end
%     artifactLabelProbThresh = 0.3; % [0-1]
%     rejICs = find((icVector==2 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==3 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==4 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==5 & icProbVector>=artifactLabelProbThresh)|...
%         (icVector==6 & icProbVector>=artifactLabelProbThresh));
%     disp(rejICs)
%     EEG = pop_subcomp( EEG, rejICs, 0 );
%     EEG = eeg_checkset( EEG ); 
    eegplot(EEG.data, 'srate', 1000,'spacing',50); 
    Data = EEG.data;
%     %% 每5秒分段
%     data_sect = [1 EEG.srate*5];
%     Data_sect = [];
%     for time = 1:fix(length(EEG.data)/(5*EEG.srate))
%         Point = 5*EEG.srate*(time-1);
%         Data_sect{time}(:,:) = EEG.data(:,Point+data_sect(1):Point+data_sect(2));
%     end
%     %% 静息态删除大于80的数据
%     threshold = 80;
%     for j = 1:length(Data_sect)
%         if max(max(abs(Data_sect{j})))>=threshold
%             Data_sect{j} = [];
%         else
%             Data_sect{j} = Data_sect{j};
%         end
%     end
%     Data_sect(cellfun(@isempty,Data_sect)) = [];%将函数应用于单元数组中的每个单元格
%     Data_num(sub) = size(Data_sect,2);
%     Data_srate(sub) = EEG.srate;
    save([SaveFile,keyword{sub}(1:end-4),'.mat'],'Data');
    clear Data_sect data EEG
    close all;
end