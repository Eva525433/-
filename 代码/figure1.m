clear all; close all; clc;

% ==== 频段设置 ====
bands = {'8-13'};

% ==== 通道信息 ====
channel = {'Fp1','Fpz','Fp2','F7','F3','Fz','F4','F8','T7','C3','Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2','Oz'};
[x,y,loc]=textread('eeg_61Loc_T.txt','%*d %f %f %s',-1);
a = 0;
for k = 1:length(channel) 
    for j = 1:length(loc) 
        if strcmp(channel{k},loc{j}) 
            a = a+1;
            num(a) = j;
        end
    end
end
x1 = x(num);
y1 = y(num);
f_name = 'Brain Network';
n = length(channel);
loc_cere = channel;

% ==== 保存路径 ====
compare_result='F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\结果\治疗前VS治疗后\';
mkdir(compare_result);

Threshold=0.01;

for b = 1:length(bands)
    band = bands{b};
    disp(['正在处理频段: ', band]);

    % ==== 加载数据 ====
    before_coh=['F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\3_control\',band,'\'];
    after_coh =['F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\2_after\',band,'\'];

    eval(['load ',before_coh,'fuzzyEntropy.mat']);
    q_time = T_time; q_mean = T_mean;
    clear T_time T_mean;
    eval(['load ',after_coh,'fuzzyEntropy.mat']);
    h_time = T_time; h_mean = T_mean;
    clear T_time T_mean;

    % ==== 构建邻接矩阵 ====
    for i = 1:size(q_time,3)
        coh_q(i,:,:) = q_time(:,:,i) + q_time(:,:,i)';
    end
    for k = 1:size(h_time,3)
        coh_h(k,:,:) = h_time(:,:,k) + h_time(:,:,k)';
    end

    % ==== 统计检验 ====
    p0 = zeros(n,n); p1 = zeros(n,n);
    for i = 1:size(coh_q,2)
        for i1 = i:size(coh_q,3)
            [h0(i,i1),p0(i,i1),~,stats0] = ttest2(coh_q(:,i,i1),coh_h(:,i,i1),Threshold,'left'); 
            [h1(i,i1),p1(i,i1),~,stats1] = ttest2(coh_q(:,i,i1),coh_h(:,i,i1),Threshold,'right');
            t0(i,i1) = stats0.tstat;  % 保存左尾检验的t值
            t1(i,i1) = stats1.tstat;  % 保存右尾检验的t值
        end
    end

    % ==== FDR 校验 ====
    [P_ida,~] = FDR(p0,Threshold);
    if isempty(P_ida), P_ida=0; end
    tem_p = p0; tem_p(tem_p>P_ida) = 0;
    FDR_p0 = tem_p; FDR_p0(FDR_p0 ~=0) = 1;


    [P_ida,~] = FDR(p1,Threshold);
    if isempty(P_ida), P_ida=0; end
    tem_p = p1; tem_p(tem_p>P_ida) = 0;
    FDR_p1 = tem_p; FDR_p1(FDR_p1 ~=0) = 1;

    % ==== 构建结果矩阵 ====
    B0 = FDR_p1 - FDR_p0; 
    Brain_Graphic(B0,n,f_name,loc_cere,x1',-y1');
    t0(B0 == 0) = 0;
    % ==== 保存结果 ====
    fig0 = figure(1);
    print(fig0,[compare_result,band,'_ttest_校验0.01.eps'],'-depsc2');
    close(fig0);

    % 清理变量避免频段间干扰
    clear coh_q coh_h q_time h_time q_mean h_mean
end
