#!/bin/bash

# Проверка количества аргументов
if [ $# -lt 2 ]; then
    echo "Использование: $0 <входная_директория> <выходная_директория> [--max_depth N]"
    exit 1
fi

input_dir="$1"
output_dir="$2"
max_depth=""

if [ "$3" = "--max_depth" ] && [ -n "$4" ]; then
    max_depth="$4"
fi

if [ ! -d "$input_dir" ]; then
    echo "Ошибка: Входная директория не существует"
    exit 1
fi

if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

copy_files() {
    local current_dir="$1"
    local current_depth="$2"
    local target_dir="$3"
    
    if [ -n "$max_depth" ] && [ "$current_depth" -gt "$max_depth" ]; then
        return
    fi
    
    if [ -n "$max_depth" ]; then
        local relative_path="${current_dir#$input_dir}"
        if [ -n "$relative_path" ]; then
            mkdir -p "$target_dir$relative_path"
            target_dir="$target_dir$relative_path"
        fi
    fi
    
    for item in "$current_dir"/*; do
        if [ -f "$item" ]; then
            filename=$(basename "$item")
            if [ -n "$max_depth" ]; then
                cp "$item" "$target_dir/"
            else
                base="${filename%.*}"
                ext="${filename##*.}"
                counter=1
                new_filename="$filename"
                
                while [ -f "$output_dir/$new_filename" ]; do
                    new_filename="${base}${counter}.${ext}"
                    counter=$((counter + 1))
                done
                
                cp "$item" "$output_dir/$new_filename"
            fi
        elif [ -d "$item" ]; then
            copy_files "$item" $((current_depth + 1)) "$target_dir"
        fi
    done
}

copy_files "$input_dir" 1 "$output_dir" 