import re

def replace_inline_code(text: str) -> str:
    """
    **Description**
    用于替换文本中单反引号（`...`）包裹的内容，将每个字符替换成 '___'。
    
    **Params**
    - `text`: 输入的 Markdown 文本字符串。
    
    **Returns**
    - 替换后的字符串。
    """
    # 匹配多反引号块，先保留位置避免误替换
    code_blocks = []
    def block_replacer(match):
        code_blocks.append(match.group(0))
        return f"[[BLOCK_{len(code_blocks)-1}]]"
    
    text = re.sub(r'(`{3,}[\s\S]*?`{3,})', block_replacer, text)

    # 替换单反引号内的内容
    def inline_replacer(match):
        inner = match.group(1)
        replaced = ''.join(['___' for _ in inner])
        return f'`{replaced}`'
    
    text = re.sub(r'`([^`\n]+?)`', inline_replacer, text)

    # 恢复多反引号块
    for i, block in enumerate(code_blocks):
        text = text.replace(f"[[BLOCK_{i}]]", block)

    return text

def process_file(input_file: str, output_file: str) -> None:
    """
    **Description**
    处理指定 Markdown 文件，将其中单反引号内的内容替换后保存到新文件。
    
    **Params**
    - `input_file`: 输入文件路径。
    - `output_file`: 输出文件路径。
    
    **Returns**
    - None
    """
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    replaced_content = replace_inline_code(content)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(replaced_content)

if __name__ == '__main__':
    # 示例调用：修改文件名即可
    input_md = './课堂笔记.md'
    output_md = './笔记测试.md'
    process_file(input_md, output_md)
    print(f"已处理完成，输出文件：{output_md}")