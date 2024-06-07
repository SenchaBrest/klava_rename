import os

def read_files_recursively(directory):
    all_text = []
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    all_text.append(content)
            except Exception as e:
                print(f"Could not read file {file_path}: {e}")

    return all_text

def write_to_output_file(text_list, output_file):
    with open(output_file, 'w', encoding='utf-8') as f:
        for text in text_list:
            f.write(text)
            f.write('\n' * 5)  # Пять пустых строк между содержимым разных файлов

if __name__ == "__main__":
    current_directory = os.getcwd()
    output_file = "merged_output.txt"

    all_text = read_files_recursively(current_directory)
    write_to_output_file(all_text, output_file)

    print(f"All files have been merged into {output_file}")
