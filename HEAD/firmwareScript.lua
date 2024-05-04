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
		DRONE_ID = 201,
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
	{pos = vector.new(9,-55,26)},
	{pos = vector.new(1,-49,41)},
	{pos = vector.new(-10,-44,17)},
	{pos = vector.new(0,-50,9)},
}

local h = path_utilities.generateHelix(10,3,2.5,15)
path_utilities.recenterStartToOrigin(h)
path_utilities.offsetCoords(h,vector.new(30,-40,20))
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

--local drone = TenThrusterTemplateVerticalCompactSP(instance_configs)
local drone = PathTracerDrone(instance_configs)

drone:run()