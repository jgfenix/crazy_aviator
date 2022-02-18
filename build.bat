@echo off
::::::::::::::::::::::::::::::::::::::::
SET LUA_VERSION=11.4
SET LUA_FILE=main.lua
SET AIRPLANE_FILE=airplane.lua
SET METEOR_FILE=meteor.lua
SET LUA_CONF_FILE=conf.lua
SET GAME_NAME=crazy_aviator
SET WIN_EXECUTABLE_GAME=%GAME_NAME%.exe
SET ZIP_GAME=%GAME_NAME%.zip
SET TMP_DIR=%CD%\tmp_dir\
SET _64BITS_DIR=win64
SET _32BITS_DIR=win32
SET TOP_DIR=%CD%
::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::
::Windows 64b
CD %TOP_DIR%
SET WIN_BIN_DIR=exe\%_64BITS_DIR%\%GAME_NAME%\
ECHO Building %_64BITS_DIR%...
RMDIR /s %WIN_BIN_DIR%
RMDIR /s %TMP_DIR%

MKDIR %TMP_DIR%
MKDIR %CD%\exe\%_64BITS_DIR%\%GAME_NAME%

XCOPY images %TMP_DIR%\images\
XCOPY sounds %TMP_DIR%\sounds\
COPY %LUA_FILE% %TMP_DIR%
COPY %AIRPLANE_FILE% %TMP_DIR%
COPY %METEOR_FILE% %TMP_DIR%
COPY %LUA_CONF_FILE% %TMP_DIR%

del /f %ZIP_GAME%
CD %TMP_DIR%
powershell -ExecutionPolicy unrestricted -Command "Compress-Archive -Path *  -DestinationPath %ZIP_GAME%"
CD ..

COPY /b ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\love.exe+%TMP_DIR%%ZIP_GAME% %WIN_BIN_DIR%%WIN_EXECUTABLE_GAME%

COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\love.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\lua51.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\mpg123.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\OpenAL32.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\SDL2.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\msvcr120.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\msvcp120.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_64BITS_DIR%\license.txt %WIN_BIN_DIR%

CD %WIN_BIN_DIR%
powershell -ExecutionPolicy unrestricted -Command "Compress-Archive -Path *  -DestinationPath %GAME_NAME%"
CD -
::::::::::::::::::::::::::::::::::::::::
::Windows 32b
CD %TOP_DIR%
SET WIN_BIN_DIR=exe\%_32BITS_DIR%\%GAME_NAME%\
ECHO Building %_32BITS_DIR%...
RMDIR /s %WIN_BIN_DIR%
RMDIR /s %TMP_DIR%

MKDIR %TMP_DIR%
MKDIR %CD%\exe\%_32BITS_DIR%\%GAME_NAME%

XCOPY images %TMP_DIR%\images\
XCOPY sounds %TMP_DIR%\sounds\
COPY %LUA_FILE% %TMP_DIR%
COPY %AIRPLANE_FILE% %TMP_DIR%
COPY %METEOR_FILE% %TMP_DIR%
COPY %LUA_CONF_FILE% %TMP_DIR%

del /f %ZIP_GAME%
CD %TMP_DIR%
powershell -ExecutionPolicy unrestricted -Command "Compress-Archive -Path *  -DestinationPath %ZIP_GAME%"
CD ..

COPY /b ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\love.exe+%TMP_DIR%%ZIP_GAME% %WIN_BIN_DIR%%WIN_EXECUTABLE_GAME%

COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\love.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\lua51.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\mpg123.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\OpenAL32.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\SDL2.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\msvcr120.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\msvcp120.dll %WIN_BIN_DIR%
COPY ..\love\love-%LUA_VERSION%-%_32BITS_DIR%\license.txt %WIN_BIN_DIR%

CD %WIN_BIN_DIR%
powershell -ExecutionPolicy unrestricted -Command "Compress-Archive -Path *  -DestinationPath %GAME_NAME%"
CD -