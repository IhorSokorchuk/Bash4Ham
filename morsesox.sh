#! /bin/bash

# This is a script to create sound files 
# with Morse signals from text strings
# Copyright (C) 2022 Ihor Sokorchuk ur3lcm@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

declare -rA morse=(
['Q']='--.-'
['W']='.--'
['E']='.'
['R']='.-.'
['T']='-'
['Y']='-.--'
['U']='..-'
['I']='..'
['O']='---'
['P']='.--.'
['A']='.-'
['S']='...'
['D']='-..'
['F']='..-.'
['G']='--.'
['H']='....'
['J']='.---'
['K']='-.-'
['L']='.-..'
['Z']='--..'
['X']='-..-'
['C']='-.-.'
['V']='...-'
['B']='-...'
['N']='-.'
['M']='--'
['1']='.----'
['2']='..---'
['3']='...--'
['4']='....-'
['5']='.....'
['6']='-....'
['7']='--...'
['8']='---..'
['9']='----.'
['0']='-----'
['/']='-..-.'
['-']='-..-.'
['?']='..--..'
[' ']='s'
['_']='s'
['#']='-...-'
['%']='-...-.-'
['&']='-.--.'
['$']='...-.-'
)

#######################################
# Print strings for sox effects file
# GLOBALS:
#   
# ARGUMENTS:
#   PARIS_wpm tone_Hz string ...
# OUTPUTS:
#   Write Strings to stdout
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
echo_morse_sox_effects_file() {
  local wpm="$1" && shift
  local tone="$1" && shift
  local string="$*"

  local i element
  local -u char

  # PARIS: 1331 2 13 2 131 2 11 2 111 3 = 33
  dit="$(printf '0.%3.3u' $((60000/(wpm*33))))"
  dah="$(printf '0.%3.3u' $((180000/(wpm*33))))"

  for (( i = 0; i < ${#string}; i++ )); do
    char="${string:$i:1}"
    morse_code="${morse["$char"]}"
    for (( j = 0; j < ${#morse_code}; j++ )); do
      morse_element="${morse_code:$j:1}"
      case "${morse_element}" in
      .) echo -n "synth ${dit} sine ${tone} : trim 0.0 ${dit} : "
      ;;
      -) echo -n "synth ${dah} sine ${tone} : trim 0.0 ${dit} : "
      ;;
      s) echo -n "trim 0.0 ${dit} : "
      ;;
      esac
    done
    echo "trim 0.0 ${dit}"
  done
}

# MAIN

sox_effects_file='morse_text.txt'
audio_file='morse_text.wav'

###########

tone='700'
wpm='22'
morse_text='DE UR3LCM/QRP'

# make morse_sox_effects_file
echo_morse_sox_effects_file ${wpm} ${tone} "$morse_text" >${sox_effects_file}
# make morse audio file
rm -f ${audio_file}
sox -n -t raw -r 48000 -b 32 -c 1 -L -e signed-integer - --effects-file ${sox_effects_file} \
| sox -t raw -r 48000 -b 32 -c 1 -L -e signed-integer - ${audio_file} bandpass $tone 50 norm -18

#############

tone='800'
wpm='19'
morse_text=' DE UR4LWM'

# echo_morse_sox_effects_file ${wpm} ${tone} "$morse_text" >${sox_effects_file}
# sox -n tmp-${audio_file} --effects-file ${sox_effects_file}
# sox tmp-${audio_file} 2-${audio_file} sinc "$(( tone - 50 ))-$(( tone + 50 ))"

#############

# sox -m 1-${audio_file} 2-${audio_file} ${audio_file}

# sox synth ${dit} noise : 

# volume='-0.9'
# play -v ${volume} -q ${audio_file} #2>/dev/null
[ -f ${audio_file} ] && play -q ${audio_file} -t alsa # 2>&1 >/dev/null &

# EOF
