#! /bin/bash
#Author: <REDACTED FOR MARKING PURPOSES> 
#REVISION 0 - 19-06-18 18:36
#sources ---------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------#
#ascii borders: https://www.asciiart.eu/art-and-design/borders
#colour codes and examples: https://stackoverflow.com/questions/10466749/bash-colored-output-with-a-variable
#formatting variables --------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------#
ERASE='\033[0m'     #clears formatting
NPC='\033[00;31m'   #RED
YOU='\033[00;32m'   #GREEN
INT='\033[00;33m'   #YELLOW
EQUIP='\033[00;35m' #PURPLE
CLI='\033[00;36m'   #CYAN
ROOM='\033[01;31m'  #LRED

#unused colours
BLUE='\033[00;34m'
LGREY='\033[00;37m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'
#other state variables -------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------#
QUIT=0                      #breaks the main loop if >0
currentRoom=ROOM_ORIGIN     #origin is (0,0) unless operator inputs differently(TODO). Bash allows us to do wierd things like use a string as part of a variable(array) name so we can change rooms easily.
echo $currentRoom
declare -A STATS
STATS[HP]=100
STATS[ATK]=10
STATS[DEF]=10
STATS[LEFT]=Nothing
STATS[RIGHT]=Nothing
#TODO: Associative array of items and their stats/effects---------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------#

#"CONSTRUCTORS" for room "OBJECTS" -------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------#
#DOC: Object Oriented Structures
#A room "object" consists of an associative array with the syntax ROOM_ROOMNAME[memberVariableOrFunctionName]. Each array ROOM_ROOMNAME is an element in an (n<=4)ly linked-list type thing 
#where ROOM_ROOMNAME[direction(N|S|E|W)] is a key/value pair that has a "pointer-like thing" to the name of another room. It is up to the designer to keep track of room locations.
#memberVariableOrFunctionName should be recognised after user input is sanitised by removing whitespace and lowercase-ing it. i.e. "Search drawer" calls the function ROOM_ROOMNAME[searchdrawer].
#Use member variables as state for the rooms.
#Directional movement is caught in a switch-case before looking up member things in the associative arrays. The current supported ones are north, south, east and west. Can be extended easily by adding cases.
#User input, after sanitation will switch-case and decide if the command is a direction [NSEW] || [anything else]. If it is not a direction it will call the function with the name of the user input.
#Then the script will echo the value pointed to by ROOM_ROOMNAME[userInputSanitised].
#If the user decides a direction, the function room(arg direction) will be called which changes the current room based on the value pointed to by ROOM_ROOMNAME[direction]. 
#The room to be changed to can be the current room.
#Functionality has been implemented where a function can be called on room change with the name ROOM_CURRENT_directionF. The kv ROOM_CURRENT[directionF] must exist and be non-null as the script checks 
#for that key to handle the terminal throwing a command not found error. The kv can be used to store state if desired. A kv can intentionally not conform to the [a-z] syntax to avoid user interaction.


#EVERY ROOM MUST IMPLEMENT ARRAY KV PAIRS:
#location
#look

#For consistency, implement all text entries for every direction.

#LIMITATION: every non-directional command must have a unique name and therefore a unique user input. This can be avoided by implementing the capability to use an associative array value as a function pointer. However, if the function does not exist, we have to catch the error.

