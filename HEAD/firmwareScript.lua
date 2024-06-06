--ID 16
local TenThrusterTemplateVerticalCompactSP = require "lib.tilt_ships.TenThrusterTemplateVerticalCompactSP"
local PathTracerDrone = require "lib.tilt_ships.PathTracerDrone"

local Path = require "lib.paths.Path"
local path_utilities = require "lib.path_utilities"

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

waypoints = {
	-- {pos = vector.new(85,201,-196)},
	-- {pos = vector.new(84,214,-175)},
	-- {pos = vector.new(84,232,-154)},
	-- {pos = vector.new(83,223,-130)},
	-- {pos = vector.new(90,210,-94)},
	-- {pos = vector.new(126,242,-93)},
	-- {pos = vector.new(133,242,-85)},
	-- {pos = vector.new(87,184,-67)},
	-- {pos = vector.new(61,146,-71)},
	-- {pos = vector.new(41,139,-39)},
	-- {pos = vector.new(69,137,-45)},
	-- {pos = vector.new(90,145,-67)},
	-- {pos = vector.new(100,138,-86)},
	-- {pos = vector.new(89,140,-85)},
	-- {pos = vector.new(56,140,-86)},

	-- {pos = vector.new(33,140,-68)},
	-- {pos = vector.new(52,154,-29)},

	-- {pos = vector.new(56,140,-58)},

	-- {pos = vector.new(72,158,-84)},

	-- {pos = vector.new(106,152,-81)},

	-- {pos = vector.new(85,145,-69)},
	-- --{pos = vector.new(85,170,-69)},

	-- {pos = vector.new(94,164,-44)},
	-- {pos = vector.new(68,156,-35)},
	-- {pos = vector.new(51,149,-50)},
	-- {pos = vector.new(56,149,-73)},
	-- {pos = vector.new(78,151,-75)},
	-- {pos = vector.new(85,157,-64)},
	-- {pos = vector.new(77,171,-51)},
	-- {pos = vector.new(70,189,-51)},
	-- {pos = vector.new(70,288,-51)},
}

local h = path_utilities.generateHelix(50,0,1,30)

--path_utilities.rotateCoords(h,quaternion.fromRotation(vector.new(0,0,1), 90))
path_utilities.rotateCoordsByAxis(h,vector.new(1,0,0),90)

path_utilities.recenterStartToOrigin(h)
path_utilities.offsetCoords(h,vector.new(50,-33,-48))
--waypoints = {}
local waypoint_length = #waypoints
for i,coord in ipairs(h) do
	waypoints[i+waypoint_length] = {pos = coord}
end

if (#waypoints>3) then
	local loop_path = true
	local ship_path = Path(waypoints,loop_path)
	spline_coords = ship_path:getNormalizedCoordsWithGradientsAndNormals(0.7,loop_path)
end

instance_configs.path_tracer_custom_config.SPLINE_COORDS = spline_coords
instance_configs.path_tracer_custom_config.STEP_SPEED = 0.08

--local drone = TenThrusterTemplateVerticalCompactSP(instance_configs)
local drone = PathTracerDrone(instance_configs)
--local drone = TenThrusterTemplateHorizontalCompactSP(instance_configs)

local cloud_level = 240


local timer_delay = 0.1 --seconds

local count_down = timer_delay

local tick_rate = 0.05
local current_state = false
local prev_state = current_state

--switches HammerHead Mirage frame depending on ship altitude
function setMirageCloudLevelMode(current_ship_altitude)
	local rs = false
	if(count_down > 0) then
		rs = true
	else
		rs = false
	end

	if(current_ship_altitude <= cloud_level) then
		redstone.setOutput("left",rs)
		redstone.setOutput("right",false)
		current_state = true
	else
		redstone.setOutput("left",false)
		redstone.setOutput("right",rs)
		current_state = false
	end

	count_down = math.max(count_down - tick_rate, 0)

	if(prev_state ~= current_state) then
		prev_state = current_state
		count_down = timer_delay
	end
end

function drone:droneCustomFlightLoopBehavior()
	setMirageCloudLevelMode(self.ShipFrame.ship_global_position.y)
end

drone:run()