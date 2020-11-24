#!/bin/bash

# shellcheck source=./util.sh disable=SC2155
function _dl_util_sh {
    local UTIL_VERSION="v2.2.5"
    local dir="$( dirname "$1" )"
    [ -f "${dir}/util.sh" ] || bash "${dir}/download-util.sh" "$UTIL_VERSION" || exit 1
    source "${dir}/util.sh"
}; _dl_util_sh "$0"

FIND_PROJECTS_PROG="${ROOT}/find_projects"

OPT_ROOT=
ARG_PATTERN=

HELP=$(cat <<END
USAGE
    ${0} [FLAGS...] [OPTIONS...] [PATTERN]

DESCRIPTION
    Finds project directories and feeds them to FZF.
    Cd's into the selected project.

    A project is directory is identified by containing
    any form of code or manifest files, by checking
    files' extensions.
    File extensions to identify project directories by:
        html js json lua rb ron rs sh toml ts

    Uses rust program \`./find_projects.rs\`.
    Run \`./build\` to compile (must have \`rustc\` installed).

ARGUMENTS
    PATTERN
        If PATTERN is given, then fzf isn't started,
        instead the first project directory match
        for PATTERN is used.
        Non-interactive.
        If not given, runs interactively with fzf.

FLAGS
    --help, -h
        Print help and exit.

OPTIONS
    --root ROOT
        Directory to fuzzy find projects in.
        DEFAULT: "\$HOME/Projects"
END
)

function main {
    check "fzf"
    check "grep"
    check_file "$FIND_PROJECTS_PROG"

    parse_args "$@"

    local select_project=
    select_project=$( run_find_projects "$OPT_ROOT" "$ARG_PATTERN" )

    echo "$select_project"
}

function run_find_projects {
    local root_dir="$1"
    local pattern="$2"

    if [ -z "$pattern" ]; then
        # interactive
        $FIND_PROJECTS_PROG "$root_dir" | fzf
    else
        # with PATTERN argument
        $FIND_PROJECTS_PROG "$root_dir" \
            | sort \
            | grep -i "$pattern" \
            | head -n 1
    fi
}

function parse_args {
    while [ -n "$1" ]; do
        case "$1" in
            "--help"|"-h")
                print_help
                ;;
            "--root")
                OPT_ROOT="$2"
                [ -z "$OPT_ROOT" ] && err "No value given to option $(clrcode)$1$(clrrs)"
                shift || true
                ;;
            *)
                if [ -z "$ARG_PATTERN" ]; then
                    ARG_PATTERN="$1"
                else
                    err "Invalid argument: $(clrcode)$1$(clrrs)"
                fi
                ;;
        esac
        shift
    done

    [ -z "$OPT_ROOT" ] && OPT_ROOT="$HOME/Projects"
    [ -d "$OPT_ROOT" ] \
        || err "Root directory $(clrcode)${OPT_ROOT}$(clrrs) is not a directory."

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
