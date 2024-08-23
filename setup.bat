@echo off

echo This setup script will clone the shared repository if it doesn't exist to the parent folder, and junction it to .\shared. Please make sure your project is in your Godot projects folder.

pause

IF NOT EXIST "..\shared\" (
  echo Cloning shared repository to ..\shared ...
  git clone git@github.com:PelicanAndValley/shared.git ..\shared
) ELSE (
  echo Shared repository found.
)

IF NOT EXIST ".\shared" (
  echo Creating junction to .\shared ...
  .\junction.exe .\shared ..\shared
) ELSE (
  echo Local shared directory found.
)

echo Done.

pause