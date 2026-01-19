#!/bin/bash

# 脚本功能：批量将当前目录下的所有.chk文件转换为.fchk，并重命名为.fch后缀

echo "开始处理.chk文件转换..."

# 检查当前目录下是否存在.chk文件
if ls *.chk 1> /dev/null 2>&1; then
    echo "找到.chk文件，开始转换..."
else
    echo "错误：当前目录下没有找到任何.chk文件！"
    exit 1
fi

# 检查formchk命令是否可用
if ! command -v formchk &> /dev/null; then
    echo "错误：找不到 formchk 命令，请确保Gaussian环境已配置"
    echo "尝试手动设置Gaussian环境变量，例如："
    echo "source /opt/gaussian/g16/bsd/g16.profile"
    exit 1
fi

# 计数器
count=0
success_count=0

# 遍历所有.chk文件
for chk_file in *.chk; do
    # 提取文件名（不带扩展名）
    base_name="${chk_file%.chk}"
    fchk_file="${base_name}.fchk"
    final_file="${base_name}.fch"
    
    echo "正在处理: $chk_file"
    ((count++))
    
    # 执行formchk转换
    if formchk "$chk_file" "$fchk_file"; then
        echo "  ✓ 成功转换: $chk_file → $fchk_file"
        
        # 重命名.fchk为.fch
        if mv "$fchk_file" "$final_file"; then
            echo "  ✓ 成功重命名: $fchk_file → $final_file"
            ((success_count++))
        else
            echo "  ✗ 重命名失败: $fchk_file"
        fi
    else
        echo "  ✗ 转换失败: $chk_file"
    fi
    echo "----------------------------------------"
done

# 输出总结信息
echo "处理完成！"
echo "总共尝试处理: $count 个文件"
echo "成功转换: $success_count 个文件"

if [ $count -gt 0 ] && [ $success_count -eq 0 ]; then
    echo "警告：所有文件转换都失败了，请检查："
    echo "1. Gaussian环境变量是否设置正确"
    echo "2. .chk文件是否完整可用"
    echo "3. 是否有足够的磁盘空间和权限"
fi