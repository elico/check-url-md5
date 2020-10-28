#!/usr/bin/env bash

# created by Eliezer Croitoru at 20201028 20:06.
# 
# NgTech LTD, 3-Clause BSD License

EXIT_CODE="0"
OUTPUT="OK"

# 2 MB
SIZE_LIMIT="2000000"

URL="$1"
EXPECTED_ETAG="$2"

if [[ -z "${URL}" ]];then
  echo "Missing URL"
  exit 1
fi

if [[ -z "${EXPECTED_ETAG}" ]];then
  echo "Missing EXPECTED File ETAG"
  exit 1
fi

FILE_HEADERS=$(curl --silent --max-filesize "${SIZE_LIMIT}" -I --header "If-None-Match: \"${EXPECTED_ETAG}\"" "${URL}")
RES=$?

URL_ETAG=$( echo "${FILE_HEADERS}" |grep -m1 -i "etag" |awk '{print $2}' )

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
  echo "${FILE_HEADERS}"|grep -i "Not Modified" >/dev/null
  RES="$?"

  if [ "${RES}" -eq "0" ]; then
    OUTPUT="OK File ETAG => \"${EXPECTED_ETAG}\""
  else
    OUTPUT="WARNING - File was changed -  CURRENT => ${URL_ETAG%%[[:cntrl:]]} , Expected => \"${EXPECTED_ETAG}\""
    EXIT_CODE="1"
  fi
fi
echo "${OUTPUT}"
exit ${EXIT_CODE}
