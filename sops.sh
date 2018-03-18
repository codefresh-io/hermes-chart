#!/bin/bash

# read input parameters
while [ $# -gt 0 ]
do
  case "$1" in
    -d) ACTION=DECRYPT; shift;;
    -e) ACTION=ENCRYPT; shift;;
    -h)
        echo >&2 "usage: $0 -(e|d) [encrypt|decrypt '*-enc.yaml' values files]"
        exit 1;;
     *) break;; # terminate while loop
  esac
done

DIR=${1:-$(dirname $0)}

DATE_SUFFIX=$(date +%y-%m-%d_%H%M%S)

# encrypt files
if [[ $ACTION == "ENCRYPT" ]]; then
  echo "Executing sops $ACTION on all *-dec.yaml files in directory $DIR "
  for f in $(find ${DIR} -name "*-dec.yaml"); do

    BACKUP_DIR=$(dirname ${f})/bak
    mkdir -p ${BACKUP_DIR}
    ENCRYPTED_FILE=${f/-dec.yaml/-enc.yaml}
    BAK_FILE=${BACKUP_DIR}/$(basename ${ENCRYPTED_FILE})-${DATE_SUFFIX}
    if [[ -f ${ENCRYPTED_FILE} ]]; then
      echo "Backing up ${ENCRYPTED_FILE} to ${BAK_FILE} "
      cp -v ${ENCRYPTED_FILE} ${BAK_FILE}
    fi
    echo "Encrypting $f ..."
    sops -e $f > ${ENCRYPTED_FILE}
  done
fi

# descrypt files
if [[ $ACTION == "DECRYPT" ]]; then
  echo "Executing sops $ACTION on all *-enc.yaml files in directory $DIR "
  for f in $(find ${DIR} -name "*-enc.yaml"); do

    BACKUP_DIR=$(dirname ${f})/bak
    mkdir -p ${BACKUP_DIR}
    DECRYPTED_FILE=${f/-enc.yaml/-dec.yaml}
    BAK_FILE=${BACKUP_DIR}/$(basename ${DECRYPTED_FILE})-${DATE_SUFFIX}
    if [[ -f ${DECRYPTED_FILE} ]]; then
      echo "Backing up ${DECRYPTED_FILE} to ${BAK_FILE} "
      cp -v ${DECRYPTED_FILE} ${BAK_FILE}
    fi

    echo "Decrypting $f file"
    sops -d $f > ${DECRYPTED_FILE}
  done
fi
