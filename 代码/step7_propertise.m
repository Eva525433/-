% 算出网络属性
close all
clear all
clc
PLV_result='F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\2_afterwpli\8-13\';
propertise_resule='F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\2_afterwpli\';mkdir(propertise_resule);
eval(['load',' ',PLV_result,'fuzzyEntropy.mat']);
for Sub = 1:length(T_time(1,1,:))
    CorrMatrix = squeeze(T_time(:,:,Sub));
    [m,n]=size(CorrMatrix);
    Re_CorrMatrix = (CorrMatrix + CorrMatrix') / 2;

    %聚类系数
    Cluster = mean(clustering_coef_wu(Re_CorrMatrix));
    %路径长度
    Matrix11 = ones(size(Re_CorrMatrix))-Re_CorrMatrix;
    Matrix11(1:n+1:end) = 0;
    [D11 B11] = distance_wei(Matrix11);%D11为两个节点的最短路径长度
    CharpNet = sum(sum(D11))/(m*(m-1));%m为
    %全局效率
    E_glo = efficiency_wei(Re_CorrMatrix);
    %局部效率
    E_loc = mean(efficiency_wei(Re_CorrMatrix,1));
    %同配系数
    %ass = mean(degrees_und(Re_CorrMatrix)); 
    propertise(Sub,1)=Cluster ;
    propertise(Sub,2)=CharpNet ;
    propertise(Sub,3)=E_glo ;
    propertise(Sub,4)=E_loc ;
    clear CorrMatrix Re_CorrMatrix Cluster CharpNet E_glo E_loc
end 
save([propertise_resule,'propertise8-13.mat'],'propertise');%将计算的几个网络属性保存在文件夹中