#! /bin/bash

#formatting variables ----------------------------------------
# colours https://stackoverflow.com/questions/10466749/bash-colored-output-with-a-variable
ERASE='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LGREY='\033[00;37m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'
#functions ---------------------------------------------------

function actionHandler(){
    case $1 in
    look)
        echo look
        ;;
    move)
        echo move
        ;;
    *)
        echo HINT
        ;;
esac
}

#content -----------------------------------------------------

echo You are in a room.

read action

actionHandler $action
