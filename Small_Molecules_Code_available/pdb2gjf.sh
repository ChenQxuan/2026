#!/bin/bash

# 检查Multiwfn是否在PATH中
if ! command -v Multiwfn &> /dev/null; then
    echo "错误：未找到Multiwfn，请确保它已安装并在PATH中"
    exit 1
fi

# 检查模板文件是否存在
template="template.gjf"
if [ ! -f "$template" ]; then
    echo "错误：未找到模板文件 $template"
    exit 1
fi

# 创建输出目录
output_dir="gjf_files"
mkdir -p "$output_dir"

# 处理所有PDB文件
for pdb_file in *.pdb; do
    if [ -f "$pdb_file" ]; then
        # 去除文件扩展名获取基本名称
        base_name=$(basename "$pdb_file" .pdb)
        temp_gjf="temp_${base_name}.gjf"
        final_gjf="$output_dir/${base_name}.gjf"
        
        echo "正在处理: $pdb_file"
        
        # 使用Multiwfn处理PDB文件生成临时GJF
        Multiwfn "$pdb_file" << EOF > /dev/null
100
2
10
${temp_gjf}
0
q
EOF
        
        # 检查是否成功生成临时GJF文件
        if [ -f "$temp_gjf" ]; then
            # 提取Multiwfn生成文件的坐标部分（从包含电荷和自旋多重度的行开始）
            # 找到包含 "0 1" 或类似模式的行
            coord_start_line=$(grep -n "^ *[0-9] *[0-9]" "$temp_gjf" | head -1 | cut -d: -f1)
            
            if [ -n "$coord_start_line" ]; then
                # 提取坐标部分
                tail -n +$coord_start_line "$temp_gjf" > temp_coords.txt
                
                # 处理模板文件：替换[name]为文件名
                sed "s/\[name\]/${base_name}/g" "$template" > temp_header.txt
                
                # 移除模板中可能存在的坐标部分（从第一个包含数字和空格的模式开始）
                header_end_line=$(grep -n "^ *[0-9] *[0-9]" temp_header.txt | head -1 | cut -d: -f1)
                
                if [ -n "$header_end_line" ]; then
                    # 只保留模板的头部（计算设置部分）
                    head -n $((header_end_line - 1)) temp_header.txt > temp_clean_header.txt
                else
                    # 如果没有找到坐标开始行，使用整个模板作为头部
                    cp temp_header.txt temp_clean_header.txt
                fi
                
                # 合并处理后的头部和坐标
                cat temp_clean_header.txt temp_coords.txt > "$final_gjf"
                
                echo "已创建: $final_gjf"
                
                # 清理临时文件
                rm -f temp_header.txt temp_clean_header.txt temp_coords.txt
            else
                echo "警告：在 $temp_gjf 中未找到坐标起始行"
            fi
            
            # 删除临时文件
            rm -f "$temp_gjf"
            
        else
            echo "警告：未能成功处理 $pdb_file"
        fi
    fi
done

echo "转换完成！所有GJF文件保存在 $output_dir 目录中"