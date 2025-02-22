{ ... }:
{
  home.file.".psqlrc".text = ''
    \set QUIET 1

    \pset linestyle unicode
    \pset border 2

    \set null [null]
    \set COMP_KEYWORD_CASE upper
    \set ON_ERROR_ROLLBACK interactive
    \set PROMPT1 '%[%033[1m%]%M/%/%R%[%033[0m%]%# '
    \set PROMPT2 ''''
    \set VERBOSITY verbose
    \timing
    \x auto

    \unset QUIET
    \conninfo
  '';
}
