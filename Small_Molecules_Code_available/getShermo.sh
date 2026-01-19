#!/bin/bash

# 清空或创建结果文件
> result.txt

# 遍历当前目录下所有.out文件
for file in *.out; do
    if [ -f "$file" ]; then
        echo "Processing $file..." >&2
        
        # 在结果文件中添加文件名作为分隔
        echo "===== $file =====" >> result.txt
        
        # 运行Shermo并提取从"========== Total =========="开始的所有内容
        Shermo "$file" | awk '/========== Total ==========/{flag=1} flag' >> result.txt
        
        # 添加空行分隔不同文件的结果
        echo -e "\n" >> result.txt
    fi
done

echo "All results saved to result.txt"