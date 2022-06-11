function kill
  # Do not show error status when using specific kill commands.
  if string match -qr '(-l|--list|-V|--version)' -- $argv
    command kill (__fish_expand_pid_args $argv) 2>/dev/null
    if test $status -eq 1
      return
    end
  else
    command kill (__fish_expand_pid_args $argv)
  end
end

# Add kill alias if os is Cygwin or Msys.
set -l os (/usr/bin/uname -o)
if string match -q 'CYGWIN*' -- $os
  or string match -iq Msys -- $os
  alias kill.exe="kill"
end

set -e os
