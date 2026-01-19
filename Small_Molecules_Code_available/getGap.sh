#!/bin/bash

# 脚本功能：使用Multiwfn批量计算当前目录下所有.fch文件的HOMO-LUMO gap

echo "开始计算HOMO-LUMO gap..."
echo "Multiwfn批量处理中..."

# 检查当前目录下是否存在.fch文件
if ls *.fch 1> /dev/null 2>&1; then
    echo "找到.fch文件，开始处理..."
else
    echo "错误：当前目录下没有找到任何.fch文件！"
    exit 1
fi

# 检查Multiwfn是否可用
if ! command -v Multiwfn &> /dev/null; then
    echo "错误：找不到 Multiwfn 命令，请确保Multiwfn已正确安装"
    echo "请将Multiwfn添加到PATH环境变量中"
    exit 1
fi

# 输出文件头
output_file="Gap.txt"
echo "HOMO-LUMO Gap Calculation Results" > "$output_file"
echo "=================================" >> "$output_file"
echo "File Name         HOMO (eV)    LUMO (eV)    Gap (eV)" >> "$output_file"
echo "----------------------------------------------------" >> "$output_file"

# 计数器
count=0
success_count=0

# 遍历所有.fch文件
for fch_file in *.fch; do
    echo "正在处理: $fch_file"
    ((count++))
    
    # 创建Multiwfn的输入命令文件 - 直接进入功能0然后退出
    cat > multiwfn_input.txt << EOF
0
q
EOF

    # 运行Multiwfn并捕获输出
    output=$(Multiwfn_noGUI "$fch_file" < multiwfn_input.txt 2>/dev/null)
    
    # 从输出中精确提取HOMO、LUMO和Gap能量（eV单位）
    # 使用awk精确提取数字部分
    homo_energy=$(echo "$output" | grep "HOMO.*energy:" | awk '{for(i=1;i<=NF;i++) if($i=="eV") print $(i-1)}')
    lumo_energy=$(echo "$output" | grep "LUMO.*energy:" | awk '{for(i=1;i<=NF;i++) if($i=="eV") print $(i-1)}')
    gap_energy=$(echo "$output" | grep "HOMO-LUMO gap:" | awk '{for(i=1;i<=NF;i++) if($i=="eV") print $(i-1)}')
    
    # 检查是否成功提取到能量值
    if [ -n "$homo_energy" ] && [ -n "$lumo_energy" ] && [ -n "$gap_energy" ]; then
        # 格式化输出
        printf "%-18s %10.4f %12.4f %10.4f\n" \
               "$fch_file" "$homo_energy" "$lumo_energy" "$gap_energy" >> "$output_file"
        
        echo "  ✓ 成功计算: HOMO=$homo_energy eV, LUMO=$lumo_energy eV, Gap=$gap_energy eV"
        ((success_count++))
    else
        echo "  ✗ 提取能量失败: $fch_file" | tee -a "$output_file"
        
        # 显示相关输出片段用于调试
        echo "$output" | grep -A2 -B2 "HOMO\|LUMO\|gap" | head -10 >> "$output_file"
    fi
    
    echo "----------------------------------------"
    
    # 清理临时文件
    rm -f multiwfn_input.txt
done

# 输出总结信息
echo "处理完成！" | tee -a "$output_file"
echo "总共处理: $count 个文件" | tee -a "$output_file"
echo "成功计算: $success_count 个文件" | tee -a "$output_file"
echo "结果已保存到: $output_file" | tee -a "$output_file"

# 显示结果文件内容
echo ""
echo "最终结果："
cat "$output_file"