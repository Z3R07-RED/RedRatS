#!/data/data/com.termux/files/usr/bin/bash
#RedRatS
#Coded by Z3R07-RED on Jun 23 2021
#
#VARIABLES:
termux_path="/data/data/com.termux/files/usr/bin"
kali_linux_path="/usr/bin"
DIALOG=${DIALOG=dialog}
dialogrc_file=".config/GreenPower.conf"
WIFIA=""

#colors dialog
if [[ -f "$dialogrc_file" ]]; then
    export DIALOGRC=$dialogrc_file
fi
#universal_functions && universal_variables
if [[ -f "CS07/universal_functions" && -f "CS07/universal_variables" ]]; then
    source "CS07/universal_functions"
    source "CS07/universal_variables"
else
    echo -e "[ERROR]: \"universal_functions\" \"universal_variables\""
    echo "";exit 1
fi
#colors
if [[ -f "$colors" ]]; then
    source "$colors"
else
    file_not_found "colors"
fi

# Directory
if [[ ! -d "$log_directory" ]]; then
	mkdir $log_directory
fi

# Directory
if [[ ! -d "$tmp_directory" ]]; then
	mkdir "$tmp_directory"
fi

#CTRL+C
trap ctrl_c INT

function ctrl_c(){
echo $(clear)
rm -rf tmp/* 2>/dev/null
rm -rf logs/* 2>/dev/null
echo "Program aborted."
tput cnorm
echo "";exit 1
}

#FUNCTIONS:
function ncurses_utils(){
if [ ! "$(command -v tput)" ]; then
	echo -e "\n${Y}[I]${W} apt install ncurses-utils ...${W}"
	apt install ncurses-utils -y > /dev/null 2>&1
	sleep 1
fi
}

# dependencies
function dependencies(){
if [[ -d "$kali_linux_path" ]]; then
   ZEROAPT="apt-get"
else
    ZEROAPT="apt"
	ncurses_utils
fi

tput civis; counter_dn=0
echo $(clear);sleep 0.3

PKGS=(dialog git wget curl play-audio mpv python sox) # dependencies
for program in "${PKGS[@]}"; do
    if [ ! "$(command -v $program)" ]; then
        echo -e "\n${R}[X]${W}${C} $program${Y} is not installed.${W}"
        sleep 0.8
        echo -e "\n\e[1;33m[i]\e[0m${C} Installing ...${W}"
        $ZEROAPT install $program -y > /dev/null 2>&1
        echo -e "\n\e[1;32m[V]\e[0m${C} $program${Y} installed.${W}"
        sleep 1
        let counter_dn+=1
    fi
done

if [[ ! -f "$log_directory/termux-api.txt" ]]; then
    if [ ! "$(command -v termux-api)" ]; then
        apt install termux-api -y
        echo ""; sleep 0.4
        apt install termux-services -y
        touch "$log_directory/termux-api.txt"
        sleep 1
    fi
    pip3 install requests
    pip3 install gtts
fi

if [ ! "$(command -v ssh)" ]; then
    pkg install openssh
    sleep 1
fi

play-audio CS07/Sounds/RedRatS_connected.mp3 2>/dev/null &
$DIALOG --backtitle "Community - Club Secreto 07" \
     --colors --title "$program_name - v$version" \
     --infobox "\n\Zu$program_name (c) $(echo "$making" |awk 'NF{print $NF}' 2>/dev/null) by $author\Zn\n\nThis program comes ABSOLUTELY WITHOUT WARRANTY;\nthanks for using the program." 10 60 ;sleep 4

tput cnorm
}

# Tome Fotos
function sacar_fotos(){
echo $(clear)
echo -e "${R}  |${W}"
echo -e "${R}-[${W}O${R}]-${W} Buscando la cámara ..."
echo -e "${R}  |${W}"
sleep 0.2
FOTONAME=""
let CAMARAS01=$(termux-camera-info 2>/dev/null| grep '\"id\":' |wc -l)
let CAMARAS=$(($CAMARAS01 - 1))

if [[ ! -d "Fotos" ]]; then
    mkdir "Fotos"
fi

for camaras in $(seq 0 $CAMARAS);
do
    if [ "$(command -v termux-camera-photo)" ]; then
        FOTONAME=$(randdata 10)
        termux-camera-photo -c "$camaras" "Fotos/$camaras-$FOTONAME.jpg"
        sleep 0.5
        $DIALOG --backtitle "$program_name - $author" \
                --title "CAMARA" \
                --infobox "\nCAMARA: [$camaras]\nFOTO  : Fotos/$camaras-$FOTONAME.jpg" 10 60
        sleep 1
    else
        unexpected_error
    fi
done
}

# Activa la Linterna
function activa_linterna(){
while true :
do
if [[ -f "$log_directory/activa_linterna.log" ]]; then
    LINTON="on"
    LINTOFF="off"
else
    LINTON="off"
    LINTOFF="on"
fi

LinternaA=$($DIALOG --stdout --backtitle "$program_name" \
                   --ok-label "Select" --item-help --default-item 1 --no-collapse --title "Linterna" \
                   --radiolist "Activa la Linterna del dispositivo\n\
Presione la tecla 'Espace' y luego 'Enter'" 12 50 2 \
                   1 "[ Linterna - ON  ]" $LINTON   "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
                   2 "[ Linterna - OFF ]" $LINTOFF  "[↑↓]-Move [SPACE]-Select [ESC]-Exit")

case $? in
    0)
        if [[ "$LinternaA" == 1 ]]; then
            touch "$log_directory/activa_linterna.log" 2>/dev/null
            play-audio CS07/Sounds/linterna_on.mp3 2>/dev/null &
            if [[ "$LINTON" == "off" ]]; then
                if [ "$(command -v termux-torch)" ]; then
                    termux-torch on
                else
                    unexpected_error
                fi
            fi
            LinternaA="Activa"
        elif [[ "$LinternaA" == 2 ]]; then
            rm -rf "$log_directory/activa_linterna.log" 2>/dev/null
            play-audio CS07/Sounds/linterna_off.mp3 2>/dev/null &
            if [[ "$LINTON" == "on" ]]; then
                if [ "$(command -v termux-torch)" ]; then
                    termux-torch off
                else
                    unexpected_error
                fi
            fi
            LinternaA="OFF"
        fi
        $DIALOG --backtitle "$program_name" \
                --title "INFORMATION" \
                --infobox "\n Linterna = $LinternaA" 8 50; sleep 2
        ;;
    1)
        break
        ;;
    255)
        echo $(clear)
        echo "Program aborted." >&2
        echo "";exit 1
        ;;
esac
done
}

function cambie_fondo(){
if [ ! "$(command -v termux-wallpaper)" ]; then
    unexpected_error
fi
$DIALOG --backtitle "$program_name" \
    --title "" \
    --prgbox "Cambio de fondo ..." "termux-wallpaper -f CS07/images/6832.jpg 2>/dev/null; play-audio CS07/Sounds/Changed_background.mp3 2>/dev/null & " 10 50
}

# Activar desactiva WIFI
function activa_wifi(){
while true :
do
if [[ -f "$log_directory/activa_wifi.log" ]]; then
    WIFION="on"
    WIFIOFF="off"
else
    WIFION="off"
    WIFIOFF="on"
fi

if [[ "$WIFIA" == "" ]]; then
    WIFION="off"
    WIFIOFF="off"
fi

WIFIA=$($DIALOG --stdout --backtitle "$program_name" \
                   --ok-label "Select" --item-help --default-item 1 --no-collapse --title "WIFI" \
                   --radiolist "Activa el wifi del dispositivo\n\
Presione la tecla 'Espace' y luego 'Enter'" 12 50 2 \
                   1 "[ WIFI - ON  ]" $WIFION  "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
                   2 "[ WIFI - OFF ]" $WIFIOFF "[↑↓]-Move [SPACE]-Select [ESC]-Exit")

case $? in
    0)
        if [[ "$WIFIA" == 1 ]]; then
            touch "$log_directory/activa_wifi.log" 2>/dev/null
            play-audio CS07/Sounds/wifi_on.mp3 2>/dev/null &
            if [[ "$WIFION" == "off" ]]; then
                termux-wifi-enable "true"
            fi
            WIFIA="Activa"
        elif [[ "$WIFIA" == 2 ]]; then
            rm -rf "$log_directory/activa_wifi.log" 2>/dev/null
            play-audio CS07/Sounds/wifi_off.mp3 2>/dev/null &
            termux-wifi-enable "false"
            WIFIA="OFF"
        fi
        $DIALOG --backtitle "$program_name" \
                --title "INFORMATION" \
                --infobox "\n WI-FI = $WIFIA" 8 50; sleep 2
        ;;
    1)
        WIFIA="true"
        break
        ;;
    255)
        echo $(clear)
        echo "Program aborted." >&2
        echo "";exit 1
        ;;
esac
done
}

dependencies
internet_connection

while true :
do
OPTIONMRT=$($DIALOG --stdout --backtitle "$program_name - $author" \
        --no-collapse --ok-label "Select" --cancel-label "Exit" --title "MENU" \
        --menu "" 10 60 5 \
        1 "[ Activa la Linterna del dispositivo ]" \
        2 "[ Vibre el dispositivo               ]" \
        3 "[ Cambie el fondo de pantalla        ]" \
        4 "[ Activa o desactiva el Wi-Fi        ]" \
        5 "[ Reproductor de musica              ]" \
        6 "[ Tome una foto y guárdela           ]" \
        7 "[ Texto a audio                      ]")

case $? in
    0)
        if [[ "$OPTIONMRT" == 1 ]]; then
            activa_linterna
        elif [[ "$OPTIONMRT" == 2 ]]; then
            if [ "$(command -v termux-vibrate)" ]; then
                termux-vibrate -f -d 1000
            else
                unexpected_error
            fi
            $DIALOG --backtitle "$program_name" \
                 --title "INFORMATION" \
                 --infobox "\n¡El móvil vibró con éxito! :)" 8 60; sleep 2
        elif [[ "$OPTIONMRT" == 3 ]]; then
            cambie_fondo
        elif [[ "$OPTIONMRT" == 4 ]]; then
            activa_wifi
        elif [[ "$OPTIONMRT" == 5 ]]; then
            ls /sdcard/ &>/dev/null
            if [[ $? = 0 ]]; then
                $DIALOG --backtitle "$program_name" \
                       --title "" \
                       --prgbox "Buscando los audios ..." "mpv /sdcard/ 2>/dev/null" 15 60
            fi
        elif [[ "$OPTIONMRT" == 6 ]]; then
            sacar_fotos
            sleep 5

        elif [[ "$OPTIONMRT" == 7 ]]; then
            source "CS07/Converter07/converter.sh"
        fi
        ;;
    1)
        echo $(clear)
        echo "Exiting ..."
        echo "";exit 0
        ;;
    255)
        echo $(clear)
        echo "Program aborted." >&2
        echo "";exit 1
        ;;
esac
done


