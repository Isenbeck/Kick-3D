# Kick-3D
Commodore 64 3D engine demo

I have made a small C64 program to see if I can make a 3D engine, just for fun. I never had an intention to build the full game engine or a game. 
But, since I already have something that is usable, I would like for somebody to use it.

The graphics display has 80x50 pixels resolution, but the program in fact uses PETscii graphics.

The program starts in the 2D view mode.
To switch to the 3D and back to the 2D view mode press the `S` button.

Player can strife left and right by using `Q` and `W` buttons. Otherwise, use the joystick to control the player.
On the map, you can see two map events called A and B. The event A will paint the part of the wall to indicate that there is a hidden door. If you press the joystick button, the wall will open. The event B is example of "open the door" event, or beter to say "open the wall."

The project is written in the C64Studio software (https://www.c64-wiki.com/wiki/C64_Studio).

## Run the program
There is a precompiled version of the program "kick3d.prg" which you can run in your emulator or your C64 machine.

## Open the project
Start the C64Studio, select `File > Open > Solution or project...`
Browse until you find the "kick3d.s64" file and open it.

## Build and run
Select the "kick3d.asm" tab in the C64Studio and then select `Build > Build and Run` from the menu.

If you have the VICE emulator set up to run by the C64Studio, the program will compile and run in the emulator.

## About the code
The code could be faster than it is. Instead, I wrote the code to be as clean as possible. There are no self-modifying code sections. And I have commented on the code as best I could.

Software is broken into several modules.

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
Sprites control routines. For now, sprites are used in the 2D view and as background objects in the 3D view.

### raycast.asm
This is the ray casting routine. It casts a single ray and returns the cell the ray hits and distances.

### rayscan.asm
This routine casts 40 rays and stores calculations in the buffer, which is later used by the display module.
The engine was originally casting 80 rays, but that was too slow. So, I have created a system where every second ray is interpolated in between casted rays.

### interrupts.asm
Just a basic interrupt scanline routine to create the effect of sky and grass by splitting the background color into two parts.

### resources.asm
Sprites and maps information.

### tables.asm
Various tables such as sine table, and calculation speed up tables.
