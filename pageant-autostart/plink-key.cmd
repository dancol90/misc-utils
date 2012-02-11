@echo off

:: ----------------------------------------------------------------
::  PAGEANT STARTER FOR GIT
:: ----------------------------------------------------------------
::  Author: Daniele Colanardi (dancol90@gmail.com)
::  Date:   08/02/2012
:: ----------------------------------------------------------------
::  Use this script instead of plink in GIT_SSH env variable to
::  start pageant with right keys and enter rsa-key password once.
:: ----------------------------------------------------------------


:: Git uses this arguments:
:: -batch git@github.com "git-receive-pack 'dancol90/git-test.git'" 
:: so we have hostname in %2 (2nd parameter).
:: 
:: In file keys\host.conf there are host-key_file association.

:: Determine useful locations
set _bin_dir=%~dp0
set _keys_dir=%_bin_dir%\keys
set _host_file=%_keys_dir%\host.conf
set _pageant=%_bin_dir%\pageant
set _plink=%_bin_dir%\plink

:: Command to get info about pageant process
set _tasklist=tasklist /v /nh /fo CSV /fi "imagename eq pageant.exe"

:: When running, pageant.exe have this WindowTitle.
:: When asking for a password, it has "Pageant: insert passphrase"
set _title="Pageant"

:: Scan each line of host.conf file (excluding comments, that start with #)
:: note the space after =>: it's part of delims option, and trim off spaces
:: from tokens
for /f "tokens=1-2 eol=# delims==> " %%a in (%_host_file%) do (
    rem if the first token (host value) equals the given hostname for ssh,
    rem we found what we needed, save the corresponding key filename
    if "-%2-"=="-%%a-" set _key=%%b
)

:: Start pageant with right key only if we have found one.
:: In other words, if ssh hostname in %2 are not present in
:: host.conf file, don't start pageant.
if not [%_key%]==[] (
    start %_pageant% %_keys_dir%\%_key%
)

:: Wait until the user enters the password in pageant gui
:wait_password

:: Parse tasklist output
for /f "tokens=9 delims=," %%a in ('%_tasklist%') do set _title=%%a

:: Check WindowTitle
if [%_title%]==["Pageant"] goto pageant_ready

:: We are not ready, loop
goto wait_password

:: We get here when user had entered the password
:pageant_ready

%_plink% %*