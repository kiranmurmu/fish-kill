function __fish_make_completion_signals --description 'Make list of kill signals for completion'
  set -q __kill_signals
  and return 0

  set -g __kill_signals

  # Cygwin's kill is special, and the documentation lies.
  # Just hardcode the signals.
  set -l os (uname -o)
  if string match -q 'CYGWIN*' -- $os
    or string match -iq Msys -- $os
    set -a __kill_signals "1 HUP" "2 INT" "3 QUIT" "4 ILL" "5 TRAP" "6 ABRT" \
      "7 EMT" "8 FPE" "9 KILL" "10 BUS" "11 SEGV" "12 SYS" "13 PIPE" \
      "14 ALRM" "15 TERM" "16 URG" "17 STOP" "18 TSTP" "19 CONT" "20 CHLD" \
      "21 TTIN" "22 TTOU" "23 IO" "24 XCPU" "25 XFSZ" "26 VTALRM" "27 PROF" \
      "28 WINCH" "29 PWR" "30 USR1" "31 USR2" "32 RTMIN" "64 RTMAX"
    alias kill.exe="kill"
    return
  end

  # Some systems use the GNU coreutils kill command where `kill -L` produces an extended table
  # format that looks like this:
  #
  #  1 HUP    Hangup: 1
  #  2 INT    Interrupt: 2
  #
  # The procps `kill -L` produces a more compact table. We can distinguish the two cases by
  # testing whether it supports `kill -t`; in which case it is the coreutils `kill` command.
  # Darwin doesn't have kill -t or kill -L
  if kill -t 2>/dev/null >/dev/null
    or not kill -L 2>/dev/null >/dev/null
    # Posix systems print out the name of a signal using 'kill -l SIGNUM'.
    complete -c kill -s l --description "List names of available signals"
    for i in (seq 31)
      set -a __kill_signals $i" "(kill -l $i | string upper)
    end
    set -a __kill_signals "32 RTMIN" "64 RTMAX"
  else
    # util-linux (on Arch) and procps-ng (on Debian) kill use 'kill -L' to write out a numbered list
    # of signals. Use this to complete on both number _and_ on signal name.
    complete -c kill -s L --description "List codes and names of available signals"
    kill -L | string trim | string replace -ra '   *' \n | while read -l signo signame
      set -a __kill_signals "$signo $signame"
    end
  end
end

# Do not show error status when using specific kill commands.
function kill
  if string match -qr '(-l|--list|-V|--version)' -- $argv
    command kill (__fish_expand_pid_args $argv) 2>/dev/null
    if test $status -eq 1
      return
    end
  else
    command kill (__fish_expand_pid_args $argv)
  end
end
