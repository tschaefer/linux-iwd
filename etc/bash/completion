_iwstatus() {
    local cur prev words cword
    _get_comp_words_by_ref cur prev words cword

    local actions='adapters devices known-networks networks diagnostics'
    local options='--help --man --version --no-pager --no-legend'

    case "$prev" in
        --help|--man|--version)
            return
            ;;
    esac

    local word action
    for word in "${words[@]}"; do
        case $word in
            networks|diagnostics)
                action=$word
                break
                ;;
        esac
    done

    case $action in
        networks|diagnostics)
            _available_interfaces
            return
            ;;
    esac


    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "${options}" -- "$cur"))
        return
    fi

    COMPREPLY=($(compgen -W "${actions}" -- "$cur"))

    return
}

complete -F _iwstatus iwstatus

# vim: ft=sh
