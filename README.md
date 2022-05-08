# Thanks for checking out BENKYO FIGHTER! 
![](https://github.com/Bofner/Benkyo-Fighter/blob/main/Images/Title.png)

This is a project I'm working on as part of my final semester of my masters degree in computer science. Benkyo Fighter will be an arcade style free-roaming shoot-em-up game for the Sega Master System written entirely in z80 assembly. It will be released in chapter segments, with my Master's project being something of a test chapter for getting the engine up and running with only a few hints as to what the main story will be about.

This repository will act as a way to catalogue this project, and as soon as I figure out how I want to format things, it will also act as a tutorial of sorts (At least for chapter 0), outlining my process, and discussing the tools that I found to be most helpful in learning my first assmebly language, as well as creating assets and everything else involved in game design.

# Making your own Sega Master System Programs

If you want to learn z80 assembly, I recommend starting off with one of Texas Instruments 83 series calculators, like the TI-84+, as it uses the same z80 cpu as the Sega Master System, but has more resources for learning how to code. Specifically Sean McLaughlin's Learn TI-83 Plus Assembly In 28 Days (https://tutorials.eeems.ca/ASMin28Days/lesson/toc.html). It uses a different assembler though. I ended up using the assembler Brass (https://benryves.com/bin/brass/).

For getting assembly up and running on the Sega Master System, I recommend using the WLA-DX assembler. The following tutorial (https://www.smspower.org/maxim/HowToProgram/Lesson1AllOnOnePage) was how I got everything up and running initially, and it contains some already compiled binaries. If you want to compile them yourself though, you can get the files from https://github.com/vhelin/wla-dx

You'll need to use some sort of IDE for running your code. While the tutorial by Maxim suggests using Context, I find it to be a bit outdated and clunky. My IDE of choice is Visual Studio Code. Not only is it a little sleeker and easier on the eyes than Context, but it also has a lot of helpful user-created pluggins you can download that are made specifically for z80 assembly. The following are the ones that I found to be the most useful 

ASM Code Lens: https://marketplace.visualstudio.com/items?itemName=maziac.asm-code-lens 

WLA-DX for VS Code: https://marketplace.visualstudio.com/items?itemName=KrocCamen.wla-dx-vscode&utm_source=VSCode.pro&utm_campaign=AhmadAwais

Z80 Instruction Set: https://marketplace.visualstudio.com/items?itemName=maziac.z80-instruction-set

Z80 Macro Assembler: https://marketplace.visualstudio.com/items?itemName=mborik.z80-macroasm

Z80 Assembly: https://marketplace.visualstudio.com/items?itemName=Imanolea.z80-asm

Hex Editor: https://marketplace.visualstudio.com/items?itemName=ms-vscode.hexeditor

Not all of these are necessary, but I found them to all be incredibly useful. 

You'll also need to run an emulator in order to test your programs. I suggest Emulicious, as it has an incredible debugging feature that I could not have done without. (https://emulicious.net/). 

And in order to get your emulator working with VS Code, you'll need to create a task. I've supplied the task.json file that I use for compiling my code, and it includes a a task for the TI-83 Calculator, as well as a Gameboy Color task that uses a different assembler all together called RGBDS. All we need to worry about is the SMS task. The task relies on the buildSMS.bat file, which I've also supplied in this repository. Your path may be different from mine, so it may need some adjustment. 

With all of that set up, you should (at the very least) be able to open up my source code in VS Code and get the game running using the task (so long as you've configured the path correctly). There is of course a lot to learn about the z80 assembly language if you want to make your own program, but I cannot go into the nitty gritty right now. 

However, I think talking about the way that I approached some problems may be helpful, and may get you thinking in the way that the z80 cpu thinks. Perhaps you'll even be able to see flaws in my methodology (I'm by no means whatsoever an expert). I'll make this its own file though, because it may take up some space. 

# What did I accomplish in a semester?
Over the course of the semester working on this project, I wasn't able to do as much as I'd hoped, but I did manage to learn a lot, and here are some of the results of what I was able to accomplish throughout my time working!

### Strafing and 8-way Shooting!
![](https://github.com/Bofner/Benkyo-Fighter/blob/main/Images/strafing.gif)

The main idea behind Benkyo Fighter was to make a game where the player could move and fire in eight directions, so that was the core focus of the first half of my semester. Getting everything to work just as intended took a lot of time, but the end result felt really good to me! Note: This GIF was recorded using a Sega Genesis Model 2 for video quality purposes, but it will run on real SMS hardware as well. 

### Hit Detection
![](https://github.com/Bofner/Benkyo-Fighter/blob/main/Images/hit%20detection.gif)

Obviously 8-way shooting doesn't mean much if there isn't anything to hit! Sadly, I my hit-detection algorithm is not perfect, and currently doesn't run on real hardware, so this GIF was made in emulator. 

### Big Sprite Animations!
![](https://github.com/Bofner/Benkyo-Fighter/blob/main/Images/carrier.gif)

I spent a good bit of time working on the design and animation of the Carrier and eyeball. The idea was to have this guy spawn enemies in for the player to fight. Unfortunately I wrote the code for his movement and spawning before I'd come up with a solid sprite drawing foundation, so he doesn't work with the current implementation of the game. But I put a lot of effort into making him, so I at least wanted to show him off. Again, This GIF was recorded using a Sega Genesis Model 2 for video quality purposes, but it will run on real SMS hardware as well. 

# Updates
As of 05/08/2022 I'm putting Benkyo Fighter on hold. It's a very large project, and too ambitious for my current skill set. A lot of the code that I wrote for the player character, carrier boss, enemy and hit detection work, but don't work well together, or are just poorly implemented. I've decided to take on smaller projects for the time being, until I feel I have the proper skill set and knowledge about the Master System to come back to Benkyo Fighter. This game is something that I truly want to see through. I can see just how much work it will be though, and I want to be more prepared before tackling something of this magnitude. I'll keep updating my github with my new projects as they come, most of which will be Sega Master System games, so keep an eye out for that! 

Until then, feel free to reach out to me with any questions at a.bofner@gmail.com

Thanks!


