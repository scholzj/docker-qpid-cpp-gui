#!/usr/bin/env bats

IMAGE="scholzj/qpid-cpp-gui"
VERSION="travis"

USERNAME="admin"
PASSWORD="123456"

QPIDD_IMAGE="scholzj/qpid-cpp"
QPIDD_VERSION="latest"

teardown() {
    echo $(docker logs $cont)
    echo $(docker logs $cont_qpidd)
 
    sudo docker stop $cont
    sudo docker rm $cont
    sudo docker stop $cont_qpidd
    sudo docker rm $cont_qpidd
}

tcpPort() {
    sudo docker port $cont_qpidd 5672 | cut -f 2 -d ":"
}

httpPort() {
    sudo docker port $cont 8080 | cut -f 2 -d ":"
}

@test "No options, correct credentials" {
    cont_qpidd=$(sudo docker run -P -d $QPIDD_IMAGE:$QPIDD_VERSION)
    port_qpidd=$(tcpPort)
    cont=$(sudo docker run -P -e QMF_GUI_ADMIN_USERNAME=$USERNAME -e QMF_GUI_ADMIN_PASSWORD=$PASSWORD -d $IMAGE:$VERSION)
    port=$(httpPort)
 
    sleep 10 # give the image time to start

    run curl -s http://$USERNAME:$PASSWORD@localhost:$port/qpid/connection/
    echo $output
    [ "$status" -eq "0" ]
    [ "$output" = "{}" ]
}

@test "Broker link, correct credentials" {
    cont_qpidd=$(sudo docker run --name=broker -d $QPIDD_IMAGE:$QPIDD_VERSION)
    port_qpidd=$(tcpPort)
    cont=$(sudo docker run -P -e QMF_GUI_ADMIN_USERNAME=$USERNAME -e QMF_GUI_ADMIN_PASSWORD=$PASSWORD --link=broker:broker -d $IMAGE:$VERSION -a broker:5672)
    port=$(httpPort)

    sleep 5 # give the image time to start

    run curl -s http://$USERNAME:$PASSWORD@localhost:$port/qpid/connection/default
    echo $output
    [ "$status" -eq "0" ]
    [ "$output" = "{\"url\":\"broker:5672\",\"connectionOptions\":{}}" ]
}

@test "Broker link, incorrect credentials" {
    cont_qpidd=$(sudo docker run --name=broker -d $QPIDD_IMAGE:$QPIDD_VERSION)
    port_qpidd=$(tcpPort)
    cont=$(sudo docker run -P -e QMF_GUI_ADMIN_USERNAME=$USERNAME -e QMF_GUI_ADMIN_PASSWORD=$PASSWORD --link=broker:broker -d $IMAGE:$VERSION -a broker:5672)
    port=$(httpPort)

    sleep 5 # give the image time to start

    run curl -s http://$USERNAME:wrongpassword@localhost:$port/qpid/connection/default
    echo $output
    [ "$status" -eq "0" ]
    [ "$output" = "" ]
}
