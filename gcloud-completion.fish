# Fish shell completion for gcloud, gsutil, and bq
# Fish equivalent of completion.bash.inc / completion.zsh.inc

function __fish_python_argcomplete
    set -l cmd $argv[1]
    set -l cmdline (commandline)
    set -l cursor (commandline --cursor)
    set -l prefix ''

    if string match -q 'gcloud *' -- "$cmdline"
        # Get tokenized command line up to cursor; last token is current word,
        # second-to-last is previous word (equivalent to bash $2 and $3)
        set -l tokens (commandline -opc)
        set -l current_word (commandline --current-token)
        set -l prev_word ''
        if test (count $tokens) -ge 2
            set prev_word $tokens[-2]
        end

        # Handle ssh user@instance specially
        if test "$prev_word" = ssh; and string match -q '*@*' -- "$current_word"
            set prefix (string replace -r '@.*' '@' -- "$current_word")
            set -l trimmed (string replace -r '^[^@]*@' '' -- "$current_word")
            set cmdline (string replace -- "$current_word" "$trimmed" "$cmdline")
        # Handle --flag=value
        else if string match -q '*=*' -- "$current_word"
            set prefix (string replace -r '=.*' '=' -- "$current_word")
            set -l replaced (string replace -- '=' ' ' "$current_word")
            set cmdline (string replace -- "$current_word" "$replaced" "$cmdline")
        end
    end

    # Call the command with _ARGCOMPLETE=1; completions are written to fd 8.
    # 8>&1 redirects fd 8 into the command substitution capture pipe;
    # 1>/dev/null and 2>/dev/null silence normal stdout and stderr.
    set -l output (env \
        IFS='' \
        COMP_LINE="$cmdline" \
        COMP_POINT="$cursor" \
        _ARGCOMPLETE=1 \
        _ARGCOMPLETE_COMP_WORDBREAKS="\"'><=;|&(:" \
        $cmd 8>&1 9>/dev/null 1>/dev/null 2>/dev/null)

    test -z "$output"; and return

    # Argcomplete separates completions with \013 (vertical tab / \x0b).
    # Split on that character, strip trailing whitespace, and add any
    # prefix accumulated above (for user@ or --flag= cases).
    for c in (string split \x0b -- $output)
        set c (string trim -r -- $c)
        test -n "$c"; and echo "$prefix$c"
    end
end

function __fish_bq_complete
    # Lazy-load bq subcommands (equivalent to the unset + eval cache trick)
    if not set -q __fish_bq_commands
        set -g __fish_bq_commands (CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1 bq help 2>/dev/null | grep '^[^ ][^ ]*  ' | sed 's/ .*//')
    end

    # Collect non-flag tokens that follow 'bq' itself.
    # If there is already one such token the subcommand has been chosen and
    # we have nothing further to offer (mirrors the [[ $2 ]] && return logic).
    set -l tokens (commandline -opc)
    set -l non_flags
    if test (count $tokens) -gt 1
        for t in $tokens[2..]
            string match -q -- '-*' $t; or set -a non_flags $t
        end
    end

    if test (count $non_flags) -eq 0
        printf '%s\n' $__fish_bq_commands
    end
end

complete -c gcloud -f -a '(__fish_python_argcomplete gcloud)'
complete -c gsutil -f -a '(__fish_python_argcomplete gsutil)'
complete -c bq     -f -a '(__fish_bq_complete)'
