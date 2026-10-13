close all; clear; clc;

% 根路径
FileRoot = 'F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\';

% 组名和标签
Groups = {'1_before', '2_after', '3_control'};
GroupLabels = {'Before', 'After', 'Control'};

% 只看 Alpha 频段
Band = '8-13';   
BandLabel = 'Alpha';

% 网络属性
PropertyNames = {'Clustering Coefficient', 'Characteristic Path Length', ...
                 'Global Efficiency', 'Local Efficiency'};
Threshold = 0.05;

% 定义颜色（RGB）
colors = [0.4 0.8 0.4;  % Before - 绿色
          0.8 0.4 0.4;  % After  - 红色
          0.2 0.6 0.8]; % Control - 蓝色

% 标题背景颜色
title_bg_colors = [0.9 0.9 0.8;  % 浅绿色
                   0.9 0.9 0.8;  % 浅红色
                   0.9 0.9 0.8;  % 浅蓝色
                   0.9 0.9 0.8]; % 浅黄色

% ==== 新建1x4的大图 ====
figure('Name',['Network Properties - ' BandLabel], 'Position', [100, 200, 1600, 800]);

for p = 1:4
    data_all = cell(1, length(Groups));

    % ==== 提取数据 ====
    for g = 1:length(Groups)
        filepath = fullfile(FileRoot, Groups{g}, ['propertise', Band, '.mat']);
        if exist(filepath, 'file')
            S = load(filepath);  
            values = S.propertise(:, p);
            data_all{g} = values(:); % 保证是列向量
        else
            error(['文件未找到: ', filepath]);
        end
    end

    % ==== 拼接成箱线图输入格式 ====
    all_values = [];
    all_groups = [];
    for g = 1:length(Groups)
        all_values = [all_values; data_all{g}];
        all_groups = [all_groups; repmat(g, length(data_all{g}), 1)];
    end

    % ==== 子图 ====
    subplot(1,4,p);
    h = boxplot(all_values, all_groups, 'Labels', GroupLabels, 'Colors', 'k'); 
    hold on;

    % ==== 给箱体上色 ====
    boxes = findobj(gca, 'Tag', 'Box');
    for j = 1:length(boxes)
        patch(get(boxes(j), 'XData'), get(boxes(j), 'YData'), colors(length(boxes)-j+1,:), ...
              'FaceAlpha', 0.3, 'EdgeColor', 'k'); 
    end

    % ==== 绘制散点（jitter） ====
    jitter = 0.15; % 水平抖动范围
    for g = 1:length(Groups)
        x = g + (rand(size(data_all{g})) - 0.5) * jitter; % 水平抖动
        y = data_all{g};
        scatter(x, y, 40, 'MarkerFaceColor', colors(g,:), ...
                'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.7);
    end

    ylabel('Value', 'FontSize', 10);
    set(gca, 'FontSize', 10);
    grid on;

    % ==== 显著性检验和标注 ====
    y1 = data_all{1}; % Before
    y2 = data_all{2}; % After
    y3 = data_all{3}; % Control

    [~,p12] = ttest(y1,y2);
    [~,p13] = ttest2(y1,y3);
    [~,p23] = ttest2(y2,y3);

    % 获取当前Y轴范围
    y_lim = ylim;
    y_range = y_lim(2) - y_lim(1);
    
    % 计算显著性线的高度
    line_height = y_lim(2) + 0.05 * y_range;
    line_step = 0.05 * y_range;
    
    % 定义显著性水平对应的星号
    getStars = @(p) sprintf('%s', repmat('*', 1, (p < 0.005) + (p < 0.01) + (p < 0.05)));
    
    % 绘制组间显著性线和标注
    if p12 < Threshold
        plot([1, 2], [line_height, line_height], 'k-', 'LineWidth', 1.2);
        text(1.5, line_height + line_step/2, getStars(p12), ...
            'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        line_height = line_height + line_step;
    end
    
    if p23 < Threshold
        plot([2, 3], [line_height, line_height], 'k-', 'LineWidth', 1.2);
        text(2.5, line_height + line_step/2, getStars(p23), ...
            'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        line_height = line_height + line_step;
    end
    
    if p13 < Threshold
        plot([1, 3], [line_height, line_height], 'k-', 'LineWidth', 1.2);
        text(2, line_height + line_step/2, getStars(p13), ...
            'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % 调整Y轴范围以显示显著性标记
    if any([p12, p13, p23] < Threshold)
        ylim([y_lim(1), y_lim(2) + 0.15 * y_range]);
    end
    
    % ==== 添加带背景颜色的标题 ====
    % 获取当前坐标轴位置
    ax_pos = get(gca, 'Position');
    
    % 计算标题框的宽度（与X轴长度匹配）
    title_width = ax_pos(3);  % 使用坐标轴宽度的80%
    title_height = 0.04;  % 固定高度
    
    % 计算标题框的位置（居中）
    title_x = ax_pos(1) + (ax_pos(3) - title_width) / 2;
    title_y = ax_pos(2) + ax_pos(4);  % 稍微向上调整位置
    
    % 创建标题文本框
    annotation('textbox', [title_x, title_y, title_width, title_height], ...
        'String', PropertyNames{p}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', title_bg_colors(p,:), ...
        'EdgeColor', 'k', ...
        'LineWidth', 1.5, ...
        'Margin', 3);  % 减小内边距
    %% ==== 保存图片为 EPS 和 JPG ====
    save_dir = 'C:\Users\pc\Desktop\python画连接图\图2\';
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end
    
    file_base = fullfile(save_dir, ['Network Properties - ' BandLabel]);
    
    print(gcf, [file_base '.eps'], '-depsc', '-painters');
    print(gcf, [file_base '.jpg'], '-djpeg', '-painters');
end