declare -A ROOM_ORIGIN
ROOM_ORIGIN[location]="Fiery Room"
ROOM_ORIGIN[look]="${INT}Everything${ERASE} is on fire! There is a ${INT}fire extinguisher${ERASE} on the western wall of the room. You see a dimly lit ${INT}exit sign${ERASE} to the ${ROOM}north${ERASE}."
ROOM_ORIGIN[north]=ROOM_CORR1
ROOM_ORIGIN[northT]="You run out of the room ${YOU}burning${ERASE} and screaming. The sprinklers help put it out."
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
ROOM_CORR1[location]="Dark Corridor Entrance"
ROOM_CORR1[look]="The orange glow of the flames paints a sillouhette on the dark corridor ahead. There is a ${EQUIP}crowbar${ERASE} on the floor next to you. You step over the burnt husk of a banana-coloured ${INT}doorframe${ERASE}.\nA boarded up ${INT}window${ERASE} hangs somewhat loosely from its nails on the ${ROOM}west${ERASE}ern wall of the hallway."
ROOM_CORR1[northT]="You carfully step into the darkness. The orange glow of the burning room behind you fades away as you venture forth into the dark corridor. It is dark."
ROOM_CORR1[north]=ROOM_CORR1_MID
ROOM_CORR1[southT]="The heat singes your skin. It is unwise to go back."
ROOM_CORR1[southF]=1 #explosions remaining
function ROOM_CORR1_southF(){
    if [ ${ROOM_CORR1[southF]} -gt 0 ]; then
        let ROOM_CORR1[southF]=${ROOM_CORR1[southF]}-1
        damage=20
        echo -e "\n\n...\n\n\nThe room explodes in an angry orange fireball, the flames lapping at the space between.\nYou recoil as glowing wooden shards fly at you. You take ${NPC}20${ERASE} damage."
        let damage=$damage*-1
        adjustHealth damage
    fi;
}
ROOM_CORR1[eastT]="A solid wall blocks your path to the east. A smouldering poster is barely legible. .  .  . \"F-O- FRAC-IO-S\""
#ROOM_CORR1[west]=
ROOM_CORR1[westF]=1 #boards left to pry
#if high enough atk, break the window and change room to ROOM_WINDOWDARK
function ROOM_CORR1_westF(){
    if [ ${STATS[ATK]} -gt 15 ]; then
        echo -e "You pry the boards off the ${INT}window${ERASE} and step into the darkness."
        ROOM_CORR1[west]="ROOM_WINDOWDARK"
        echo -e "A shattered window spews glass and splinters on the floor to the ${ROOM}west${ERASE}. You step in to the darkness which consumes the space on the other side."
    else
        echo -e "A boarded up ${INT}window${ERASE} hangs somewhat loosely from its nails on the ${ROOM}west${ERASE}ern wall of the hallway. You are not strong enough to pry the boards off."
    fi;
}
ROOM_CORR1[crowbar]=1 #number of crowbars for eg.
#to abstract
function crowbar(){
    if [ ${ROOM_CORR1[crowbar]} -gt 0 ]; then
        if [ ${STATS[RIGHT]} == "Nothing" ]; then
            echo -e "You pick up the ${EQUIP}crowbar${ERASE} with your ${YOU}right hand${ERASE}."
            let STATS[ATK]=${STATS[ATK]}+20
            STATS[RIGHT]="Crowbar"
            #echo -e "${STATS[RIGHT]}"
            let ROOM_CORR1[crowbar]=${ROOM_CORR1[crowbar]}-1
        elif [ ${STATS[LEFT]} == "Nothing" ]; then
            echo -e "You pick up the ${EQUIP}crowbar${ERASE} with your ${YOU}left hand${ERASE}."
            let STATS[ATK]=${STATS[ATK]}+20
            STATS[LEFT]="Crowbar"
            #echo -e "${STATS[LEFT]}"
            let ROOM_CORR1[crowbar]=${ROOM_CORR1[crowbar]}-1
        else
            echo "Your hands are full."
        fi;
    else
        echo -e "You have already picked up the ${INT}crowbar${ERASE}."
    fi;
}
ROOM_CORR1[doorframe]=0
function doorframe(){
    echo -e "The ${INT}door${ERASE} is banana coloured with brown and blackened edges. Not unlike a banana."
}
ROOM_CORR1[window]=0
function window(){
    echo -e "A boarded up ${INT}window${ERASE} hangs somewhat loosely from its nails on the ${ROOM}west${ERASE}ern wall of the hallway."
}

