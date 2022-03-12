#!/bin/bash

# run each .asm with command in header comment

regex='; (nasm -f elf32 .*\.out)'

for d in src/*; do
    cd "$d"

    for f in *.asm; do
        echo "file: $d/$f"
        content=$(cat $f)
        if [[ $content =~ $regex ]]; then
            run_cmd="${BASH_REMATCH[1]}"
            echo "cmd: $run_cmd"
            eval "$run_cmd"
        else
            echo "NO RUN CMD"
            echo "NO RESULT"
        fi
        echo
    done

    cd ../..
done
