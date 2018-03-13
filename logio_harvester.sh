#!/usr/bin/env bash

# Description: harvester.conf file generator for Log.io server

export LC_ALL=en_US.utf8

NODE_NAME="dev.cleveroad.com"
PROJECT_DIR="/home/deploy/projects/dev"
LOGIO_DIR="/home/deploy/.log.io"
HARV_TMP="${LOGIO_DIR}/harvester.conf.tmp"
HARV_PORT=1211
PROJECT_LIST=( $(ls ${PROJECT_DIR}) )

NODE_PROJECTS=("ayio" "ayoo" "cleveroad" "friendhub" "matchplayer" \
    "osmo" "pqcode" "shirtapp" "startech" "trainaway" "yeo" "openmind" "metknow" \
)

clean_logs() {
for x in ${NODE_PROJECTS[@]}; do
    for y in ${PROJECT_LIST[@]}; do
        if [ -d "${PROJECT_DIR}/${y}" ] && [[ "${y}" =~ "${x}" ]]; then
            if [ -d "${PROJECT_DIR}/${y}/logs" ]; then

                cd "${PROJECT_DIR}/${y}/logs"
                ALL_LOGS=( $(ls *.log) )
                LOG_MAX_NUM=$(ls | egrep -o '[0-9]*'|sort -n|tail -n 1)

                if ! [ -z ${ALL_LOGS} ]; then
                    for i in ${ALL_LOGS[@]}; do
                        if ! ([[ "$i" =~ "${LOG_MAX_NUM}" ]] || [[ "$i" =~ $[${LOG_MAX_NUM}-1] ]]); then
                            rm -f ${i}
                        fi
                    done
                fi
            fi
            ALL_LOGS=()
            LOG_MAX_NUM=
        fi
    done
done
}

clear_prevtmp() {
if [ -f ${HARV_TMP} ]; then
    rm -f ${HARV_TMP} && echo "Delete old ${HARV_TMP}."
fi
}

generate_header() {
cat > ${HARV_TMP} << HOF
exports.config = {
  nodeName: "${NODE_NAME}",
  logStreams: {
HOF
}

generate_footer() {
cat >> ${HARV_TMP} << FOF
  },
  server: {
    host: '127.0.0.1',
    port: ${HARV_PORT}
  }
}
FOF
}

clean_logs
clear_prevtmp
generate_header

for x in ${NODE_PROJECTS[@]}; do
    for y in ${PROJECT_LIST[@]}; do
        if [ -d "${PROJECT_DIR}/${y}" ] && [[ "${y}" =~ "${x}" ]]; then
            if [ -d "${PROJECT_DIR}/${y}/logs" ]; then
                LOG_PATH="/logs"
            else
                LOG_PATH=""
            fi

            echo "    ${x}: [" >> ${HARV_TMP}
            COMMA=","
            TMP_ARR=( $(ls ${PROJECT_DIR}/${y}${LOG_PATH}/*.log) )
            for i in ${TMP_ARR[@]}; do
                if [ ${TMP_ARR[-1]} == ${i} ]; then
                    COMMA=""
                fi
                echo -e "      ${PROJECT_DIR}${LOG_PATH}/${i}${COMMA}" >> ${HARV_TMP}
            done
            [ ${NODE_PROJECTS[-1]} == ${x} ] \
            && echo -e "    ]" >> ${HARV_TMP} || echo -e "    ]," >> ${HARV_TMP}
        fi
    done
done

generate_footer

echo "New ${HARV_TMP} generated on $(date +%d.%m.%Y-%H:%M)"
