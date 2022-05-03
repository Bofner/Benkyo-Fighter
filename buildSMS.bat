 @echo off
 cls

 ..\WLA-DX_Binaries\wla-z80 -o main.asm main.o

 echo [objects] > linkfile
 echo main.o >> linkfile

 ..\WLA-DX_Binaries\wlalink -drvs linkfile output.sms
 
 
REM specific to my computer/github repository
 java -jar ..\..\Emulicious-with-Java\Emulicious.jar output.sms
 
 del linkfile
 del main.o
 ::output.sms