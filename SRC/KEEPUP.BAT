@echo off
cls
timer
neuro %1 %2 %3
if errorlevel 4 goto exit
if errorlevel 3 door
if errorlevel 2 startup
keepup
:exit
@echo on
