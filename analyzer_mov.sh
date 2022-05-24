#!/bin/bash

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

declare -r mov_complet="https://pelispop.me/peliculas-catalogo-completo/"
declare -r mov_recently_added="https://pelispop.me/peliculas-agregadas-recientemente/"
declare -r mov_netflix="https://pelispop.me/peliculas-de-netflix/"

#Colours
declare -r greenColour="\e[0;32m\033[1m"
declare -r endColour="\033[0m\e[0m"
declare -r redColour="\e[0;31m\033[1m"
declare -r blueColour="\e[0;34m\033[1m"
declare -r yellowColour="\e[0;33m\033[1m"
declare -r purpleColour="\e[0;35m\033[1m"
declare -r turquoiseColour="\e[0;36m\033[1m"
declare -r grayColour="\e[0;37m\033[1m"

function help_panel(){
    echo -e "${yellowColour}[*] Usage ${endColour}"
    for ((i=0;i<80;i++));do echo -ne "${redColour}-${endColour}"; done; echo
    echo -e "\t${yellowColour}[-e] Mode explore ${endColour}${yellowColour}\texample ./mov_analyzer -e 1${endColour}"
    echo -e "\t\t${purpleColour}1)List_movies${endColour}"
    echo -e "\t\t${purpleColour}2)Recently_movies${endColour}"
    echo -e "\t\t${purpleColour}3)Movies_netflix${endColour}"
    echo -e "\t\t${purpleColour}4)Find_films${endColour}"
    echo -e "\t${yellowColour}[-n]Output arguments${endColour}"
    echo -e "\t\t${purpleColour}Usage ./mov_analyzer -e mode_explore -n Output_movies${endColour}"
}
function delete_cache(){
  rm mov* mov_ file* 2>/dev/null
  
}
function ctrl_c(){
    tput cnorm
    echo -e "\n\n${redColour}[!] Exiting...${endColour}"
    exit 1
}
trap ctrl_c SIGINT

function find_film(){
  for ((i=0;i<80;i++)); do echo -ne "${redColour}*${endColour}"; done; echo
    echo -ne "\t\t\t\t${yellowColour}Looking for movie${endColour}"; echo
  for ((i=0;i<80;i++)); do echo -ne "${redColour}*${endColour}"; done; echo
  echo -ne "\t${purpleColour}[*] insert name movie : "
  read name 
   ${endColour}
   movie=$(curl -s "https://pelispop.me/?s="$name"" | html2text | grep -P "^#*\s" -A 1 | grep -v "*" | tr -d '#*()' | sed 's/\[.*\]//' |  tr -d ' ' | cut -d "/" -f1-4 | grep "\https.*\s*\S*" -A 1 | grep -vP "^[0-5]" | grep -v "^-" | head -n 8 | xargs | sed 's/https\:\/\//\n/g' | tr -d ' ' | cut -d "/" -f1,2
)
  if [ ! $movie ]; then 
       echo -e "\t\t${yellowColour}Any result${endColour}"
       ctrl_c
  fi
count=0;for mov in $movie; do let count+=1; echo "$count) $mov"; done

until [ $option -le $count ]; do 
  echo -en "\t\t${yellowColour}Insert number of the movie: "; read option "${endColour}"
  message=$(if [ $option -gt $count ]; then echo 1;else echo 0; fi)
   
  view_movie $message "$(echo $movie)" $option
  done
  


}
function view_movie()
{
  echo '' > file.tmp
  if [ $1 -eq 0 ]; then 
    for mov in $2;do
    echo $mov >> file.tmp
    done
  fi
  url=$(cat file.tmp | sed '/^ *$/d' | awk "NR==$3") #remove white space 
  echo '' > mov_
  curl -s "https://$url/" | html2text | grep -i "sinopsis" -A 20 >> mov_
  while read line ; do echo -e "${yellowColour}$line${endColour}" ; done < mov_
  echo -ne "\t\t${redColour}watch movie: "; read option "${endColour}"

  until [ $option == "yes" ]; do
    find_film 
  done

  firefox $url 2>/dev/null $
    delete_cache
   ctrl_c
}
function movies(){
  number_output=$1
  category=$2
  echo '' > mov.tmp

while [ "$(cat mov.tmp | wc -l)" -eq 1 ]; do
  movies=$(curl -s $category | html2text | grep -P "^#*\s" |grep -v "*" | tr -d '#*|' | grep -oP '\[.*\]' | tr -d '[]\-' | head -n $number_output >> mov.tmp)
done

    echo "Movies" > mov.table
    while read movie; do echo "${movie}" >> mov.table; done < mov.tmp

    printTable "-" "$(less mov.table)"
    delete_cache
}



parameter_counter=0;while getopts ":e:n:h" args; do
        case $args in
        e)exploration_mode=$OPTARG;let parameter_counter+=1;;
        n)number_output=$OPTARG;let parameter_counter+=1;;
        h)help_panel;;
      esac
done
if [ $parameter_counter -eq 0  ]; then
  help_panel
elif [ "$(echo $exploration_mode)" -eq 1 ]; then
        if [ ! "$number_output" ]; then
            number_output=30
            movies $number_output $mov_complet
          else
           movies $number_output $mov_complet 
        fi
elif [ "$(echo $exploration_mode)" -eq 2 ]; then
         if [ ! "$number_output" ]; then
            number_output=30
            movies $number_output $mov_recently_added
          else
           movies $number_output $mov_recently_added
        fi
elif [ "$(echo $exploration_mode)" -eq 3 ]; then 
       if [ ! "$number_output" ]; then
            number_output=30
            movies $number_output $mov_netflix
          else
           movies $number_output $mov_netflix
        fi
elif [ "$(echo $exploration_mode)" -eq 4 ]; then

  find_film
fi 2>/dev/null


