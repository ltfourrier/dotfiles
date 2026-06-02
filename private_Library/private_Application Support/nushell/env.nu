# env.nu
#
# Installed by:
# version = "0.112.2"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

$env.EDITOR = 'hx'

$env.PATH = ($env.PATH
  | prepend "/usr/local/opt/ruby/bin"
  | prepend "/usr/local/lib/ruby/gems/3.1.0/bin"
  | prepend "/usr/local/bin"
  | prepend "/usr/local/sbin"
  | append "/Users/laurent.fourrier/.local/bin")
