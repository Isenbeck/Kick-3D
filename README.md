# Kick-3D
Commodore 64 3D engine

I have made a small C64 program to see if I can make a 3D engine, just for fun. And I have never had an intention to build the full game engine. 
But, since I already have something that is, I believe, usable, I would like for somebody to use it.

The project is written in the C64Studio software (https://www.c64-wiki.com/wiki/C64_Studio).

## Open the project
Start the C64Studio, select `File > Open > Solution or project...`
Browse until you find the "kick3d.s64" file and open it.

## Build and run
Select the "kick3d.asm" tab in the C64Studio and then select `Build > Build and Run` from the menu.

If you have the VICE emulator set up to run by the C64Studio, the program will compile and run in the emulator.

## About the software
### kick3d.asm
This module is used as a manager module through which the program is assembled.

### main.asm
This module contains the main program loop, setup, and some global routines.

### math.asm
This module contains mathematical functions. And only three mathematical functions are used in this program: sine, cosine, and multiplication. 

### user.asm
This module contains routines used to control the interaction with the user and control player actions.
There are joystick control routines, keyboard control routines, and player map events control.

### display.asm
This module contains routines for graphics display. 

### sprites.asm

### raycast.asm

### rayscan.asm

### interrupts.asm

### resources.asm

### tables.asm
