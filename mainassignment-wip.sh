#! /bin/bash
#sources -----------------------------------------------------
#ascii borders: https://www.asciiart.eu/art-and-design/borders
#colour codes and examples: https://stackoverflow.com/questions/10466749/bash-colored-output-with-a-variable
#formatting variables ----------------------------------------
ERASE='\033[0m'
NPC='\033[00;31m' #RED
YOU='\033[00;32m' #GREEN
INT='\033[00;33m' #YELLOW
BLUE='\033[00;34m'
EQUIP='\033[00;35m' #PURPLE
CLI='\033[00;36m' #CYAN
LGREY='\033[00;37m'
ROOM='\033[01;31m' #LRED
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'
#state variables ---------------------------------------------
QUIT=0                  #breaks the main loop if >0
currentRoom=ROOM_ORIGIN   #origin is (0,0) unless operator inputs differently(TODO). Bash allows us to do wierd things like use a string as part of a variable(array) name so we can change rooms easily.
echo $currentRoom
declare -A STATS
STATS[HP]=100
STATS[ATK]=10
STATS[DEF]=10
STATS[LEFT]=Nothing
STATS[RIGHT]=Nothing
#"CONSTRUCTORS" for room "OBJECTS" ------------------------------------------------
#A room "object" consists of an associative array with the syntax ROOM_ROOMNAME[memberVariableOrFunctionName]. Each array ROOM_ROOMNAME is an element in an (n<=4)ly linked-list type thing 
#where ROOM_ROOMNAME[directionN|S|E|W] is a function that changes the room we are in. i.e. changes currentRoom.
#memberVariableOrFunctionName should be recognised after user input is sanitised by removing whitespace and lowercase-ing it. i.e. "Search drawer" calls the function ROOM_ROOMNAME[searchdrawer].
#Use member variables as state for the rooms.
#Directional movement is caught in a switch-case before looking up member things in the associative arrays. The current supported ones are north, south, east and west.
#User input, after sanitation will switch-case and decide if the command is a direction [NSEW] || [anything else]. If it is not a direction it will call the function with the name of the user input.
#Then the script will echo the value pointed to by ROOM_ROOMNAME[userInputSanitised].
#If the user decides a direction, the function updateRoom(direction) will be called which changes the current room based on the value pointed to by ROOM_ROOMNAME[direction]. The room to be changed to can be the current room.
#Then an echo will be called on the value pointed to by ROOM_ROOMNAME[directionT] 


#EVERY ROOM MUST IMPLEMENT ARRAY KV PAIRS:
#location
#look
#north
#south
#east
#west

declare -A ROOM_ORIGIN
ROOM_ORIGIN[location]="Fiery Room"
ROOM_ORIGIN[look]="${INT}Everything${ERASE} is on fire! There is a ${INT}fire extinguisher${ERASE} on the western wall of the room. You see a dimly lit ${INT}exit sign${ERASE} to the ${ROOM}north${ERASE}."
ROOM_ORIGIN[north]=ROOM_CORR1
ROOM_ORIGIN[northT]="You run out of the room ${YOU}burning${ERASE} and screaming."
ROOM_ORIGIN[southT]="You look to the south and you are blinded by the flames."
ROOM_ORIGIN[eastT]="The eastern side of the room has collapsed."
ROOM_ORIGIN[westT]="The western wall is on fire."

ROOM_ORIGIN[everything]=0
function everything(){
    echo -e "It's all burning. ${YOU}You're${ERASE} burning."
}
ROOM_ORIGIN[fireextinguisher]=0
function fireextinguisher(){
    damage=60
    echo -e "It's also on fire. You try to grab it and you take ${NPC}${damage}${ERASE} damage."
    let damage=$damage*-1
    adjustHealth $damage
}
ROOM_ORIGIN[exitsign]=0
function exitsign(){
    damage=240
    echo -e "The flames have melted the casing on the tritium sign and you see exposed wires. The sign shorts out and electrocutes you. You take ${NPC}${damage}${ERASE} damage."
    let damage=$damage*-1
    adjustHealth $damage
}

