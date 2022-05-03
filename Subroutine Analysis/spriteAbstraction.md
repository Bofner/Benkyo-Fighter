# Sprite Drawing Analysis
The subroutine for drawing sprites to the screen works in tandem with the specific structure of each sprite object that will be displayed on screen. The Sega Master System can only draw sprites in 8x8 or 8x16 size pieces. This subroutine works only for 8x16 sprites, but it can be used to draw a object of up to 15x15 sprites (of size 8x16). I refer to these large sprite objects as sprite OBJs.

All sprite OBJs have the same basic structure that can be added onto, but the order of the base structure cannot be altered for the subroutine to work. Below is the basic structure for all sprite OBJs. The Mongoose sprite was the first sprite OBJ that was designed using this subroutine, and consists of only the necessary data to have it be drawn to the screen. Brief descriptions of each byte or word of data follow their declaration. 

.struct mongoose

    hitAdr      dw      ;The address where hit-detection subroutine for that specific OBJ type is
    sprNum      db      ;The draw-number of the sprite      
    hw          db      ;The height and width of the entire OBJ
    y           db      ;The Y coord of the OBJ
    x           db      ;The X coord of the OBJ
    cc          db      ;The first character code for the OBJ 
    sprSize     db      ;The total area of the OBJ
    
.endst

;Other bytes of data may be added before hitAdr, or after SprSize, but not between

;any of the data bytes labeled above, as this will mess with the pointer

Any sprite OBJ that needs to be drawn using this subroutine MUST follow this structure. In addition to having this structure, there are a couple of parameters that must be set before calling the subroutine. The following is the main description for this subroutine:

Updates any sprite-OBJect. DE is our pointer, and HL is used for
updating the properties of the sprite
Parameters: DE = spriteOBJ.sprNum
Affects: DE, A, BC

The 16-bit register DE must be set to the spriteOBJ.sprNum, which can simply be done by the following assembly code:

ld de, mongoose.sprNum
call MultiUpdateSATBuff

Note that register DE contains the ADDRESS for our mongoose.sprNum, and not the actual value of mongoose.sprNum.

The whole subroutine works by using DE as a pointer. Since we are using a register, we don't have to worry about specific values assosciated with a single sprite OBJ. This means that so long as the sprite OBJ follows the structure given above, then any sprite OBJ can be drawn using this subroutine. 

The Sprite Drawing subroutine is broken down into different segments. Let's take a walk through each one. 

### MultiUpdateSATBuff
This section is the beginning of the subroutine. This is what gets called whenever a sprite OBJ needs to be drawn to the screen. This sets up everything that needs to be set up in order to draw a sprite OBJ to the screen. There are a couple of global constants and variables called that should be discussed. 

The first is in the title of the section, the **SATBuff**. The **SATBuff** is the Sprite Attribute Table Buffer. This is a portion of memory that acts as a buffer for the Sprite Attribute Table. It exists so that writes to the SAT won't happen while graphics are displayed on screen.

Just behind the **SATBuff** in memory is the **SOAL**, or Sprite Object Address List. The **SOAL** is a list of 16-bit addressses of the collision subroutines for all sprites currently on screen. It gets updated every frame as sprites in the SAT get updated. While it does not exist in the video RAM, it is in effect an extension of the **SATBuff**.  

Finally we have **sprUpdCnt**. **sprUpdCnt** is a global variable that keeps track of how many sprites have been updated while the Sprite Draw subroutine has been running. This is so that we can properly keep track of what sprite number our sprite OBJ should correspond to. The Sega Master System can only display up to 64 sprites on screen at a time, so this number should never go above this limit. In addition, the SMS can only display 8 sprites at a time on a single scanline, so sprite OBJs will realistically never be more than 8 sprites wide. 

Each section is further subdivided into small tasks just by comments the precede the code. Take the following code snippet for example:

    push hl                     ;Preserving HL
    ;Determine Sprite Number
        ld a, (sprUpdCnt)
        ld (de), a
    ;Writing the hit detection address to the SOAL
        dec de                  ;ld de, OBJ.adrL
        dec de                  ;ld de, OBJ.adrH
        ...
        
This section does 4 main things: 

1. Determines the sprit OBJ's sprite number
2. Updates the SOAL with the proper collision subroutine address
3. Determines the height of our sprite OBJ
4. Determines the width of our sprite OBJ

