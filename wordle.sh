#! /bin/bash

source library.sh

MAX_GUESS=6
GUESS_COUNT=1
PATTERN="^.....$"

TEMPLATE_FILE="template.html"
DSTN_DIR="html"
rm -rf ${DSTN_DIR}
mkdir -p ${DSTN_DIR}
cp -r css ${DSTN_DIR}

ACTUAL_WORD=$( generate_word "${PATTERN}" )
actual_word=( $( string_to_array "${ACTUAL_WORD}" ) )

while [[ ${GUESS_COUNT} -le ${MAX_GUESS} ]]
do
    read -p "Enter your guess (${GUESS_COUNT}/${MAX_GUESS}): " guess
    words_validation "${guess}"
    result=$?
    # echo ${result}
    if [[ ${result} == 3 ]]
    then
        continue
    fi
    guessed_word=( $( filter_word "${guess}" ) )
    create_html "${actual_word[*]}" "${guessed_word[*]}" "${GUESS_COUNT}" "${TEMPLATE_FILE}"
    GUESS_COUNT=$(( ${GUESS_COUNT} + 1 ))
done

echo "The Word is ${ACTUAL_WORD}"