declare -A ROOM_CORR1
ROOM_CORR1[location]="Dark Corridor"
ROOM_CORR1[look]="The orange glow of the flames paints a sillouhette on the dark corridor ahead. There is a ${EQUIP}crowbar${ERASE} on the floor next to you. You step over the burnt husk of a banana-coloured ${INT}doorframe${ERASE}."
ROOM_CORR1[northT]="You carfully step into the darkness. It is dark."
ROOM_CORR1[north]=ROOM_0_2
ROOM_CORR1[southT]="The heat singes your skin. It is unwise to go back."
ROOM_CORR1[southF]=1
function ROOM_CORR1_southF(){
    if [ ${ROOM_CORR1[southF]} -gt 0 ]; then
        let ROOM_CORR1[southF]=${ROOM_CORR1[southF]}-1
        damage=20
        echo -e "\n\n\n...\n\n\nThe room explodes in an angry orange fireball. You take ${NPC}20${ERASE} damage."
        let damage=$damage*-1
        adjustHealth damage
    fi;
}
ROOM_CORR1[south]=ROOM_CORR1
ROOM_CORR1[eastT]="A solid wall blocks your path to the east. A smouldering poster is barely legible. .  .  . \"F-O- FRAC-IO-S\""
ROOM_CORR1[westT]="A shattered window spews glass on the floor to the west. The darkness consumes the space on the other side."
ROOM_CORR1[west]=ROOM_WINDOWDARK
ROOM_CORR1[crowbar]=1
function crowbar(){
    if [ $ROOM_CORR1[crowbar] > 0 ]; then
        if [ $STATS[LEFT] = "Nothing" ]; then
            echo -e "You pick up the ${EQUIP}crowbar${ERASE}."
            let STATS[ATK]=$STATS[ATK]+20
            let STATS[LEFT] = "Crowbar"
            let ROOM_CORR1[crowbar]=$ROOM_CORR1[crowbar]-1
        elif [ $STATS[RIGHT] = "Nothing" ]; then
            echo -e "You pick up the ${INT}crowbar${ERASE}."
            let STATS[ATK]=$STATS[ATK]+20
            let STATS[RIGHT] = "Crowbar"
            let ROOM_CORR1[crowbar]=$ROOM_CORR1[crowbar]-1
        else
            echo "Your hands are full."
        fi;
    else
        echo "You have already picked up the ${INT}crowbar${ERASE}."
    fi;
}

declare -A ROOM_WINDOWDARK
ROOM_WINDOWDARK[location]="Dark window abyss..."
ROOM_WINDOWDARK[look]="You can barely see."
#ROOM_-1_1
#ROOM_-1_1
#ROOM_-1_1
#ROOM_-1_1


#functions ---------------------------------------------------
#check for death and deal damage/heal
function adjustHealth(){
    let STATS[HP]=${STATS[HP]}+$1
    if [ ${STATS[HP]} -le 0 ]; then
        let QUIT=1;
        echo -e "${NPC}YOU DIED${ERASE}"
    fi;
}
#orient the player every time they change rooms
function updateRoom(){
    echo -e "\n--------------------------------------------------------"
    actionHandler location
    echo -e "--------------------------------------------------------\n"
}
#checks if it should perform a function on the room change, print some text and then change the room
function room(){
        out="${currentRoom}[${1}T]"
        echo -e ${!out}
        temp="${currentRoom}[${1}F]"
        #if the value at ROOM_CORR1[southF] is not empty
        if [ ! -z "${!temp}" ]; then
            #find the function called e.g ROOM_CORR1_southF
            ${currentRoom}_${1}F
        fi;
        out="${currentRoom}[${1}]"
        if [ ! -z "${!out}" ]; then
            currentRoom="${!out}"
            #echo $currentRoom
            updateRoom
        fi;
}
function echoStats(){
    echo -e "-------------${YOU}${name}${ERASE}'s STATS-------------"
    echo -e "HP:...............${STATS[HP]}\nATK:..............${STATS[ATK]}\nDEF:..............${STATS[DEF]}\n"
    echo -e "LEFT HAND:........${STATS[LEFT]}\nRIGHT HAND:.......${STATS[RIGHT]}"
}

