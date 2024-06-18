# VS2-SKY-WHALE

[Valkyrien Skies 2](https://modrinth.com/mod/valkyrien-skies) is a Minecraft Mod that turns minecraft structures into physics objects. With it are an army of [addons](https://wiki.valkyrienskies.org/wiki/List_of_addons) that add stuff to make them fly. Coupled with [ComputerCraft](https://modrinth.com/mod/cc-tweaked) we can achieve omnidirectional flight. 

Visit their discord: ([VS2](https://discord.gg/aWeNDCUTS6), [CC](https://discord.gg/dRTtrdK)) to find out more.

## LOADING INTO THE DEMO MAPS
1. Download and install the following maps:
   
   [DOWNLOAD_LINKS_HERE]

2. Initialize Leviathan Drones
   
    Once you load in to the world, you should have two Computercraft:Pocket Computers in your hotbar. The one with ID:0 is your controller and the other one with ID:1 is your debugger. Run `debugger_leviathan.lua` on the debugger and press 't' on your keyboard to (re)initialize the drones.

   ![2024-06-18_10 32 19](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/1a546294-1d01-4d08-86a6-02f1ad590003)


   ![2024-06-18_10 33 54](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/1270e333-9bbd-4672-ac33-63d04efa06d9)

   
   ![2024-06-18_10 36 42](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/13008e87-d190-46aa-8998-305fb85e2eb6)

3. Unpause Head-Drone (TRACER)

   On your controller pocket computer run `swarm_controller.lua`. The swarm controller UI should appear. You can configure each of the drones by clicking on one of their IDs on the list on the left side of the screen. The list is arranged from top to bottom starting with the head-drone (Drone ID:16).

  ![2024-06-18_10 36 54](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/f1fd1735-6444-4f88-8a8a-6de9ad23b583)

   All drones are paused by default. We need to set them to `RUN` to get them to move.

   Unpause the head-drone first. Click on it's Drone ID and toggle the `PAUSE` button. The head-drone should start positioning itself to the starting position.

   ![image](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/ce1eb8f7-fa79-495f-ab03-be6fb0bd20c6)

   ![2024-06-18_21 27 07](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/63861208-a9b3-44c1-8bef-ee0d5b08ef8d)

   ![2024-06-18_21 29 17](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/eeac140c-be0c-4d48-8d22-d0dc669c6875)

4. Unpause Segment-Drone (SEGMENT)

   Next we need to unpause the segment-drones. We can go thru the list one by one to unpause them all but we can configure them all at once from the `ALL` tab. Click the `ALL` button on the top left to bring up the Swarm Controls. 

   ![image](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/391d827e-6cf4-496d-bf04-0736845d41c6)
   
   ![2024-06-18_10 36 54](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/ae6c5b98-10f3-4472-8407-53ae1dda35c5)

   

   We can switch thru the different types of drones by clicking on the Drone-Type button. It's set to `TURRET`  when you first start the program. Set it to `SEGMENT` to configure all of our segment-drones.

   ![image](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/b8b2db83-6bfb-4ea9-a821-27efc39f570a)

   ![2024-06-18_21 32 35](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/e668b30d-736d-4206-9871-4e31a335240f)


   Toggle the `PAUSE` button to `RUN` and click on `Set Swarm` to send the new settings to our segment-drones.

   ![2024-06-18_21 34 54](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/0a67768f-9d86-4418-b093-ae998fd0df69)

   ![image](https://github.com/19PHOBOSS98/VS2-SKY-WHALES/assets/37253663/731a96ca-d079-4eaf-8ba1-5b22f1dbb31e)


   Segment-drones only move when the head-drone is "walking" 
   
5. Set Head-Drone To "Walk"

   In your swarm controller, click on the head-drone from the drone list (ID:16) and toggle `STOP` to `WALK` to get it to start "walking" the flight path.
   The segment-drones will start to fly into place one by one as the head-drone moves.

## HOW TO SETUP A CUSTOM LEVIATHAN DRONE SWARM

### Before Loading Into The World
* install the included resourcepacks
* install the included datapack
* install the included modpack
* add the included nbt schematic files (`VS2-SKY-WHALES\DRONE_STRUCTURE_SCHEMATICS\SCHEMATICS`,`VS2-SKY-WHALES/MIRAGE/STRUCTURE_FILES/...`) to your game's `schematics` folder
* add the included V-Mod schematics (`VS2-SKY-WHALES\DRONE_STRUCTURE_SCHEMATICS\VMOD_SCHEMATICS`) to your game's `VMod-Schematics` folder
* In `SAVE_FOLDER/serverconfig/some_peripherals-SERVER.toml` file, configure `SomePeripheralsConfig.RadarSettings>max_entity_search_radius & max_ship_search_radius` both to 500
(* Incase of having too many active drones, in `SAVE_FOLDER/serverconfig/computercraft-server.toml` file, increment `computer_threads` to a higher value)

### After Loading Into The World
 1. Ready two ComputerCraft:Pocket-Computers to use as your Swarm Controller and Debugger tablets
 2. Ready at least two different ComputerCraft:Turtles with Ender Modems. These will be our drone pilots
      Each new CC:Turtle you put down has a unique Computer-ID. This points the turtle to a folder: `WORLD_SAVE/computercraft/computer/[COMPUTER_ID_HERE]` where all it's Lua scripts are saved.
      
      We need atleast 1 to act as our head-drone and another one as our segment-drone.   
      
      In Creative, you can copy-paste a CC:Turtle (CTRL+SHIFT+MIDDLE-CLICK on block) to have multiple Turtles in the world with the same Computer-ID.
      Each of those Turtles would be pointing to the same Computer Folder. This makes it easier to setup new drones without copy pasting more code.
      However, you can't typically copy-paste like this in Survival. In that case you need to copy-paste the code to new computer-folders each time you add a new drone to the world.
    
 3. Copy the Swarm Controller Code to your Swarm Controller's computer-folder
 4. Copy the Debugger Code to your Debugger's computer-folder
 5. Copy the drone Code from the `HEAD` folder to your head-drone's computer-folder
 6. Copy the drone Code from the `BODY` folder to your segment-drones' computer-folder

      Again, you need to copy it to different folders if you're in survival
 
 7. In-game, build the Omni-Drones (formerly known as Tilt-Ships) using the provided structure files

      Make sure to not rotate the structure and build it as it is.
      
      You can use Create:Schematics to spawn the structure in and turn them into ships using Valkyrien Skies 2 Eureka:Helms or any of the VS2 addons.
      
      Make sure the blocks are not touching anything else when you apply physics to the structure.
      
      Swap out the glass block in the middle with your CC:Turtle. Make sure, the side with the Ender Modem is not touching any of the two Redstone Integrators.
      
      You can also use V-Mod to spawn them in as VS2-ships directly. Note that saving a VS-ship with CC:Turtles using V-Mod also copies their Computer-IDs.
      That means you can spawn multiple drones with the same computer-ID. I've included VS-Ship-Schematics of both my head and segment drones with their onboard Turtles.
      You can use those, tho you might need to switch the Turtles out with new ones and save them as new schematics first before you spawn more in.
    
 8. Boot-up the drones

     There's a script that should automatically start the firmware when the Turtle turns on. Turning the Turtle off and on again should (re)start the script.
     They should start hovering in place.

     The drones should automatically start right when you spawn them in using V-Mod. 
      
 9. Setup the drone ID list

     Each drone has a unique ship-ID. You can view this by right-clicking on their turtles when they start-up for the first time.
     Take note of each of your drone's ID.

     We need to edit the following Lua scripts and set each of their `DRONE_IDs` list:
        * Swarm Controller Tablet > `swarm_controller.lua`
        * Debugger Tablet > `debugger_leviathan.lua`
        * Head Drone > `firmwareScript.lua`
 
 10. Set Flight Path

     The head-drone is a `PathTracerDrone`. You give it a set of waypoints and it will trace it in the sky. Go to your head-drone's `firmwareScript.lua` file and edit the `WAYPOINTS` variable. It needs atleast 4 points to start moving.
     Keep in mind that these coordinates need to be in world space. You can use my [Pathing Library](https://github.com/19PHOBOSS98/Lua-Computercraft-Spline-Path-Library/tree/main) to generate Smooth Curving paths, just make sure to `offset` them to the right world coordinates before flying your drones.
      
 11. Set SEGMENT_DELAY

      Each of the drones are set to follow each other on a set distance. Edit the `debugger_leviathan.lua` script and set the `SEGMENT_DELAY` variable to adjust the gap between the drones.

 12. Run Debugger

      In your Debugger tablet run `debugger_leviathan.lua` and press the `t` key to (re)initialize the leviathan drones with their proper settings (debugger_leviathan.lua > `SEGMENT_DELAY`)
     
 13. Run Swarm Controller

     In your Swarm Controller tablet run `swarm_controller.lua`. The swarm controller UI should appear.

     You can configure each of the drones individually by clicking on one of their IDs on the list on the left side of the screen.

     You can configure multiple drones of the same tpye all at once by clicking on `ALL`.
     We can switch thru the different types of drones by clicking on the Drone-Type button. It should be set to `TURRET` when you first start the program. On text (String) inputs don't forget to press `Enter` to lock in the new setting.
     
     When you're done with the changes, click on `SetSwarm` to send the new settings to the drones.

 14. Unpause Head-Drone

      In your Swarm Controller, click on your head drone's ID and Unpause it by toggling the `PAUSE` button to `RUN`. The head-drone should start positioning itself to the starting position.
      
 15. Unpause Segment-Drones

      In your Swarm Controller, click on `ALL` and switch drone-type to `SEGMENT`. Toggle the `PAUSE` button to `RUN` and click on `SetSwarm` to send the new settings to our segment-drones. The segment-drones should start moving when the head-drone starts "walking" 
      
 16.  Set Head-Drone To "Walk"

      In your Swarm Controller, click on your head drone's ID and toggle the `STOP` button to `WALK`. The head-drone should start "walking" thru the list of coordinates we've set. Toggle the button to `STOP` to... stop

 17. Set Custom Skin

     The drones have onboard Mirage Projectors from a small mod I made called [Mirage](https://youtu.be/LpBEGNvNQbg). Follow this [video guide](https://youtu.be/XtJSwktTuuw?si=8fTOF-V3WfaLQDtH) to learn how to use it.
     I've included my skins in the github repo. Copy the text files you like from `VS2-SKY-WHALES/MIRAGE/STRUCTURE_FILES/...` into a book&quill in-game and right click on the onboard Mirage Projector to set it. With the nbt files properly added, It should start projecting the skin.

### Misc Drone Settings

For this particular setup, I've rigged the drones to output redstone signals depending on how far up they are.
I used [RFTools](https://modrinth.com/mod/rftools-utility) Wireless redstone transmitters and receivers to feed the signals to an onboard Mirage Projector.

This is how the Cloth Whale changes skin when it ducks under the clouds:

In your drone's `firmwareScript.lua` file, set the `ALTITUDE_THRESHOLD` variable to the desired block height you want it to start outputting redstone.

If the ship passes it going down it should send a redstone pulse from the Turtle's back, if it passes it going up, the Turtle outputs a redstone pulse from the front.


