#!/bin/bash
# pv wrapper that imitates cp usage
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#   cpv file_or_dir_src file_or_dir_dst
#
# More details at ownyourbits.com

function cpv()
{
  local DST=${@: -1}                    # last element
  local SRC=( ${@: 1 : $# - 1} )        # array with rest of elements

  # checks
  type pv &>/dev/null || { echo "install pv first"; return 1; }
  [ $# -lt 2  ]       && { echo "too few args"    ; return 1; }

  # special invocation
  function cpv_rename()
  {
    local SRC="$1"
    local DST="$2"
    local DSTDIR="$( dirname "$DST" )"

    # checks
    if   [ $# -ne 2     ]; then echo "too few args"          ; return 1; fi
    if ! [ -e "$SRC"    ]; then echo "$SRC doesn't exist"    ; return 1; fi
    if   [ -d "$SRC"    ]; then echo "$SRC is a dir"         ; return 1; fi
    if ! [ -d "$DSTDIR" ]; then echo "$DSTDIR does not exist"; return 1; fi

    # actual copy
    echo -e "\n$SRC 🡺  $DST"
    pv   "$SRC" >"$DST"
  }

  # special case for cpv_rename()
  if ! [ -d "$DST" ]; then cpv_rename "$@"; return $?; fi;

  # more checks
  for src in "${SRC[@]}"; do 
    local dst="$DST/$( basename "$src" )"
    if ! [ -e "$src" ]; then echo "$src doesn't exist" ; return 1;
    elif [ -e "$dst" ]; then echo "$dst already exists"; return 1; fi
  done

  # actual copy
  for src in "${SRC[@]}"; do 
    if ! [ -d "$src" ]; then 
      local dst="$DST/$( basename "$src" )"
      echo -e "\n$src 🡺  $dst"
      pv "$src" > "$dst"
    else 
      local dir="$DST/$( basename "$src" )"
      mkdir "$dir" || continue
      local srcs=( $src/* )
      cpv "${srcs[@]}" "$dir";
    fi
  done
  unset cpv_rename
}

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
