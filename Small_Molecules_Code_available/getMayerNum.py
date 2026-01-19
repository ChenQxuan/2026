def count_bond_orders_below_threshold(filename, threshold=0.9):
    """
    统计result.txt文件中每个molecule部分键级小于指定阈值的数目
    
    参数:
    filename: 文件名
    threshold: 阈值，默认为0.9
    
    返回:
    包含每个molecule统计结果的字典
    """
    results = {}
    current_molecule = None
    count_below_threshold = 0
    
    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            line = line.strip()
            
            # 检测新的molecule开始
            if line.startswith('=====') and line.endswith('====='):
                if current_molecule is not None:
                    # 保存上一个molecule的结果
                    results[current_molecule] = count_below_threshold
                
                # 重置计数器和当前molecule
                current_molecule = line.strip('= ').strip()
                count_below_threshold = 0
                continue
            
            # 处理键级数据行
            if line.startswith('#') and ':' in line and len(line.split()) >= 5:
                try:
                    # 提取最后一列的键级值
                    parts = line.split()
                    bond_order = float(parts[-1])
                    
                    # 检查是否小于阈值
                    if bond_order < threshold:
                        count_below_threshold += 1
                except (ValueError, IndexError):
                    # 跳过无法解析的行
                    continue
    
    # 添加最后一个molecule的结果
    if current_molecule is not None:
        results[current_molecule] = count_below_threshold
    
    return results

def main():
    filename = 'result.txt'  # 你的文件名
    
    # 统计键级小于0.9的数目
    results = count_bond_orders_below_threshold(filename, 0.9)
    
    # 输出结果
    print("各molecule中键级小于0.9的数目统计:")
    print("=" * 50)
    
    total_count = 0
    for molecule, count in results.items():
        print(f"{molecule}: {count} 个")
        total_count += count
    
    print("=" * 50)
    print(f"总计: {total_count} 个")
    print(f"molecule总数: {len(results)} 个")
    
    # 可选：保存结果到文件
    with open('bond_order_statistics.txt', 'w', encoding='utf-8') as output_file:
        output_file.write("各molecule中键级小于0.9的数目统计:\n")
        output_file.write("=" * 50 + "\n")
        for molecule, count in results.items():
            output_file.write(f"{molecule}: {count} 个\n")
        output_file.write("=" * 50 + "\n")
        output_file.write(f"总计: {total_count} 个\n")
        output_file.write(f"molecule总数: {len(results)} 个\n")

if __name__ == "__main__":
    main()