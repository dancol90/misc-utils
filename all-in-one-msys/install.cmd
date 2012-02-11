@echo off

setlocal EnableDelayedExpansion

set _mingw_url=http://sourceforge.net/projects/mingw/files/Installer/mingw-get/mingw-get-0.4-alpha-1/mingw-get-0.4-mingw32-alpha-1-bin.zip/download
set _curl_url=http://gknw.itex.at/mirror/curl/win32/curl-7.19.4-devel-mingw32.zip
set _tcl_url=http://prdownloads.sourceforge.net/tcl/tcl8511-src.zip
set _tk_url=http://prdownloads.sourceforge.net/tcl/tk8511-src.zip

:: Per ora usiamo la cartella out, poi dovrà inserirlo l'utente
set _out_dir=%~dp0out
set _msys_dir=%_out_dir%\msys\1.0

echo Installation directory is %_out_dir%

::goto normalize-mingw

echo -----------------------------------------------------------

:make-dirs

echo Preparing working directories

if not exist tmp (
    echo    Creating temp folder
    mkdir tmp
)

if exist %_out_dir% (
    echo    Deleting existing %_out_dir%
    rd /S /Q %_out_dir%
)

echo    Creating %_out_dir%
mkdir %_out_dir%

echo -----------------------------------------------------------

:stage-1-mingw-get

echo Installing Mingw and MSys

echo    Downloading mingw-get
curl -o tmp\mingw-get.zip -L -# %_mingw_url%

echo    Unzipping mingw-get
unzip -o tmp\mingw-get.zip -d %_out_dir%

echo    Executing mingw-get
%_out_dir%\bin\mingw-get -verbose=0 install mingw msys g++ autoconf msys-console msys-openssl msys-openssh zlib expat msys-perl gettext msys-crypt msys-rxvt msys-libiconv


echo -----------------------------------------------------------

:normalize-mingw


echo Normalizing Mingw and MSys installations.

echo    Creating fstab file
echo %_out_dir:\=/% /mingw > %_msys_dir%\etc\fstab


echo    Checking for executables duplicates
for %%a in (cmd rvi vi) do (
    set _file=%_msys_dir%\bin\%%a


    if exist !_file! (
        if exist !_file!.exe (
            echo    Deleting useless !_file!.exe
            rm /F /Q !_file!.exe
        )
    )
)

for %%a in (ftp ln make awk echo egrep fgrep printf pwd ex rview rvim view) do (
    set _file=%_msys_dir%\bin\%%a
    
    if exist !_file! (
        if exist !_file!.exe (
            echo    Deleting useless !_file!
            rm /F /Q !_file!
        )
    )
)


echo    Renaming mingw's make to mingw32-make
set _file=%_out_dir%\bin\make.exe
if exist %_file% rename %_file% mingw32-make.exe

echo    Creating link to msys.bat
:: Consider using mklink instead of a bat file
echo ..\msys\1.0\msys.bat > %_out_dir%\bin\msys.cmd

echo -----------------------------------------------------------

echo Installing last version of cURL and libcurl

echo    Downloading cURL package for mingw
curl -o tmp\curl-mingw.zip -L -# %_curl_url%

echo    Extracting cURL 
unzip -o tmp\curl-mingw.zip */bin/ */include/ */lib/ -d %_out_dir%

echo -----------------------------------------------------------

echo Installing Tcl/Tk (git dependencies)

curl -o tmp\tcl.zip -L -# %_tcl_url%
curl -o tmp\tl.zip -L -# %_tk_url%

endlocal
pause