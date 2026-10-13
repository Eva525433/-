clear all
close all
clc

[x, y, z] = textread('F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\loc_21.txt');
for ii = 1:length(x)
    xyz_elec(ii,1) = x(ii);
    xyz_elec(ii,2) = y(ii);
    xyz_elec(ii,3) = z(ii);
end
xyz_dipoles = load('corti869-3000dipoles.dat');
% Calculate the dipole orientations.
xyz_dipOri  = bsxfun ( @rdivide, xyz_dipoles, sqrt ( sum ( xyz_dipoles .^ 2, 2 ) ) );
xyz_dipOri ( 2601: 3000, 1 ) = 0;
xyz_dipOri ( 2601: 3000, 2 ) = 0;
xyz_dipOri ( 2601: 3000, 3 ) = 1;
% ------------------
% define headmodel
headmodel        = [];
headmodel.type   = 'concentricspheres';
headmodel.o      = [ 0.0000 0.0000 0.0000 ];
headmodel.r      = [ 0.8700,0.9200,1];
headmodel.cond   = [ 1.0000,0.0125,1];
headmodel.tissue = { 'brain' 'skull' 'scalp' };
% -------------------
% calculate leadfield
[Lead_Field,~] = dong_calc_leadfield3(xyz_elec,xyz_dipoles,xyz_dipOri,headmodel);
G = Lead_Field;
G_ave = mean(G);
G_ave = G-repmat(G_ave, size(G, 1), 1);
Ra = G*pinv(G_ave, 0.05);   % the value 0.05 is for real data; for simulated data, it may be set as zero.
clear G G_ave;

path = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\3_EEGData\3_control\';
savepath = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\4_restData\3_control\';mkdir(savepath);
keyword = data_load(path,'.mat');
for sub = 1:length(keyword)
    load([path,keyword{sub}]);
    % re-reference to REST
    cur_var = [];cur_ave = [];cur_var1 = [];
    cur_var = EEG.data;
    cur_ave = mean(cur_var);
    cur_var1 = cur_var-repmat(cur_ave, size(cur_var, 1), 1);
    cur_var = Ra*cur_var1;
    cur_var = cur_var1 + repmat(mean(cur_var), size(cur_var, 1), 1); % edit by Li Dong (2017.8.28)
    EEG.data = cur_var;
    save([savepath,keyword{sub}(1:end-4),'.mat'], 'EEG');
    clear EEG
end