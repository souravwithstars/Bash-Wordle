#! /bin/bash

function generate_word () {
    local pattern="$1"
    local number=$( grep "${pattern}" /usr/share/dict/words | wc -l )
    local random_number=$( jot -r 1 1 ${number} )

    local word=$( grep "${pattern}" /usr/share/dict/words | tail -n ${random_number} | head -n 1 | tr [:lower:] [:upper:] )
    echo "${word}"
}

function string_to_array () {
    local string="$1"
    local index=0
    while [[ ${index} -lt 5 ]]
    do
        local array[${index}]="${string:${index}:1}"
        index=$(( ${index} + 1 ))
    done
    echo "${array[*]}"
}

function words_validation () {
    local words="$1"

    [[ ${#words} != 5 ]] && { echo "Please Enter a Word with 5 letters!" ; return 3 ; }

    grep "${words}" /usr/share/dict/words &> /dev/null
    [[ $? != 0 ]] && { echo "Please Enter a Valid Word!" ; return 3 ; }
}

function filter_word () {
    local word="$1"
    word=$( echo ${word} | tr [:lower:] [:upper:] )
    word=( $( string_to_array "${word}" ) )
    echo "${word[*]}"
}

function create_tag () {
    local tag="$1"
    local class="$2"
    local content="$3"

    echo "<${tag} class=\"${class}\">${content}</${tag}>"
}

function generate_tag () {
    local actual=( $1 )
    local guessed=( $2 )
    local index="$3"

    if [[ "${guessed[${index}]}" == "${actual[${index}]}" ]]
    then
        create_tag "span" "right-spot" "${guessed[${index}]}"
    elif [[ "${guessed[${index}]}" == "${actual[0]}" ]] || [[ "${guessed[${index}]}" == "${actual[1]}" ]] || [[ "${guessed[${index}]}" == "${actual[2]}" ]] || [[ "${guessed[${index}]}" == "${actual[3]}" ]] || [[ "${guessed[${index}]}" == "${actual[4]}" ]] #
    then
        create_tag "span" "wrong-spot" "${guessed[${index}]}"
    else
        create_tag "span" "not-valid" "${guessed[${index}]}"
    fi 
}

function word_checking () {
    local actual=( $1 )
    local guessed=( $2 )

    for index in `seq ${#actual[@]}`
    do
        local word[${index}]=$( generate_tag "${actual[*]}" "${guessed[*]}" "$(( ${index} - 1 ))" )
    done
    echo "${word[*]}"
    
}

function create_html () {
    local actual=( $1 )
    local guessed=( $2 )
    local guess_count="$3"
    local template="$4"
    local output_file="html/guess_${guess_count}.html"

    cp ${template} ${output_file}
    word[${guess_count}]=$( word_checking "${actual[*]}" "${guessed[*]}" )

    for i in `seq ${guess_count}`
    do
        sed -i '' "s;word_$i.*word_$i;${word[$i]};g" ${output_file} #
    done

    if [[ "${guessed[@]}" == "${actual[@]}" ]]
    then
        echo "Congrats, You Guessed Right!"
        sleep 2
        open ${output_file}
        break
    fi
    sleep 2

    open ${output_file}
}