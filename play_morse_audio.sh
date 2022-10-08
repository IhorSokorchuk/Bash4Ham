#! /bin/bash

# This is an program for play morse code audio
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
# Print a sox effects text
# GLOBALS:
#
# ARGUMENTS:
#   PARIS_wpm tone_Hz text_string ...
# OUTPUTS:
#   Print a sox effects text
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
echo_morse_sox_effects_file_text() {
  local wpm="$1" && shift
  local tone="$1" && shift
  local string="$*"

  local i element
  local -u char

  # PARIS: 2+4+4+2+ 1+ 2+4+ 1+ 2+4+2+ 1+ 2+2+ 1+ 2+2+2+ 2 = 42
  dit="$(printf '0.%3.3u' $((60000/(wpm*42))))"
  dah="$(printf '0.%3.3u' $((180000/(wpm*42))))"

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

tone='700'
wpm='22'
morse_text='DE UR3LCM/QRP'

# make special pipe file
[ -e pipe ] || mknod pipe p
[ -p pipe ] || exit

# play morse code audio
sox -n --effects-file pipe -p \
| sox -p -p bandpass $tone 50 norm -18 \
| play -q -p -t alsa &
echo_morse_sox_effects_file_text ${wpm} ${tone} "$morse_text " >pipe

exit

# EOF
