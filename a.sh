#! /bin/bash
#sources -----------------------------------------------------
#ascii borders: https://www.asciiart.eu/art-and-design/borders
#colour codes and examples: https://stackoverflow.com/questions/10466749/bash-colored-output-with-a-variable
#formatting variables ----------------------------------------
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
#state variables ---------------------------------------------
QUIT=0
XY=(2 1)
#0HP,1ATK,2DEF,3LEFT,4RIGHT
STATS=( 100 10 10 1 1 )
#room content ------------------------------------------------
#declare -A ROOM
ROOM_0=("Everything is on fire." "There is a house to the west.")
ROOM_1=("A white house stands before you." "The front door is slightly ajar.")
ROOMS=(ROOM_0[@] ROOM_1[@])
#functions ---------------------------------------------------
#decides on what function to call based on user input
function coord(){
    echo "You are at (x,y)=(${XY[0]},${XY[1]})"
}

function echoStats(){
    echo -------------${name}\'s STATS-------------
    echo -e "HP:........${STATS[0]}\nATK:.......${STATS[1]}\nDEF:.......${STATS[2]}\n"
    echo -e "LEFT HAND:........${STATS[3]}\nRIGHT HAND:.......${STATS[4]}"
}

function actionHandler(){
    case $1 in
    stats)
        echoStats
        ;;
    look)
        echo ${!ROOMS[1]:1:1}
        ;;
    move)
        echo Where do you want to move?
        ;;
    help)
        echo HELP TO BE IMPLEMENTED LOL
        ;;
    quit)
        echo "Are you sure you want to quit the game and lose your progress?"
        read x
        if [[ "$x" = "y" || "$x" = "yes" ]]; then
            let QUIT=1
        fi;
        ;;
    *)
        echo -e "I didn\'t understand that... do you need some ${GREEN}help${ERASE}?"
        ;;
esac
}
#content ---------------------------------------------------------------
echo -e " __| |____________________________________________| |__"
echo -e "(__   ____________________________________________   __)"
echo -e "   | |                                            | |  \n"
echo -e "          What shall we call you, adventurer?\n"
read -p "          Name: " name
name=$(echo ${name^})
echo -e "\n          Let us begin, ${GREEN}${name}!${ERASE}\n"
echo -e " __| |____________________________________________| |__"
echo -e "(__   ____________________________________________   __)"
echo -e "   | |                                            | |  \n"


until [ $QUIT -gt 0 ]; do
echo -e "\n--------------------------------------------------------"
#put initial text to player here
coord
echo -e "--------------------------------------------------------\n"
read action 
actionHandler $(echo $action | tr '[A-Z]' '[a-z]')

done
echo -e ${ERASE}Until next time, ${name}!