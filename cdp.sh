#!/bin/bash

# shellcheck source=./util.sh disable=SC2155
function _dl_util_sh {
    local UTIL_VERSION="v2.2.5"
    local dir="$( dirname "$1" )"
    [ -f "${dir}/util.sh" ] || bash "${dir}/download-util.sh" "$UTIL_VERSION" || exit 1
    source "${dir}/util.sh"
}; _dl_util_sh "$0"

ARG_DIR=""
PROJ_EXTS=(
html
js
json
lua
rb
ron
rs
sh
toml
ts
)

HELP=$(cat <<END
USAGE
    ${0} [FLAGS...] [OPTIONS...] [DIR]

DESCRIPTION
    Finds project directories and feeds them to FZF.
    Cd into the selected project.
    A project is directory is identified by containing
    any form of code or manifest files, by checking
    files' extensions.
    File extensions to identify project directories by:
        ${PROJ_EXTS[*]}

ARGUMENTS
    DIR
        Directory to fuzzy find projects in.
        DEFAULT: "\$HOME/Projects"

FLAGS
    --help, -h
        Print help and exit.
END
)

function main {
    check "find"
    check "fzf"
    check_file "./find_projects"

    parse_args "$@"

    local project_dirs=
    project_dirs=$(find_projects)
}

function find_projects {
    local dirs=
    dirs=$( ./find_projects )
}

function parse_args {
    while [ -n "$1" ]; do
        case "$1" in
            "--help"|"-h")
                print_help
                ;;
            *)
                if [ -z "$ARG_DIR" ]; then
                    ARG_DIR="$1"
                else
                    err "Invalid argument: $(clrcode)$1$(clrrs)"
                fi
        esac
        shift
    done

    [ -z "$ARG_DIR" ] && ARG_DIR="$HOME/Projects"

    true
}

function print_help {
    echo "$HELP"
    exit 0
}

function clrcode {
    clr "${CLR_CODE[@]}"
}

main "$@"
