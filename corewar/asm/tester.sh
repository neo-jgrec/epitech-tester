#!/usr/bin/bash
##
## neo-diamons, 2023
## corewar/asm
## File description:
## tester
##

ECHO="/usr/bin/echo -e"

function help() {
    $ECHO "Usage: ./tester.sh <asm_binary> <asm_test_binary>"
    $ECHO "-h --help: Display this help"
    $ECHO
    $ECHO "You must have a champions in the ./champions directory"
}

if [ "$#" -eq 0 ]
then
    $ECHO "[\033[0;31mKO\033[0m] Too few arguments."
    exit 0
fi

if [ "$#" -eq 1 ]
then
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]
    then
        help
        exit 0

    else
        $ECHO "[\033[0;31mKO\033[0m] Too few arguments."
        exit 1
    fi
fi

if [ ! -f "$1" ]
then
    $ECHO "[\033[0;31mKO\033[0m] asm binary not found."
    exit 1
fi

if [ ! -f "$2" ]
then
    $ECHO "[\033[0;31mKO\033[0m] asm_test binary not found."
    exit 1
fi

if [ "$#" -gt 2 ]
then
    $ECHO "[\033[0;31mKO\033[0m] Too many arguments."
    exit 1
fi

CHAMPIONS_DIR="$(dirname $(dirname "$0"))/champions/"

if [ ! -d "${CHAMPIONS_DIR}" ]
then
    $ECHO "[\033[0;31mKO\033[0m] Champions directory not found."
    exit 1
fi

if [ 0 -eq "$(ls -1 ${CHAMPIONS_DIR}*.s 2>/dev/null | wc -l)" ]
then
    $ECHO "[\033[0;31mKO\033[0m] Champions directory not contains any champions."
    exit 1
fi

ASM_BIN="$1"
ASM_TEST_BIN="$2"
TOTAL_OK=0
TOTAL_TEST=0
TMP_DIR=$(mktemp -d)

for file in ${CHAMPIONS_DIR}*.s
do
    ((TOTAL_TEST++))
    FILENAME=$(basename ${file%.*})

    ${ASM_TEST_BIN} $file
    if [ $? -ne 0 ]
    then
        ${ECHO} "[\033[0;34mTest\033[0m][\033[0;31mINVALID\033[0m] $file"
        rm -f $file
        continuew
    fi
    mv ${FILENAME}.cor ${TMP_DIR}/${FILENAME}.cor.ref

    ${ASM_BIN} $file
    if [ $? -ne 0 ]
    then
        ${ECHO} "[\033[0;34mTest\033[0m][\033[0;31mKO\033[0m] $file"
        rm -f ${TMP_DIR}/${FILENAME}.cor ${TMP_DIR}/${FILENAME}.cor.ref
        continue
    fi
    mv ${FILENAME}.cor ${TMP_DIR}/${FILENAME}.cor

    hexdump -C ${TMP_DIR}/${FILENAME}.cor > ${TMP_DIR}/${FILENAME}.hex
    hexdump -C ${TMP_DIR}/${FILENAME}.cor.ref > ${TMP_DIR}/${FILENAME}.hex.ref

    FILEDIFF=$(diff -q ${TMP_DIR}/${FILENAME}.hex ${TMP_DIR}/${FILENAME}.hex.ref)
    if [ $? -ne 0 ]
    then
        ${ECHO} "[\033[0;34mTest\033[0m][\033[0;31mKO\033[0m] $file"
        ${ECHO} "$FILEDIFF\n"

    else
        ${ECHO} "[\033[0;34mTest\033[0m][\033[0;32mOK\033[0m] $file"
        ((TOTAL_OK++))
    fi

    rm ${TMP_DIR}/${FILENAME}.cor ${TMP_DIR}/${FILENAME}.cor.ref
    rm ${TMP_DIR}/${FILENAME}.hex ${TMP_DIR}/${FILENAME}.hex.ref
done

${ECHO} "[\033[0;33mTOTAL\033[0m] $TOTAL_OK/$TOTAL_TEST"

if [ $TOTAL_OK -eq $TOTAL_TEST ]
then
    rm -rf ${TMP_DIR}
    exit 0
else
    exit 1
fi
