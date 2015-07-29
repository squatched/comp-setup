#!/bin/bash -e
# Startup yakuake with specific tabs opened, titles, and commands run.
# Expects a file to be passed to it that contains on each line, the name
# to give the new tab and the command to be run to initialize the tab, comma
# separated. Lines that begin with '#' are ignored.
#
# E.G.:
#
# ==================== yakuakue_desktop.config ====================
# htop,htop
# journalctl,journalctl --follow --full
# proj,cd /srv/proj && clear
# shell
# =================================================================

# Trim leading/trailing white space.
# Cribbed from http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-bash-variable
trim ()
{
    local var="${@}"
    var="${var#"${var%%[![:space:]]*}"}"    # Remove leading whitespace
    var="${var%"${var##*[![:space:]]}"}"    # Remove trailing whitespace
    echo $var
}

# Helper that sends a command to yakuake
call_yakuake_method ()
{
    path="${1}"
    method="${2}"
    parameters=("${@:3}")
    result=$(dbus-send --print-reply=literal --dest=org.kde.yakuake /yakuake/${path} org.kde.yakuake.${method} "${parameters[@]}")
    result=$(trim ${result})

    if [[ -n "${result}" ]]
    then
        echo "${result}"
    fi
}

# Retrieves the currently active session id
get_active_session_id ()
{
    call_yakuake_method sessions activeSessionId | rev | cut -d" " -f1 | rev
}

# Makes a session active.
set_active_session ()
{
    call_yakuake_method sessions raiseSession "int32:${1}"
}

# Retrieves the terminal ids for a given tab
get_terminal_ids_for_tab ()
{
    # These tab ids are returned comma delimited. Replace the commas for easier time
    #   getting the results as an array.
    call_yakuake_method sessions terminalIdsForSessionId "int32:${1}" | sed -e 's/,/ /g'
}

# Returns the tab's id.
add_tab ()
{
    # Returns something of the form "int32 ##" so grab just the last digit.
    call_yakuake_method sessions addSession | rev | cut -d" " -f1 | rev
}

# Takes a tab id and the title string
set_tab_title ()
{
    call_yakuake_method tabs setTabTitle "int32:${1}" "string:${@:2}"
}

# Takes a tab id and the command string
run_tab_command_in_first_terminal ()
{
    terminals=($(get_terminal_ids_for_tab "${1}"))
    call_yakuake_method sessions runCommandInTerminal "int32:${terminals[0]}" "string:${@:2}"
}

# If we're given a file name, then process it. (Allows this script to be dot sourced)
config_file_name="${*}"
if [[ -n "${config_file_name}" ]]
then
    INITIAL_SESSION_ID=$(get_active_session_id)
    
    while IFS=, read -r tab_title tab_command;
    do
        # Trim variables.
        tab_title=$(trim "${tab_title}")
        tab_command=$(trim "${tab_command}")

        # Skip any title in the file starting with a "#"
        if [[ "${tab_title}" =~ ^#.*$ ]]
        then
            continue
        fi

        # Create the new tab
        tab_id=$(add_tab)

        # Give it a title.
        if [[ -n "${tab_title}" ]]
        then
            set_tab_title "${tab_id}" "${tab_title}"
        fi
        
        # Run the command.
        if [[ -n "${tab_command}" ]]
        then
            run_tab_command_in_first_terminal "${tab_id}" "${tab_command}"
        fi
    done <"${config_file_name}"

    set_active_session ${INITIAL_SESSION_ID}
fi
