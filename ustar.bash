#!/usr/bin/env bash
# shellcheck disable=SC2034

# @Author: goregath
# @Date:   2023-07-29 14:28:29
# @Last Modified by:   goregath
# @Last Modified time: 2023-07-31 20:43:17

# Dump a tar-header with payload to stdout according to POSIX 1003.1-1990 with a blocksize of 512.
ustar-dump() {
    local IFS= LC_CTYPE=C
    local OPTARG OPTIND OPTERR=1 opt
    #             0   1        5            10          15
    local -ra T=( s   o o o o  d  s t s   s s s  s  o o s   s  s )
    local -ra W=( 100 8 8 8 12 12 8 1 100 6 2 32 32 8 8 155 12 512 )
    eval local -a F=\( [{0..17}]= \)
    local -n w="W[i]" t="T[i]"
    local -i i d
    local v
    usage() {
        printf 'USAGE: ustar-dump [-hBCDFLPS] [-o OPT] [--] [PATH] [PAYLOAD]\n'
    }
    dump_i() {
        # Dump field at `i` aligned to field width `w`.
        local -i n=${#F[i]}
        local -i p=$(( n == 0 ? w : (n != w ? w - n % w : 0) ))
        # Special case for i=17: Do not dump if payload is zero length.
        if (( i != 17 || n > 0 )); then
            printf %s "${F[i]}"
            if (( p > 0 )); then
                eval "printf '\\0%.0s' {1..$p}"
            fi
        fi
    }
    set_iv() {
        # Set field at `i` to `v` with respect to type and width.
        local -n w="W[i]" t="T[i]"
        case $t in
            t )
                case "$v" in
                    -|reg|file|regular ) v=0 ;;
                    h|lnk|link|hardlink ) v=1 ;;
                    l|sym|symlink ) v=2 ;;
                    c|chr|char ) v=3 ;;
                    b|blk|block ) v=4 ;;
                    d|dir|directory ) v=5 ;;
                    p|fifo|pipe ) v=6 ;;
                    [0-6] ) ;;
                    * )
                        printf "error: %q: invalid type flag\n" "$v" >&2
                        return 1 ;;
                esac
                ;;& # continue
            d )
                case "$v" in
                    now ) v=$EPOCHSECONDS ;;
                esac
                ;& # fallthrough
            o )
                if ! printf '%o' "$v" >/dev/null 2>&1; then
                    printf "error: %q: invalid number\n" "$v" >&2
                    return 1
                fi
                printf -v v '%o' "$v"
                ;& # fallthrough
            * )
                if (( w > 1 && ${#v} > w-1 )); then
                    printf "error: %q does not fit string[%d]\n" "$v" "$w" >&2
                    return 1
                fi
                F[i]="$v" ;;
        esac
    }
    setpath_v() {
        # Set a file path and split up between fields of `name` (0) and
        # `prefix` (15) whenever possible.
        local p n t
        # Set and truncate value to `prefix` of width 154+1. We allow an
        # additional character to handle an additional `/`.
        p="${v:0:155}"
        # find last `/` in prefix
        t="${p##*/}"
        # trim right-hand side of `/` from `prefix`
        p="${p%"$t"}"
        # trim `prefix` from value to get `name` 
        n="${v#"$p"}"
        # trim leading `/` from `prefix` if any
        p="${p%/}"
        i=15 v="$p" set_iv
        i=0  v="$n" set_iv
    }
    setopt() {
        # Parse `OPTARG` to field assignments.
        # FORMAT: key=value[,[key=value]]..
        local -i i
        local -a argv fldv
        local arg k v
        # shellcheck disable=SC2162
        IFS=$',\n' read -a argv <<<"$OPTARG"
        for arg in "${argv[@]}"; do
            IFS=+ read -ra fldv <<<"${arg%%=*}"
            for k in "${fldv[@]}"; do
                v="${arg#*=}"
                case "$k" in
                    n|name ) i=0 ;;
                    m|mode ) i=1 ;;
                    u|uid ) i=2 ;;
                    g|gid ) i=3 ;;
                    s|size ) i=4 ;;
                    t|date|time|mtime ) i=5 ;;
                    T|type ) i=7 ;;
                    l|link|linkname|target ) i=8 ;;
                    U|user|uname ) i=11 ;;
                    G|group|gname ) i=12 ;;
                    D|major|devmajor ) i=13 ;;
                    d|minor|devminor ) i=14 ;;
                    p|prefix ) i=15 ;;
                    P|path )
                        setpath_v
                        continue
                        ;;
                    * )
                        printf 'error: unknown field %q\n' "$k" >&2
                        return 1
                        ;;
                esac
                set_iv
            done
        done
    }
    if [[ -n ${USTAR_OPTS:+x} ]]; then
        OPTARG="$USTAR_OPTS" setopt
    fi
    while getopts ":hBCDFLPSo:" opt; do
        case "$opt" in
            o) setopt ;;
            h) usage; return ;;
            B) OPTARG="T=b,m=0666" setopt ;;
            C) OPTARG="T=c,m=0666" setopt ;;
            D) OPTARG="T=d,m=0775" setopt ;;
            F) OPTARG="T=-,m=0644" setopt ;;
            L) OPTARG="T=h,m=0644" setopt ;;
            S) OPTARG="T=l,m=0777" setopt ;;
            *) usage >&2; return 1 ;;
        esac
    done
    shift $((OPTIND-1))
    if [[ -z ${F[15]:+x}${F[0]:+x} ]]; then
        # Use first argument ($1) to set the path if neither `name` (0) nor
        # `prefix` (15) has been previously set. This mode is for convenience
        # and offers some auto magic-like:
        # - trim trailing `/`
        # - append `/` if type is set to directory
        printf -v v '%s%b' "${1/%\/*/}" "\\0$(( 57 * (F[7] == 5) ))"
        setpath_v
    fi
    # size     magic      version  reserved payload
    F[4]=${#2} F[9]=ustar F[10]=00 F[16]="" F[17]="$2"
    # calculate header checksum for fields 0..15
    v="${F[*]:0:16}"
    for (( i=0,F[6]=256; i<${#v}; i++,F[6]+=d )); do
        # Get ordinal number for ASCII character,
        # this is equivalent to ord(v[i]).
        printf -v d %d "'${v:$i:1}"
    done
    printf -v F[6] %o "${F[6]}"
    for (( i=0; i<18; i++ )); do
        # dump fields
        dump_i
    done
}