declare -A ROOM_WINDOWDARK
ROOM_WINDOWDARK[location]="Dark window abyss..."
ROOM_WINDOWDARK[look]="You can barely see."
ROOM_WINDOWDARK[eastT]="You climb back through the window into the dark corridor."
ROOM_WINDOWDARK[east]=ROOM_CORR1
ROOM_WINDOWDARK[westT]="There is nothing there."
ROOM_WINDOWDARK[northT]="There is nothing there."
ROOM_WINDOWDARK[southT]="There is nothing there."


declare -A ROOM_CORR1_MID
ROOM_CORR1_MID[location]="Dark Corridor 1"
ROOM_CORR1_MID[look]="You see a faint glow of another exit sign to the ${ROOM}north${ERASE}."
ROOM_CORR1_MID[north]="ROOM_ROOF_AC"
ROOM_CORR1_MID[northT]="Tripping over a fallen vending machine, you head towards the exit door. You push the door open and find yourself outside on the roof of a skyscraper."
ROOM_CORR1_MID[northF]=0
function ROOM_CORR1_MID_northF(){
    ROOM_ROOF_AC[look]="Two ${NPC}guards${ERASE} armed with stun batons and rifles flank a VTOL aircraft on the other side of the rooftop. There is no helipad. They do not notice you but seem alert.\nYou overhear one of them speaking into his comm-device:\n\n\"No sign of the body, he's still in the building somewhere.\"\n\nYou take cover behind an AC exhaust unit on the western side. There is a stairwell exit to the ${ROOM}east${ERASE} that might provide you with cover."
}
ROOM_CORR1_MID[south]="ROOM_CORR1"
ROOM_CORR1_MID[southT]="You head back south towards the flames."
ROOM_CORR1_MID[westT]="The wall of the corridor plastered with broken digital signage sparks occasionally."
ROOM_CORR1_MID[eastT]="The ${ROOM}east${ERASE}ern wall has collapsed, exposing the floor below. It looks like you are not on the ground floor. You might be able to survive the fall. Would you like to ${CLI}jump${ERASE} down?"
ROOM_CORR1_MID[east]=
ROOM_CORR1_MID[jump]=0
function jump(){
    ROOM_CORR1_MID[east]=ROOM_DOWN1
    actionHandler east
    damage=15
    echo -e "The fall hits your feet hard. A bit too hard. You take ${NPC}${damage}${ERASE} damage."
    let damage=$damage*-1
    adjustHealth damage
}

declare -A ROOM_DOWN1
ROOM_DOWN1[location]="Downstairs Maintainence Room"
ROOM_DOWN1[look]="You find yourself in a mantainence room filled with various boxes and switches on the walls. A holo-${INT}terminal${ERASE} glows faintly blue in the corner. There is a stairwell to the ${ROOM}north${ERASE}."
ROOM_DOWN1[terminal]=0
ROOM_DOWN1[northF]=0 #bool:unlocked?
ROOM_DOWN1[southT]="An assortment of cleaning robots sleep in their charging stations along the wall."
ROOM_DOWN1[eastT]="There is nothing of interest to the east."
ROOM_DOWN1[westT]="The floor above has collapsed and blocked the rest of the room. It is too high to jump back up."
function ROOM_DOWN1_northF(){
    if [ ${ROOM_DOWN1[northF]} ]; then
        ROOM_DOWN1[north]=ROOM_ROOF_STAIRWELL #unlock the door permanently
        currentRoom=ROOM_ROOF_STAIRWELL #i dont think this is needed
        echo -e "You ascend the stairs to the roof and see two ${NPC}guards${ERASE} armed with stun batons and rifles who flank a VTOL aircraft on the other side of the rooftop. There is no helipad."
        #the guards are alerted if you turn the lights from on to off
        if [ ${ROOM_ROOF_AC[lights]} ]; then
           echo -e "The ${NPC}guards${ERASE} do not notice you but seem alert.\nYou overhear one of them speaking into his comm-device:\n\n\"No sign of the body, he's still in the building somewhere.\"\n\nYou take cover behind the stairwell exit you just emerged from. There is an AC unit to the ${ROOM}west${ERASE} that might provide you with cover."
        else
            ROOM_ROOF_AC[stealth]=0
            echo -e "The ${NPC}guards${ERASE} have been alerted by the lights turning off. They pivot and rain your location with bullets. You take cover behind the stairwell exit you just emerged from.\nThere is an AC unit to the ${ROOM}west${ERASE} that might provide you with cover."
        fi;
    else
        echo -e "The stairwell to the ${ROOM}north${ERASE} is locked electronically."
    fi;
}