In order to save space, the width and height are saved in the save byte, OBJ.hw. Heigh and width are saved in a nibble, so a bitmask is used to get the dimensions. This is where our 15x15 limit comes into places, but again, we wouldn't ever want a sprite OBJ to be wider than 8 sprites anyway, so in terms of width, this is more than enough. A 15 sprite tall sprite OBJ would take up more than half of the viewable screen, so it is very unlikely that we would ever need to draw something so tall, but if we were, this would be one setback for this subroutine. 

The height is saved in the B register, and the width in the C register.

For a closer look at how this section works, please refer to the either the source code, or the spriteAbstraction.asm file. The subroutine is well commented and should be able to provide most any answer to your questions. 

### MUSBWidthReset
Now we start to get into the real inner workings. But first, we must introduce another 3 variables. That is **sprYOff** or the Sprite Y Offset. This is used to determine where the next sprite should be drawn vertically. **sprXOff** is similar, but determines the offset for where the sprite should be drawn horizontally. **sprCCOff** is used to determine which Character Code should be used for our sprite. 

This section acts as a width reset. The way that a sprite OBJ is drawn to the screen is similar to how the viewable screen is drawn by the console. It starts drawing one sprite at a time from left to right. Once it has drawn as many sprites across as is indicated by OBJ.hw. This value is stored in the C register at all times during this subroutine, and is decremented each time a sprite is drawn. When this number reaches zero, this section of the subroutine restores the original width so that we can continue along for another row. 

Once the width has been reset, **sprYOff** must be updated. A value of $10 (16 decimal) is added, since this subroutine works for 8x16 sprites. If we were to work with 8x8 sprites, then this number should be altered to be $08 (8 decimal). 

The **sprXOff** is then reset to 0, since our subroutine will begin drawing from the far left again. 

Next the **sprCCOff** is adjusted. A value of $02 is added because this subroutine uses 8x16 sprites, and whenever a new character needs to be used, the value in video RAM must be incremented by 2. 

### MUSBLoop
Here we have the main loop for our subroutine. This is called every time we need to draw a new sprite, so long as we are not resetting the width. This section is pretty straightforward. It first decrements the width value stored in the C register as explained in the section above. It then adjusts the **sprXOff**, increasing the value by $08 in order to put the next sprite right up next to the previous. Similarly, it updates the **sprCCOff** in order to point to the next character in the VRAM. 

The next couple of tasks are a little complicated at first glance, but are actually doing something very simple. 

Next the subroutine calculates the Y coordinate for the sprite it is working on. 

Following the Y coordinate is the X coordinate. Which is followed by the Character Code. The reason the subroutine goes from Y to X to CC is because that is the order in which the SAT is written in VRAM, so it makes the most sense to write out the data in the same order. 

Once that has been done, all information necessary for drawing the sprite has been communicated. The next task adds 1 to the value of OBJ.sprSize. To calculate the area of the sprite OBJ, (OBJ.sprSize) would be a tad bit costly since we would need to run a multiplication subroutine. So instead of doing that, the area is simply calculated by adding 1 to the OBJ.sprSize as each sprite is drawn to the screen. 

The subroutine then checks how many more sprites we have left to draw in our row. If there are more than one, then we loop back to the beginning of this section. If there aren't, then we check to see if we have any more left to draw vertically. This is done in a special way. Since our height is stored in the B register, we implement the following code:

;If we have finished a row
;Reset our *pointer

    dec de                      ;ld de, OBJ.cc
    dec de                      ;ld de, OBJ.x
    dec de                      ;ld de, OBJ.y
    dec de                      ;ld de, OBJ.hw
    djnz MUSBWidthReset         ;If our Height != 0, then we keep drawing
    
The djnz is a special opcode that decrements the value in the B register, and then checks if it is zero. If it is, then it continues to the next line of code. If not, then it jumps to a specified label. In this instance, we have it go back to reset our width. If B ends up being zero, then we have finished drawing our sprite OBJ!

The final thing that this subroutine does is set the sprite terminator in the **SATBuff**. This is a special predetermined value that indicates to the hardware to stop drawing sprites. This is done after every call of the subroutine so that we don't have to call a sprite terminator function elsewhere in our program. If we want to draw another sprite, this data just gets overwritten. This write only takes 61 T-states, so it isn't terribly expensive. 

Finally the subroutine resets **sprYOff**, **sprXOff** and **sprCCOff** so that they are ready for the next sprite OBJ to be drawn. 

I spent a lot of time commenting this subroutine so that it would readable not only to myself in the future, but hopefully others as well, so feel free to dig around in the source code or the spriteAbstraction.asm file. 
