--ID 16
local PathTracerDrone = require "lib.tilt_ships.PathTracerDrone"
local Path = require "lib.paths.Path"
local path_utilities = require "lib.path_utilities"

local ALTITUDE_THRESHOLD = 240

local DRONE_IDs = {
	"16",
	"29",
	"37",
	"30",
	"31",
	"32",
	"33",
	"34",
	"35",
	"36",
}
--[[REMEMBER THESE ARE IN WORLD COORDINATES]]--
local WAYPOINTS = {
	{pos = vector.new(67,179,-227)},
	{pos = vector.new(81,179,-225)},
	{pos = vector.new(99,178,-221)},
	{pos = vector.new(93,189,-211)},
	{pos = vector.new(85,201,-196)},
	{pos = vector.new(84,214,-175)},
	{pos = vector.new(84,232,-154)},
	{pos = vector.new(83,223,-130)},
	{pos = vector.new(90,210,-94)},
	{pos = vector.new(126,242,-93)},
	{pos = vector.new(133,242,-85)},
	{pos = vector.new(87,184,-67)}, -- entry
	{pos = vector.new(61,146,-71)},
	{pos = vector.new(42,144,-46)},
	{pos = vector.new(69,140,-45)},
	{pos = vector.new(90,145,-67)},
	{pos = vector.new(100,138,-86)},
	{pos = vector.new(89,140,-85)},

	{pos = vector.new(56,140,-86)},

	{pos = vector.new(33,140,-68)},
	{pos = vector.new(52,154,-29)},

	{pos = vector.new(56,140,-58)},

	{pos = vector.new(72,158,-84)},

	{pos = vector.new(106,152,-81)},

	{pos = vector.new(85,150,-69)}, -- attack

	{pos = vector.new(107,157,-60)},

	{pos = vector.new(104,157,-47)},

	{pos = vector.new(86,156,-10)},
	{pos = vector.new(62,156,-7)},
	{pos = vector.new(37,149,-37)},
	{pos = vector.new(38,149,-75)},
	{pos = vector.new(82,151,-84)},

	{pos = vector.new(85,157,-64)}, -- up
	{pos = vector.new(88,171,-55)},
	{pos = vector.new(79,233,-60)},
}

--[[ generates Helix Path
local helix_path = path_utilities.generateHelix(50,0,1,30) --generates coordinate list of spiral
path_utilities.rotateCoordsByAxis(helix_path,vector.new(1,0,0),90) --rotates list of coordinates by axis
path_utilities.recenterStartToOrigin(helix_path) --recenters list of coordinates to start at (0,0,0)
path_utilities.offsetCoords(helix_path,vector.new(113,230,-44)) --moves list of coordinates
local waypoint_length = #WAYPOINTS
for i,coord in ipairs(helix_path) do --adds helix coordinates to end of WAYPOINTS
	WAYPOINTS[i+waypoint_length] = {pos = coord}
end]]--

local instance_configs = {
	radar_config = {
		designated_ship_id = "3",
		designated_player_name="PHO",
		ship_id_whitelist={},
		player_name_whitelist={},
	},
	ship_constants_config = {
		--DRONE_ID = 201,
		DRONE_ID = ship.getId(),
		THRUSTER_TIER = 5,
		THRUSTER_TABLE_DIRECTORY = "./input_thruster_table/thruster_table.json",
		PID_SETTINGS=
		{
			POS = {
				P = 0.7,
				I = 0.001,
				D = 1
			},
			ROT = {
				X = {
					P = 0.04,
					I = 0.001,
					D = 0.05
				},
				Y = {
					P = 0.04,
					I = 0.001,
					D = 0.05
				},
				Z = {
					P = 0.05,
					I = 0.001,
					D = 0.05
				}
			}
		},
	},
	channels_config = {
		DEBUG_TO_DRONE_CHANNEL = 9,
		DRONE_TO_DEBUG_CHANNEL = 10,
		
		REMOTE_TO_DRONE_CHANNEL = 7,
		DRONE_TO_REMOTE_CHANNEL = 8,
		
		DRONE_TO_COMPONENT_BROADCAST_CHANNEL = 800,
		COMPONENT_TO_DRONE_CHANNEL = 801,
		
		EXTERNAL_AIM_TARGETING_CHANNEL = 1009,
		EXTERNAL_ORBIT_TARGETING_CHANNEL = 1010,
		EXTERNAL_GOGGLE_PORT_CHANNEL = 1011,
		REPLY_DUMP_CHANNEL = 10000,
	},
	rc_variables = {
		
	},
	path_tracer_custom_config = {
		SPLINE_COORDS = {}
	},
}
spline_coords = {}

if (#WAYPOINTS>3) then
	local loop_path = true
	local ship_path = Path(WAYPOINTS,loop_path)
	spline_coords = ship_path:getNormalizedCoordsWithGradientsAndNormals(0.3,loop_path)
end

instance_configs.path_tracer_custom_config.SPLINE_COORDS = spline_coords
instance_configs.path_tracer_custom_config.STEP_SPEED = 0.03


local drone = PathTracerDrone(instance_configs)


local timer_delay = 0.1 --seconds

local count_down = timer_delay

local tick_rate = 0.05
local current_state = false
local prev_state = current_state

--switches HammerHead Mirage frame depending on ship altitude
function setMirageByAltitude(current_ship_altitude)
	local rs = false
	if(count_down > 0) then
		rs = true
	else
		rs = false
	end

	if(current_ship_altitude <= ALTITUDE_THRESHOLD) then
		redstone.setOutput("front",rs)
		redstone.setOutput("back",false)
		current_state = true
	else
		redstone.setOutput("front",false)
		redstone.setOutput("back",rs)
		current_state = false
	end

	count_down = math.max(count_down - tick_rate, 0)

	if(prev_state ~= current_state) then
		prev_state = current_state
		count_down = timer_delay
	end
end

local droneShipFrame = drone.ShipFrame

function transmit(cmd,args,drone_id)
	droneShipFrame.modem.transmit(droneShipFrame.com_channels.REMOTE_TO_DRONE_CHANNEL, droneShipFrame.com_channels.REPLY_DUMP_CHANNEL,
	{drone_id=drone_id,msg={cmd=cmd,args=args}})
end

function sendCurrentTargetSpatialsToSegments()
	local spatial = {position=droneShipFrame.ship_global_position,orientation=droneShipFrame.target_rotation}
	for i, id in ipairs(DRONE_IDs) do
		transmit("add_target_spatial",spatial,id)
	end
end

local prev_tracker_idx = 0
function drone:droneCustomFlightLoopBehavior()
	setMirageByAltitude(droneShipFrame.ship_global_position.y)
	
	local current_tracker_idx = self.tracker:getCurrentIndex()
	if(prev_tracker_idx ~= current_tracker_idx) then
		sendCurrentTargetSpatialsToSegments()
		prev_tracker_idx = current_tracker_idx
	end
end

drone:run()