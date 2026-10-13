close all; clear; clc;

% 根路径
FileRoot = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\';

% 组名和频段
Groups = {'1_before', '2_after', '3_control'};
GroupLabels = {'Before', 'After', 'Control'};

Bands = {'0.5-4', '4-8', '8-13', '13-30', '30-45'};
BandLabels = {'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};

% 网络属性
PropertyNames = {'Clustering Coefficient', 'Characteristic Path Length', ...
                 'Global Efficiency', 'Local Efficiency'};
Threshold = 0.05;
% 主循环：每个属性画一张图
for p = 1:4
    means = zeros(length(Bands), length(Groups));
    stds = zeros(length(Bands), length(Groups));
    data_all = cell(length(Bands), length(Groups));

    for b = 1:length(Bands)
        band = Bands{b};
        for g = 1:length(Groups)
            group = Groups{g};
            filepath = fullfile(FileRoot, group, ['propertise', band, '.mat']);

            if exist(filepath, 'file')
                S = load(filepath);  % 加载变量
                values = S.propertise(:, p);
                data_all{b, g} = values;

                means(b, g) = mean(values, 'omitnan');
                stds(b, g) = std(values, 'omitnan');
            else
                error(['文件未找到: ', filepath]);
            end
        end
    end

    % 绘图
    figure('Name', PropertyNames{p}, 'Position', [200, 200, 1000, 800]);
    bar_handle = bar(means, 'grouped'); hold on;

    % 设置误差线
    [ngroups, nbars] = size(means);
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, means(:, i), stds(:, i), 'k.', 'LineWidth', 1.2);
    end

    % 设置颜色
    bar_handle(1).FaceColor = [0.4 0.8 0.4];  % Before
    bar_handle(2).FaceColor = [0.8 0.4 0.4];  % After
    bar_handle(3).FaceColor = [0.2 0.6 0.8];  % Control

    % 设置坐标轴等
    set(gca, 'XTickLabel', BandLabels, 'XTick', 1:length(BandLabels));
    xtickangle(45);
    ylabel('Value');
    title(PropertyNames{p});

    if strcmp(PropertyNames{p}, 'Characteristic Path Length')
        ylim([0.8, 1]);  % 可根据你的实际数据范围微调
    end

    % 设置坐标轴等
    set(gca, 'XTickLabel', BandLabels, 'XTick', 1:length(BandLabels), 'FontSize', 12);
    xtickangle(45);
    ylabel('Value', 'FontSize', 12);
    title(PropertyNames{p}, 'FontSize', 18);

    legend(GroupLabels, 'Location', 'northwest', 'FontSize', 14);
    grid on;

    % 显著性分析 + 连线 + 星号
    for b = 1:length(Bands)
        % 提取数据
        y1 = data_all{b,1}; % Before
        y2 = data_all{b,2}; % After
        y3 = data_all{b,3}; % Control

        % 取柱中心位置
        base_x = b;  % 第b组（频段）
        x1 = base_x - groupwidth/2 + groupwidth/6;
        x2 = base_x - groupwidth/2 + 3*groupwidth/6;
        x3 = base_x - groupwidth/2 + 5*groupwidth/6;

        y_max = max([means(b,:) + stds(b,:)]) * 1.05;

        % 初始化高度偏移
        y_shift = 0.02 * y_max;
        h = y_max;

        % 逐对比较
        [h012,p012] = ttest(y1, y2,Threshold,'left');  % Before vs After
        [h112,p112] = ttest(y1, y2,Threshold,'right');  % Before vs After
        h12 = h112 - h012;
        [h013,p013] = ttest2(y1, y3,Threshold,'left');  % Before vs Control
        [h113,p113] = ttest2(y1, y3,Threshold,'right');  % Before vs Control
        h13 = h113 - h013;
        [h023,p023] = ttest2(y2, y3,Threshold,'left');  % Before vs Control
        [h123,p123] = ttest2(y2, y3,Threshold,'right');  % Before vs Control
        h23 = h123 - h023;
        % 基础高度
        y_max = max([means(b,:) + stds(b,:)]) * 1;
        y_shift = 0.03 * y_max;
        
        % 固定每个比较的高度
        h12_pos = y_max;               % 最底层
        h23_pos = y_max + y_shift;     % 中间层
        h13_pos = y_max + 2*y_shift;   % 最上层
        if strcmp(PropertyNames{p}, 'Characteristic Path Length')
            y_shift = 0.01 * y_max;
            h23_pos = y_max + y_shift;     % 中间层
            h13_pos = y_max + 2*y_shift;   % 最上层
        end
        % 显著性连线和星号
        if h12 ~= 0
            plot([x1, x2], [h12_pos, h12_pos], 'k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
            text(mean([x1, x2]), h12_pos + y_shift * 0.2, '*', 'FontSize', 14, ...
                'HorizontalAlignment', 'center', 'HandleVisibility', 'off');
        end
        if h23 ~= 0
            plot([x2, x3], [h23_pos, h23_pos], 'k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
            text(mean([x2, x3]), h23_pos + y_shift * 0.2, '*', 'FontSize', 14, ...
                'HorizontalAlignment', 'center', 'HandleVisibility', 'off');
        end
        if h13 ~= 0
            plot([x1, x3], [h13_pos, h13_pos], 'k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
            text(mean([x1, x3]), h13_pos + y_shift * 0.2, '*', 'FontSize', 14, ...
                'HorizontalAlignment', 'center', 'HandleVisibility', 'off');
        end

    end
end
