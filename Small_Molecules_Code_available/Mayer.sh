#!/bin/bash

# 脚本名称: analyze_bond_orders_fixed.sh
# 功能: 批量处理 .fch 文件，使用 Multiwfn 计算 Mayer 键级，提取结果并统计键级<0.9的数量
# 修正: 改进awk命令以正确解析键级值

# 定义输出文件
output_file="result_fixed.txt"

# 清空或创建最终的结果文件
echo "Multiwfn Mayer Bond Order Analysis Results (Corrected)" > "$output_file"
echo "=====================================================" >> "$output_file"
echo "" >> "$output_file"

# 循环处理当前目录下的所有 .fch 文件
for fchfile in *.fch; do
    # 检查是否存在 .fch 文件，避免找不到文件时循环执行
    if [ ! -f "$fchfile" ]; then
        echo "警告: 未找到任何 .fch 文件。"
        exit 1
    fi

    echo "正在处理文件: $fchfile"
    base_name=$(basename "$fchfile" .fch)

    # 创建 Multiwfn 的输入命令文件
    cat > input.txt << EOF
9
1
q
EOF

    # 运行 Multiwfn，将预先生成的输入命令通过重定向传递给它，并捕获输出
    multiwfn_output=$(Multiwfn_noGUI "$fchfile" < input.txt 2>&1)

    # 清理临时输入文件
    rm -f input.txt

    # 从输出中提取关键部分 (从 "Bond orders..." 到 "Total valences...")
    extracted_section=$(echo "$multiwfn_output" | sed -n '/Bond orders with absolute value >=  0.050000/,/Total valences and free valences defined by Mayer/p' | head -n -1)

    # 将提取出的部分写入结果文件，并添加文件名作为标记
    echo "---- 结果文件: $fchfile ----" >> "$output_file"
    echo "$extracted_section" >> "$output_file"
    echo "" >> "$output_file"

    # 分析提取出的部分，计算键级小于 0.9 的键的数量
    # 改进的awk命令：更精确地匹配数据行和提取第4列
    count=$(echo "$extracted_section" | awk '
        /^ # [0-9]+:/ {
            # 确保行有足够多的字段
            if (NF >= 5) {
                # 第4列是键级值
                bond_order = $4
                # 检查是否为数字
                if (bond_order + 0 == bond_order && bond_order < 0.9) {
                    count++
                }
            }
        }
        END {print count+0}')  # 确保输出数字，即使为0

    # 调试信息：查看提取的行数
    line_count=$(echo "$extracted_section" | wc -l)
    echo "提取了 $line_count 行数据" >> "$output_file"
    echo "找到 $count 个键级 < 0.9 的键" >> "$output_file"

    # 将统计结果追加到结果文件
    echo ">> 在文件 $fchfile 中，键级小于 0.9 的键的数量为: $count" >> "$output_file"
    echo "" >> "$output_file"
    echo "----------------------------------------" >> "$output_file"
    echo "" >> "$output_file"

    echo "文件 $fchfile 处理完成。找到 $count 个键级 < 0.9 的键。"
done

echo "所有文件处理完毕！详细结果已保存到 $output_file。"