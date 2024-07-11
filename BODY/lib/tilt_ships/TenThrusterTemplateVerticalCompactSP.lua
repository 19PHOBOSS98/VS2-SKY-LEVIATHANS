local quaternion = require "lib.quaternions"
local utilities = require "lib.utilities"

local DroneBaseClassSP = require "lib.tilt_ships.DroneBaseClassSP"

local TenThrusterTemplateVerticalCompactSP = DroneBaseClassSP:subclass()

TenThrusterTemplateVerticalCompactSP.RSIBow = peripheral.wrap("top")
TenThrusterTemplateVerticalCompactSP.RSIStern = peripheral.wrap("bottom")

--OVERRIDABLE FUNCTIONS--
function TenThrusterTemplateVerticalCompactSP:powerThrusters(component_redstone_power)
	if(type(component_redstone_power) == "number")then
		self.RSIBow.setAnalogOutput("up", component_redstone_power)      -- +Y
		self.RSIBow.setAnalogOutput("south", component_redstone_power)   -- +X
		self.RSIBow.setAnalogOutput("north", component_redstone_power)   -- -X
		self.RSIBow.setAnalogOutput("east", component_redstone_power)	-- +Z
		self.RSIBow.setAnalogOutput("west", component_redstone_power)	-- -Z

		self.RSIStern.setAnalogOutput("down", component_redstone_power)  -- -Y 
		self.RSIStern.setAnalogOutput("south", component_redstone_power) -- +X
		self.RSIStern.setAnalogOutput("north", component_redstone_power) -- -X
		self.RSIStern.setAnalogOutput("east", component_redstone_power)	-- +Z
		self.RSIStern.setAnalogOutput("west", component_redstone_power)	-- -Z
	else
		self.RSIBow.setAnalogOutput("up", component_redstone_power[1])      -- +Y
		self.RSIBow.setAnalogOutput("south", component_redstone_power[2])   -- +X
		self.RSIBow.setAnalogOutput("north", component_redstone_power[3])   -- -X
		self.RSIBow.setAnalogOutput("east", component_redstone_power[4])	-- +Z
		self.RSIBow.setAnalogOutput("west", component_redstone_power[5])	-- -Z

		self.RSIStern.setAnalogOutput("down", component_redstone_power[6])  -- -Y 
		self.RSIStern.setAnalogOutput("south", component_redstone_power[7]) -- +X
		self.RSIStern.setAnalogOutput("north", component_redstone_power[8]) -- -X
		self.RSIStern.setAnalogOutput("east", component_redstone_power[9])	-- +Z
		self.RSIStern.setAnalogOutput("west", component_redstone_power[10])	-- -Z
	end
end

function TenThrusterTemplateVerticalCompactSP:organizeThrusterTable(thruster_table)

	local new_thruster_table = {}

	for i,thruster in pairs(thruster_table) do
		new_thruster_table[1+#new_thruster_table] = {}
	end
	
	for i,thruster in pairs(thruster_table) do
		local dir = thruster.direction
		local rad = thruster.radius
		
		local isBow = rad.y > 0
		local idx_offset = isBow and 0 or 5

		if(dir.y > 0) then
			new_thruster_table[1] = thruster
		elseif (dir.y < 0) then
			new_thruster_table[6] = thruster
		elseif (dir.x > 0) then--east
			new_thruster_table[2+idx_offset] = thruster
		elseif (dir.x < 0) then--west
			new_thruster_table[3+idx_offset] = thruster
		elseif (dir.z > 0) then--south
			new_thruster_table[4+idx_offset] = thruster
		elseif (dir.z < 0) then--north
			new_thruster_table[5+idx_offset] = thruster
		end
	end

	return new_thruster_table
end

function TenThrusterTemplateVerticalCompactSP:getOffsetDefaultShipOrientation(default_ship_orientation)-----------------------
	return quaternion.fromRotation(default_ship_orientation:localPositiveY(), 45)*default_ship_orientation
end
--OVERRIDABLE FUNCTIONS--

function TenThrusterTemplateVerticalCompactSP:init(instance_configs)
	local configs = instance_configs
	
	configs.ship_constants_config = configs.ship_constants_config or {}
	
	configs.ship_constants_config.DEFAULT_NEW_LOCAL_SHIP_ORIENTATION = quaternion.fromRotation(vector.new(0,1,0), 45)-----------------------
	
	configs.ship_constants_config.MOD_CONFIGURED_THRUSTER_SPEED = configs.ship_constants_config.MOD_CONFIGURED_THRUSTER_SPEED or 10000-----------------------
	
	configs.ship_constants_config.THRUSTER_TIER = configs.ship_constants_config.THRUSTER_TIER or 2-----------------------
	
	configs.ship_constants_config.PID_SETTINGS = configs.ship_constants_config.PID_SETTINGS or-----------------------
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
	}

	TenThrusterTemplateVerticalCompactSP.superClass.init(self,configs)
end

return TenThrusterTemplateVerticalCompactSP