#inherited member methods in every room:
function iLook(){
    #usage: ROOMS[room number]:room_member_index
    out=$currentRoom[look]
    echo -e ${!out}
}

function iLocation(){
    out=$currentRoom[location]
    echo -e "Location: ${!out}"
}


#catch the following args:
#look
#location
#north
#south
#east
#west
#stats
#move
#help
#quit
#
#If not caught, check for an entry in the room array element thing. If no entry, error msg. If there is an entry, call the function $1. ENSURE A NON_INHERITED ENTRY HAS A CORRESPONDING FUNCTION
function actionHandler(){
    case $1 in
    look)
        iLook
        ;;
    location)
        iLocation
        ;;
    north)
        #+y
        room north
        ;;
    south)
        #-y
        room south
        ;;
    east)
        #+x
        room east
        ;;
    west)
        #-x
        room west
        ;;
    stats)
        echoStats
        ;;
    move)
        echo Where do you want to move?
        ;;
    help)
        echo -e "\nColours:\n"
        echo -e "${INT}Yellow${ERASE} objects can be interacted with."
        echo -e "${EQUIP}Purple${ERASE} objects are gear you can equip in your left or right hand."
        echo -e "${YOU}Green${ERASE} text refers to your character attributes."
        echo -e "${NPC}Red${ERASE} text refers to enemy attributes."
        echo -e "${ROOM}Pink${ERASE} text refers to places you may be able to travel to."
        echo -e "${CLI}Blue${ERASE} text refers other commands you can use."
        echo -e "\nCommon commands:\n\nlocation ....... Displays the name of the room you are in."
        echo -e "look ........... Describes your location and points out any interactable ${INT}objects${ERASE}."
        echo -e "stats .......... Displays your characters stats and items you are carrying."
        echo -e "quit ........... Quit the game."
        ;;
    quit)
        echo "Are you sure you want to quit the game and lose your progress?"
        read x
        if [[ "$x" = "y" || "$x" = "yes" ]]; then
            let QUIT=1
            echo -e "${ERASE}Until next time, ${YOU}${name}${ERASE}."
        else
            echo "Type 'y' or 'yes' to confirm that you want to quit. Returning to game..."
        fi;
        ;;
    *)
        #try to use the command as the room's array index here
        out=$currentRoom[$1]
        #echo "${!out}"
        #if the ROOM_X_Y[command] value returns empty, i.e. the key/value pair does not exist in the room declaration.
        if [ -z "${!out}" ]; then
            echo -e "I didn't understand that... do you need some ${CLI}help${ERASE}?"
        else
            #call the function with the name $in i.e. the command name
            $1
        fi;
        ;;
esac
}
#content ---------------------------------------------------------------
echo -e " __| |____________________________________________| |__"
echo -e "(__   ____________________________________________   __)"
echo -e "   | |                                            | |  \n"
echo -e "          What shall we call you?\n"
read -p "          Name: " name
name=$(echo ${name^})
echo -e "\n          Let us begin, ${YOU}${name}${ERASE}.\n"
echo -e " __| |____________________________________________| |__"
echo -e "(__   ____________________________________________   __)"
echo -e "   | |                                            | |  \n"

#put initial text to player here
echo -e "\n--------------------------------------------------------"
actionHandler location
echo -e "--------------------------------------------------------\n"
actionHandler look

until [ $QUIT -gt 0 ]; do

read action 
cleaning=${action// } #replace space with nothing
sanitised=$(echo $cleaning | tr '[A-Z]' '[a-z]') #lowercase everything and use as arg
actionHandler $sanitised

done