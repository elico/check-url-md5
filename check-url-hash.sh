#!/usr/bin/env bash

# created by Eliezer Croitoru at 20201028 20:06.
# 
# NgTech LTD, 3-Clause BSD License

EXIT_CODE="0"
OUTPUT="OK"

# 2 MB
SIZE_LIMIT="2000000"

URL="$1"
EXPECTED_HASH="$2"

HASH="$3"
HASH_BINARY="md5sum"


if [[ -z "${URL}" ]];then
  echo "Missing URL"
  exit 1
fi

if [[ -z "${EXPECTED_HASH}" ]];then
  echo "Missing EXPECTED File HASH"
  exit 1
fi

case "${HASH}" in
  md5|md5sum|MD5)
    HASH_BINARY="md5sum"
  ;;
  sha1|sha1sum|SHA1)
    HASH_BINARY="sha1sum"
  ;;
  sha256|sha256sum|SHA256)
    HASH_BINARY="sha256sum"
  ;;
  sha512|sha512sum|SHA512)
    HASH_BINARY="sha512sum"
  ;;
  sha384|sha384sum|SHA384)
    HASH_BINARY="sha384sum"
  ;;
  sha224|sha224sum|SHA224)
    HASH_BINARY="sha224sum"
  ;;
  *)
    HASH_BINARY="md5sum"
  ;;
esac

FILE=$(curl --silent --max-filesize "${SIZE_LIMIT}" "${URL}")
RES=$?

if [ "${RES}" -eq "0" ];then
  OUTPUT="OK"
  # OK
else
  echo $RES
  case ${RES} in
    63)
      OUTPUT="WARNING The file is too big"
      EXIT_CODE="1"
    ;;
    *)
      OUTPUT="WARNING curl exit code: ${RES}"
      EXIT_CODE="2"
    ;;
  esac
fi

if [ "${RES}" -eq "0" ];then
  FILE_HASH=$( ${HASH_BINARY} <<< "${FILE}" |awk '{print $1}')

  if [ "${EXPECTED_HASH}" == "${FILE_HASH}" ]; then
    OUTPUT="OK - ${FILE_HASH} == ${EXPECTED_HASH}"
  else
    if [ "${#EXPECTED_HASH}" -eq "${#FILE_HASH}" ];then
      OUTPUT="WARNING - ${FILE_HASH} != ${EXPECTED_HASH}"
    else
      OUTPUT="WARNING - Different HASH length - ${FILE_HASH} != ${EXPECTED_HASH}"
    fi

    EXIT_CODE="1"
  fi
fi
echo "${OUTPUT}"
exit ${EXIT_CODE}
