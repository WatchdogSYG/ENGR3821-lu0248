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
QUIT=0                  #breaks the main loop if >0
XY=(0 0)                #current coordinates in cardinal directional plane
currentRoom=ROOM_0_0    #origin is (0,0) unless operator inputs differently(TODO). The 
#0HP,1ATK,2DEF,3LEFT,4RIGHT
declare -A STATS
STATS[HP]=100
STATS[ATK]=10
STATS[DEF]=10
STATS[LEFT]=Nothing
STATS[RIGHT]=Nothing
#room content ------------------------------------------------
#room data structure is doubly linked list-like with pointers to the "next" element/room being the directional key/value pairs.
declare -A ROOM_0_0
ROOM_0_0[location]="Fiery Room"
ROOM_0_0[look]="${YELLOW}Everything${ERASE} is on fire! There is a ${YELLOW}fire extinguisher${ERASE} on the western wall of the room. You see a dimly lit ${YELLOW}exit sign${ERASE} to the north."
ROOM_0_0[north]=ROOM_0_1
ROOM_0_0[fire_extinguisher]=fe
ROOM_0_0[exit_sign]=ex

declare -A ROOM_0_1
ROOM_0_1[location]="Watery Room"
ROOM_0_1[look]="${YELLOW}Nothing${ERASE} is on fire! There is a ${YELLOW}water extinguisher${ERASE} on the western wall of the room. You see a dimly lit ${YELLOW}exit sign${ERASE} to the north."
ROOM_0_1[south]=ROOM_0_0
ROOM_0_1[east]=east
ROOM_0_1[west]=west

#functions ---------------------------------------------------
function updateRoom(){

}

function echoStats(){
    echo -------------${name}\'s STATS-------------
    echo -e "HP:...............${STATS[HP]}\nATK:..............${STATS[ATK]}\nDEF:..............${STATS[DEF]}\n"
    echo -e "LEFT HAND:........${STATS[LEFT]}\nRIGHT HAND:.......${STATS[RIGHT]}"
}

function actionHandler(){
    case $1 in
    stats)
        echoStats
        ;;
    look)
        #usage: ROOMS[room number]:room_member_index
        out=$currentRoom[look]
        echo -e ${!out}
        ;;
    location)
        out=$currentRoom[location]
        echo -e "    ${!out}"
        ;;
    north)
        #+y
        ;;
    south)
        #-y
        ;;
    east)
        #+x
        ;;
    west)
        #-x
        ;;
    move)
        echo Where do you want to move?
        ;;
    help)
        echo -e "\nColours:\n"
        echo -e "${YELLOW}Yellow${ERASE} objects can be interacted with."
        echo -e "${PURPLE}Purple${ERASE} objects are gear you can equip in your left or right hand."
        echo -e "${GREEN}Green${ERASE} text refers to your character attributes."

        echo -e "\nCommon commands:\n\nlocation ....... Displays the name of the room you are in."
        echo -e "look ........... Describes your location and points out any interactable ${YELLOW}objects${ERASE}."
        echo -e "stats .......... Displays your characters stats and items you are carrying.(NOT IMPLEMENTED YET)"
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
echo -e "\n          Let us begin, ${GREEN}${name}${ERASE}!\n"
echo -e " __| |____________________________________________| |__"
echo -e "(__   ____________________________________________   __)"
echo -e "   | |                                            | |  \n"

echo -e "\n--------------------------------------------------------"
#put initial text to player here
actionHandler location
echo -e "--------------------------------------------------------\n"
actionHandler look

until [ $QUIT -gt 0 ]; do

read action 
actionHandler $(echo $action | tr '[A-Z]' '[a-z]')

done
echo -e ${ERASE}Until next time, ${name}!