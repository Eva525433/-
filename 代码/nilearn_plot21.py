import os
import numpy as np
import pandas as pd
from scipy.io import loadmat
from nilearn import plotting
import matplotlib.pyplot as plt
import mat73
import matplotlib.cm as cm

# ==== 文件路径 ====
mat_path = "C:/Users/pc/Desktop/python画连接图/R_mat1.mat.mat"
coord_path = "C:/Users/pc/Desktop/python画连接图/Coordinates3.txt"

# ==== 自动读取 .mat 文件（兼容 v7 / v7.3） ====
try:
    # 尝试用 scipy 读取（适用于v7及以下）
    mat = loadmat(mat_path)
    if 'B0' in mat:
        FC_Matrix = mat['B0']
    else:
        # 打印所有变量名供你确认
        print("⚠️ 未找到变量 'B0'，文件包含变量：", mat.keys())
        raise KeyError
except Exception:
    # 如果失败，尝试 mat73（适用于 v7.3 HDF5 格式）
    print("尝试使用 mat73 读取 v7.3 格式...")
    mat = mat73.loadmat(mat_path)
    FC_Matrix = mat['B0']

# ==== 确保是 numpy 数组 ====
FC_Matrix = np.array(FC_Matrix)
print("✅ FC 矩阵维度:", FC_Matrix.shape)
FC_Matrix = FC_Matrix + FC_Matrix.T
# ==== 读取脑区坐标 ====
coords = pd.read_csv(coord_path, delim_whitespace=True, header=None).values[:, 0:3]
print("✅ 坐标维度:", coords.shape)
# ==== 每个节点使用不同颜色 ====
n_nodes = FC_Matrix.shape[0]
cmap = cm.get_cmap('Pastel1', n_nodes)  # 浅色 colormap
node_colors = [cmap(i) for i in range(n_nodes)]
# ==== 绘制脑连接图 ====
plotting.plot_connectome(0.9*FC_Matrix, coords,
                         node_color=node_colors,
                         #node_size=100*node_strength,
                         #edge_threshold="70%",
                         #edge_cmap='brg',
                         colorbar=True
                         )

# save_dir = "C:/Users/pc/Desktop/python画连接图/图/"
# filename = "8-13rPANSS"
#
# # EPS（矢量图，高分辨率）
# plt.savefig(os.path.join(save_dir, f"{filename}.eps"), format='eps', dpi=1000)
#
# # JPG（位图，高分辨率）
# plt.savefig(os.path.join(save_dir, f"{filename}.jpg"), format='jpg', dpi=1000, bbox_inches='tight')
#
# plt.show()


# import os
# import numpy as np
# import xlrd
# from scipy import io
# from scipy.io import loadmat
# from nilearn import plotting
# import pandas as pd
# import h5py
# import matplotlib.pyplot as plt
# import mat73
# # 指定要读取的文本文件的文件路径
# file_path = "C:/Users/pc/Desktop/python画连接图/Coordinates2.txt"
# # 指定要读取的文本文件的文件路径
#
# mat = h5py.File('C:/Users/pc/Desktop/python画连接图/t.mat','r')
# # a = mat73.loadmat('F:/毕业交接/审稿意见/ciPLV/result/RSCZ_SCZ/8-13.mat')
# #mat = h5py.File('F:/毕业交接/结果/模型可靠性验证/BD-c_vs_SZ-c.mat','r')
# #FC_Matrix = mat.get('r')
# FC_Matrix = mat['R_mat']
#
#
# #mat = io.loadmat('F:/毕业交接/结果/特有成分相关性/BD/特有成分/ymrs.mat')
# #FC_Matrix = mat["r"]
# FC_Matrix = np.array(FC_Matrix)
# FC_Matrix = np.transpose(FC_Matrix)
# # 使用pandas的read_csv函数读取数据（假设数据以空格或制表符分隔）
# data = pd.read_csv(file_path, delim_whitespace=True, header=None)
# data = np.array(data)
# coords = data[:,0:3]
#
# #node_strength = np.sum(np.abs(FC_Matrix), axis=0)
# #node_strength /= np.max(node_strength)
# # 连接
# plotting.plot_connectome(0.9*FC_Matrix, coords,
#                          node_color='#61bfad',
#                          #node_size=100*node_strength,
#                          #edge_threshold="70%",
#                          #edge_cmap='brg',
#                          colorbar=True
#                          )
# #plt.show()
#
# # plt.savefig('F:/毕业交接/审稿意见/ciPLV/result/RSCZ_SCZ/8-13.eps', format='eps', dpi=1000)
# #plt.savefig('F:/毕业交接/论文图/BD-c_vs_SZ-c.eps', format='eps', dpi=1000)
# plt.show()



# 计算每个节点的归一化绝对强度
#node_strength = np.sum(np.abs(FC_Matrix), axis=0)
#node_strength /= np.max(node_strength)
# 画节点图
#plotting.plot_markers(node_strength, coords, title='', )
#plt.show()
