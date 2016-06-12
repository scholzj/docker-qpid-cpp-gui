#!/bin/bash
set -e

# if command starts with an option, prepend qpidd
if [ "${1:0:1}" = '-' ]; then
    set -- ./QpidRestAPI.sh "$@"
fi

if [ "$1" = "./QpidRestAPI.sh" ]; then
    chown -R qpidd-gui /home/qpidd-gui/qpid-qmf2-tools
    if [[ "$QMF_GUI_ADMIN_USERNAME" && "$QMF_GUI_ADMIN_PASSWORD" ]]; then
        echo "$QMF_GUI_ADMIN_USERNAME:$QMF_GUI_ADMIN_PASSWORD" >> qpid-web/authentication/account.properties
    fi
fi

# else default to run whatever the user wanted like "bash"
exec "$@"