#this multiroom (AC+STAIRWELL) shall have shared member variables in the AC object
#this "room" is a bit different, it is a combat scene. All directional movement can also be actions like "attack" which will change the room to dissallow some room-member commands. This room will have different state (stealth|lights) depending on which path you take.
declare -A ROOM_ROOF_AC
ROOM_ROOF_AC[location]="Rooftop: In Cover (AC Unit)"
ROOM_ROOF_AC[look]=""
ROOM_ROOF_AC[_stealth]=1
ROOM_ROOF_AC[lights]=1
ROOM_ROOF_AC[floodlights]=1
function floodlights(){
    lights
}
function lights(){
    if [ ${ROOM_ROOF_AC[lights]} == 1]; then
        echo -e "The ${INT}lights${ERASE} illuminate the entire rooftop and the black plume of turbulent smoke rising from the south of the building, only casting shadows where the AC unit and ${ROOM}stairwell${ERASE} exit block the rays."
    else 
        echo -e "The ${INT}floodlights${ERASE} have been turned off. Two cones of light protrude from the ${NPC}guards${ERASE}' helmets to cut through the darkness."
    fi;
}
ROOM_ROOF_AC[northT]="The guards will notice you if you move north out of cover. Would you like to ${CLI}attack${ERASE} them instead?"
ROOM_ROOF_AC[southT]="The door behind you is jammed. You return to cover."
ROOM_ROOF_AC[westT]="You peer off the side of the skyscraper. The neon advertisements and hover-taxis that litter the night cityscape daze you for a few seconds. You snap out of it and quickly return to cover before the ${NPC}guards${ERASE} notice."
ROOM_ROOF_AC[east]=ROOM_ROOF_STAIRWELL
ROOM_ROOF_AC[eastF]=0
function ROOM_ROOF_AC_eastF(){
    if [ stealth ]; then
        echo -e "You dash to the ${ROOM}stairwell${ERASE} and try to open the door but it is electronically locked. You take cover behind the protrusion instead."
    else
        damage=25
        echo -e "The guards fire a hail of energy shots to where they think you are. You lose feeling and function in your robotically enhanced left arm for a second as it deflects a shot. You take ${NPC}${damage}${ERASE} damage."
        let damage=$damage*-1
        adjustHealth damage
    fi;
}

declare -A ROOM_ROOF_STAIRWELL
ROOM_ROOF_STAIRWELL[location]="Rooftop: In Cover (Stairwell)"
ROOM_ROOF_STAIRWELL[look]=

#functions -------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------#
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
        temp="${currentRoom}[${1}F]"
        #if the value at ROOM_CORR1[southF] is not empty
        if [ ! -z "${!temp}" ]; then
            #find the function called e.g ROOM_CORR1_southF
            ${currentRoom}_${1}F
        fi;
        out="${currentRoom}[${1}T]"
        echo -e ${!out}
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
        echo -e "${YOU}Green${ERASE} text refers to friendly character attributes."
        echo -e "${NPC}Red${ERASE} text refers to enemy attributes."
        echo -e "${ROOM}Pink${ERASE} text refers to places you may be able to travel to."
        echo -e "${CLI}Blue${ERASE} text refers other commands you can use."
        echo -e "\nCommon Commands:\n\nlocation ....... Displays the name of the room you are in."
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
#main loop -------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------#
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