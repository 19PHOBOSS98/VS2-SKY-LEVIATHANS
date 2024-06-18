# VS2-SKY-WHALE

## LOADING INTO THE DEMO MAPS
1. Download and install the following maps:
2. Initialize Leviathan Drones
   
    Once you load in to the world, you should have two Computercraft:Pocket Computers in your hotbar. The one with ID:0 is your controller and the other one with ID:1 is your debugger.
    Run `debugger_leviathan.lua` on the debugger and press 't' on your keyboard to (re)initialize the drones.
   
4. Unpause Head-Drone (TRACER)

   On your controller pocket computer run `swarm_controller.lua`. The swarm controller UI should appear. You can configure each of the drone by clicking on one of their IDs on the list on the left side of the screen. The list is arranged from top to bottom starting with the head-drone (Drone ID:16).

   All drones are paused by default. We need to set them to `RUN` to get them to move.

   Unpause the head-drone first. Click on it's Drone ID and toggle the `PAUSE` button. The head-drone should start positioning itself to the starting position.

   
5. Unpause Segment Drone (SEGMENT)

   Next we need to unpause the segment-drones. We can go thru the list one by one to unpause them all but we can configure them all at once from the `ALL` tab.

   Click the `ALL` button on the top left to bring up the Swarm Controls. We can switch thru the different types of drones by clicking on the Drone-Type button. It's set to `TURRET` by default. Set it to `SEGMENT` to configure all of our segment-drones.

   Toggle the `PAUSE` button to `RUN` and click on `SetSwarm` to send the new settings to our segment-drones.

   Segment-drones only move when the head-drone is "walking" 
   
7. Set Head-Drone To "Walk"

   In your swarm controller, click on the head-drone from the drone list (ID:16) and toggle `STOP` to `WALK` to get it to start "walking" the flight path.
   The segment-drones will start to fly into place one by one as the head-drone moves.

## HOW TO SETUP A CUSTOM LEVIATHAN DRONE SWARM

### Before Loading Into The World
* install the included resourcepacks
* install the included datapack
* install the included modpack
* In `SAVE_FOLDER/serverconfig/some_peripherals-SERVER.toml` file, configure `SomePeripheralsConfig.RadarSettings>max_entity_search_radius & max_ship_search_radius` both to 500
(* Incase of having too many active drones, in `SAVE_FOLDER/serverconfig/computercraft-server.toml` file, increment `computer_threads` to a higher value)

### After Loading Into The World
 1. Ready two ComputerCraft:Pocket-Computers to use as your Swarm Controller and Debugger tablets.
 2. Ready ComputerCraft:Turtles with Ender Modems. These will be our drone pilots.
    Each new CC:Turtle you put down has a unique Computer-ID. This points the turtle to a folder: `WORLD_SAVE/computercraft/computer/[COMPUTER_ID_HERE]` where all it's Lua scripts are saved

    In Creative, you can copy-paste a CC:Turtle (CTRL+SHIFT+MIDDLE-CLICK on block) to have multiple Turtles with the same Computer-ID. Each of those Turtles would be pointing to the same Computer Folder. This makes it easier to setup new drones without copy pasting more code. However, you can't typically copy-paste like this in Survival. In that case you need to copy-paste the code to new `computer` folders each time you add a new drone to the world.
    
 4. 
 5. 


### Setting Lua Scripts
   In-game, grab yourself .
   

### Spawning Drones

### Configure Drone Settings



VIDEO_HERE


