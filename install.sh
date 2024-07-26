#!/bin/bash
# Default variables
function="install"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -f|--fix)
            function="fix"
            shift
            ;;
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
        *|--)
    break
	;;
	esac
done
install() {
#docker install
cd $HOME
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/VS/main/docker.sh)
#websocat
wget https://github.com/vi/websocat/releases/latest/download/websocat.x86_64-unknown-linux-musl -O websocat
chmod +x websocat
sudo mv websocat /usr/local/bin/
websocat --version
#create dir and config
if [ ! -d $HOME/analog ]; then
mkdir $HOME/analog
fi
sleep 1
read -p "Enter node NAME: " NAME
echo 'export NAME='${NAME}
# Create script 
tee $HOME/analog/docker-compose.yml > /dev/null <<EOF
version: "3.7"
name: analog

services:
  node:
    image: analoglabs/timenode-test:latest
    restart: always
    command: |
      --base-path /.analog
      --unsafe-rpc-external
      --rpc-methods=Unsafe
      --name $NAME
      --telemetry-url='wss://telemetry.analog.one/submit 9'
    ports:
    - '9944:9944'
    - '30303:30333'
    volumes:
    - ${HOME}/analog:/.analog

volumes:
  analog:

EOF
sleep 2
#docker run
docker compose -f $HOME/analog/docker-compose.yml up -d
docker logs -f analog-node-1
}
fix() {

}

uninstall() {
if [ ! -d "$HOME/analog" ]; then
    break
fi
read -r -p "Wipe all DATA? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
docker compose -f $HOME/analog/docker-compose.yml down -v
rm -rf $HOME/analog
        ;;
    *)
	echo Canceled
	break
        ;;
esac
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function