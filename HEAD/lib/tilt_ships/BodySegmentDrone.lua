local TenThrusterTemplateVerticalCompactSP = require "lib.tilt_ships.TenThrusterTemplateVerticalCompactSP"

local quaternion = require "lib.quaternions"

local Object = require "lib.object.Object"

local flight_utilities = require "lib.flight_utilities"

local BodySegmentDrone = Object:subclass()

--overridable functions--
function BodySegmentDrone:setShipFrameClass(configs) --override this to set ShipFrame Template
	self.ShipFrame = TenThrusterTemplateVerticalCompactSP(configs)
end
--overridable functions--

--custom--
--initialization:
function BodySegmentDrone:initializeShipFrameClass(instance_configs)
	local configs = instance_configs
	
	configs.ship_constants_config = configs.ship_constants_config or {}
	
	configs.ship_constants_config.DRONE_TYPE = "SEGMENT"
	
	configs.ship_constants_config.MOD_CONFIGURED_THRUSTER_SPEED = configs.ship_constants_config.MOD_CONFIGURED_THRUSTER_SPEED or 10000
		
	configs.ship_constants_config.THRUSTER_TIER = configs.ship_constants_config.THRUSTER_TIER or 5

	configs.ship_constants_config.PID_SETTINGS = configs.ship_constants_config.PID_SETTINGS or
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
	
	configs.radar_config = configs.radar_config or {}
	
	configs.radar_config.player_radar_box_size = configs.radar_config.player_radar_box_size or 50
	configs.radar_config.ship_radar_range = configs.radar_config.ship_radar_range or 500
	
	configs.rc_variables = configs.rc_variables or {}
	
	
	configs.rc_variables.run_mode = false

	self:setShipFrameClass(configs)
	self.ShipFrame:setTargetMode(false,"SHIP")
	
end


function BodySegmentDrone:run()
	self.ShipFrame:run()
end

function BodySegmentDrone:setSegmentDelay(new_value)
	self.rc_variables.segment_delay = tonumber(new_value)
	self.saved_alignment_position = {self.ShipFrame.ship_global_position}
	self.saved_alignment_orientation = {self.ShipFrame.ship_rotation}
end
function BodySegmentDrone:setGapLength(new_value)
	self.rc_variables.gap_length = tonumber(new_value)
end

--custom--


--overridden functions--
function BodySegmentDrone:overrideShipFrameCustomProtocols()
	local bsd = self
	function self.ShipFrame:customProtocols(msg)
		local command = msg.cmd
		command = command and tonumber(command) or command
		case =
		{
		["segment_delay"] = function (arguments)
			bsd:setSegmentDelay(arguments)
		end,
		["gap_length"] = function (arguments)
			bsd:setGapLength(arguments)
		end,
		["HUSH"] = function (args) --kill command
			self:resetRedstone()
			print("reseting redstone")
			self.run_firmware = false
		end,
		default = function ( )
			print(textutils.serialize(command)) 
			print("customHoundProtocols: default case executed")   
		end,
		}
		if case[command] then
		 case[command](msg.args)
		else
		 case["default"]()
		end
	end
end

function BodySegmentDrone:overrideShipFrameGetCustomSettings()
	local bsd = self
	function self.ShipFrame.remoteControlManager:getCustomSettings()
		return {
			segment_delay = bsd.rc_variables.segment_delay,
			gap_length = bsd.rc_variables.gap_length,
			group_id = bsd.rc_variables.group_id,
			segment_number = bsd.rc_variables.segment_number,
		}
	end
end

function BodySegmentDrone:overrideShipFrameCustomPreFlightLoopBehavior()
	local bsd = self
	function self.ShipFrame:customPreFlightLoopBehavior()
		bsd.saved_alignment_position = {self.ship_global_position}
		bsd.saved_alignment_orientation = {self.ship_rotation}
		bsd.prev_time = os.clock()
	end
end

function BodySegmentDrone:overrideShipFrameCustomFlightLoopBehavior()
	local bsd = self
	function self.ShipFrame:customFlightLoopBehavior()
		--[[
		useful variables to work with:
			self.target_global_position
			self.target_rotation
			self.rotation_error
			self.position_error
		]]--
		
		--term.clear()
		--term.setCursorPos(1,1)
				
		--self:debugProbe({"debugging drone: ",self.ship_constants.DRONE_ID})

		if (not self.remoteControlManager.rc_variables.run_mode) then
			return;
		end

		local elapsed_time = os.clock() - bsd.prev_time
		if (elapsed_time < 0.1) then
			return
		else
			bsd.prev_time = os.clock()
		end

		local leader = self.sensors.orbitTargeting:getTargetSpatials()
		-- self:debugProbe({"leader.velocity: ",leader.velocity:length()})
		-- if (math.abs(leader.velocity:length()) < 3) then
		-- 	return
		-- end
		--local actual_leader_orientation = quaternion.fromRotation(leader.orientation:localPositiveY(),45)*leader.orientation
		--local new_leader_left_vector = actual_leader_orientation:localPositiveY()

		--local chain_link_pos = leader.position + actual_leader_orientation:localPositiveZ()-- * -bsd.rc_variables.gap_length
		--self.target_global_position = flight_utilities.adjustOrbitRadiusPosition(self.target_global_position,chain_link_pos,bsd.rc_variables.gap_length)
		--self.target_global_position = flight_utilities.adjustOrbitRadiusPosition(leader.position,chain_link_pos,bsd.rc_variables.gap_length)
		local actual_gap = math.abs((leader.position - self.sensors.shipReader:getWorldspacePosition()):length())
		
		if (actual_gap >= bsd.rc_variables.gap_length) then
			table.insert(bsd.saved_alignment_orientation,1,leader.orientation)
			table.insert(bsd.saved_alignment_position,1,leader.position)

			if (#bsd.saved_alignment_orientation>bsd.rc_variables.segment_delay) then
				table.remove(bsd.saved_alignment_orientation)
				table.remove(bsd.saved_alignment_position)
			end
		end
		self.target_global_position = bsd.saved_alignment_position[#bsd.saved_alignment_position]
		self.target_rotation = bsd.saved_alignment_orientation[#bsd.saved_alignment_orientation]
		
	end
end


function BodySegmentDrone:initCustom(custom_config)
	self.rc_variables.segment_delay = custom_config.segment_delay or 30
	self.rc_variables.gap_length = custom_config.gap_length or 10
	self.rc_variables.group_id = custom_config.group_id or "groupA"
	self.rc_variables.segment_number = custom_config.segment_number or 0
end

function BodySegmentDrone:init(instance_configs)
	self:initializeShipFrameClass(instance_configs)
	
	self:overrideShipFrameCustomProtocols()
	self:overrideShipFrameGetCustomSettings()
	--self:overrideShipFrameOnResetRedstone()
	--self:addShipFrameCustomThread()
	self:overrideShipFrameCustomPreFlightLoopBehavior()
	self:overrideShipFrameCustomFlightLoopBehavior()

	body_segment_custom_config = instance_configs.body_segment_custom_config or {}

	self.rc_variables = instance_configs.rc_variables

	self:initCustom(body_segment_custom_config)
	BodySegmentDrone.superClass.init(self)
end
--overridden functions--




return BodySegmentDrone