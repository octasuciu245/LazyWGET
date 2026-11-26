#!/bin/bash
workspace="lwget_data"
history_log="$workspace/visited.log"
 

if [ -z "$1" ] && [ ! -d "$workspace" ]; then

    echo "Te rog introdu un link"

    echo "Exemplu: ./lwget <URL>"

    exit 1

fi
 
root_url=$1
 

mkdir -p "$workspace"
 

get_last_level() {


    last=$(ls -d "$workspace"/nivel_* 2>/dev/null | sort -V | tail -n 1)

    if [ -z "$last" ]; then

        echo "-1" 

    else

        echo "${last##*_}"

    fi

}
 

last_level=$(get_last_level)

current_level=$((last_level + 1))
 

dir_current="$workspace/nivel_$current_level"

dir_prev="$workspace/nivel_$last_level"



if [ "$last_level" -eq "-1" ]; then

    if [ -z "$root_url" ]; then

        echo "Te rog introdu un link"

        exit 1

    fi
 
    echo "Se descarca radacina..."

    mkdir -p "$dir_current"

    touch "$history_log"


    wget -q -P "$dir_current" "$root_url"

  

    echo "$root_url" >> "$history_log"

    echo "Datele au fost descarcate in folderul $workspace"

    exit 0

fi
 

echo "Evaluam promisiunile din $dir_prev"
 
mkdir -p "$dir_current"
 


shopt -s nullglob

source_files=("$dir_prev"/*)
 
if [ ${#source_files[@]} -eq 0 ]; then

    echo "Nu exista fisiere anterioare. Stop."

    rmdir "$dir_current"

    exit 0

fi
 
for file in "${source_files[@]}"; do

    echo "Parsez fisierul: $file"



    found_promises=$(grep -oE 'href="http[^"]+"' "$file" | cut -d'"' -f2)

    for url in $found_promises; do



        if grep -Fqx "$url" "$history_log"; then

            continue

        else

            echo "Promisiune gasita,se descarca acum: $url"

            wget -q -T 5 -t 1 -P "$dir_current" "$url"

            if [ $? -eq 0 ]; then

                echo "$url" >> "$history_log"

            else

                echo "Link-ul nu poate fi descarcat: $url"

            fi

        fi

    done

done
 

if [ -z "$(ls -A "$dir_current")" ]; then

    echo "Nivelul $current_level este gol"

    rmdir "$dir_current"

else

    echo "Nivelul $current_level este gata"

fi
 

if command -v tree &> /dev/null; then

    echo "Structura actuala:"

    tree "$workspace"

fi
 
