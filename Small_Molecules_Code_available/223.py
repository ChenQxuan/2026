import pandas as pd
import os
import subprocess
import sys

def check_openbabel():
    """检查Open Babel是否安装"""
    try:
        result = subprocess.run(['obabel', '-V'], capture_output=True, text=True)
        return result.returncode == 0
    except:
        return False

def smiles_to_3d_openbabel(excel_file, output_dir="3d_structures_ob"):
    """
    使用Open Babel从Excel文件读取SMILES并批量转换为3D结构
    """
    
    if not check_openbabel():
        print("错误: 未找到Open Babel，请先安装")
        print("安装命令: conda install -c conda-forge openbabel")
        return
    
    # 创建输出目录
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # 读取Excel文件
    print(f"正在读取Excel文件: {excel_file}")
    try:
        df = pd.read_excel(excel_file)
        smiles_list = df.iloc[:, 0].tolist()[1:]  # 跳过第一行标题
        print(f"找到 {len(smiles_list)} 个SMILES字符串")
    except Exception as e:
        print(f"读取Excel文件失败: {e}")
        return
    
    success_count = 0
    fail_count = 0
    
    for i, smiles in enumerate(smiles_list, 1):
        if pd.isna(smiles) or not isinstance(smiles, str) or smiles.strip() == "":
            continue
            
        smiles = smiles.strip()
        print(f"处理第 {i} 个分子: {smiles}")
        
        try:
            # 创建临时smi文件
            temp_smi = os.path.join(output_dir, f"temp_{i}.smi")
            with open(temp_smi, 'w') as f:
                f.write(smiles)
            
            # 输出文件
            output_file = os.path.join(output_dir, f"molecule_{i:04d}.pdb")
            
            # 使用Open Babel转换
            # --gen3d: 生成3D坐标
            # -h: 添加氢原子
            cmd = f'obabel -ismi {temp_smi} -opdb -O {output_file} --gen3d -h'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode == 0 and os.path.exists(output_file):
                print(f"  成功保存: {output_file}")
                success_count += 1
            else:
                print(f"  转换失败")
                fail_count += 1
            
            # 删除临时文件
            if os.path.exists(temp_smi):
                os.remove(temp_smi)
                
        except Exception as e:
            print(f"  处理失败: {e}")
            fail_count += 1
    
    print(f"\n处理完成！成功: {success_count}, 失败: {fail_count}")

# 使用示例
if __name__ == "__main__":
    smiles_to_3d_openbabel("Stable_molecules_ranged.xlsx")