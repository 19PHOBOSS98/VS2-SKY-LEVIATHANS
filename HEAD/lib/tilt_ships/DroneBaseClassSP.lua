local quaternion = require "lib.quaternions"
local utilities = require "lib.utilities"
local pidcontrollers = require "lib.pidcontrollers"
local targeting_utilities = require "lib.targeting_utilities"
local player_spatial_utilities = require "lib.player_spatial_utilities"
local flight_utilities = require "lib.flight_utilities"
local JSON = require "lib.JSON"
local matrix = require "lib.matrix"

local clamp = utilities.clamp
local PwmScalar = utilities.PwmScalar
local getQuaternionRotationError = flight_utilities.getQuaternionRotationError
local getLocalPositionError = flight_utilities.getLocalPositionError
local abs = math.abs
local max = math.max
local min = math.min


local SensorsSP = require "lib.sensory.SensorsSP"

local DroneBaseClass = require "lib.tilt_ships.DroneBaseClass"

local DroneBaseClassSP = DroneBaseClass:subclass()

--OVERRIDABLE FUNCTIONS--
function DroneBaseClassSP:organizeThrusterTable(thruster_table)

	local new_thruster_table = {}

	return new_thruster_table
end

function DroneBaseClassSP:powerThrusters(redstone_power)
	if(type(redstone_power) == "number")then
		
	else
		
	end
end

function DroneBaseClassSP:getOffsetDefaultShipOrientation(default_ship_orientation)	--based on dynamic ship orientation (rotated from how it is oriented right now)
	return DroneBaseClass:getOffsetDefaultShipOrientation(default_ship_orientation)
end

function DroneBaseClassSP:initAccelerationControllers()
	local max_lin_acc = self.max_linear_acceleration
	local max_ang_acc = self.max_angular_acceleration
	self.pos_PID = pidcontrollers.PID_Discrete_Vector(	self.ship_constants.PID_SETTINGS.POS.P,
											self.ship_constants.PID_SETTINGS.POS.I,
											self.ship_constants.PID_SETTINGS.POS.D,
											-max_lin_acc,max_lin_acc)

	self.rot_x_PID = pidcontrollers.PID_Discrete_Scalar(self.ship_constants.PID_SETTINGS.ROT.X.P,
													self.ship_constants.PID_SETTINGS.ROT.X.I,
													self.ship_constants.PID_SETTINGS.ROT.X.D,
													-max_ang_acc[1][1],max_ang_acc[1][1])
	self.rot_y_PID = pidcontrollers.PID_Discrete_Scalar(self.ship_constants.PID_SETTINGS.ROT.Y.P,
													self.ship_constants.PID_SETTINGS.ROT.Y.I,
													self.ship_constants.PID_SETTINGS.ROT.Y.D,
													-max_ang_acc[2][1],max_ang_acc[2][1])
	self.rot_z_PID = pidcontrollers.PID_Discrete_Scalar(self.ship_constants.PID_SETTINGS.ROT.Z.P,
													self.ship_constants.PID_SETTINGS.ROT.Z.I,
													self.ship_constants.PID_SETTINGS.ROT.Z.D,
													-max_ang_acc[3][1],max_ang_acc[3][1])

	-- self.pos_PID = pidcontrollers.PID_Continuous_Vector(	self.ship_constants.PID_SETTINGS.POS.P,
	-- 										self.ship_constants.PID_SETTINGS.POS.I,
	-- 										self.ship_constants.PID_SETTINGS.POS.D,
	-- 										-max_lin_acc,max_lin_acc)
	-- self.rot_x_PID = pidcontrollers.PID_Continuous_Scalar(self.ship_constants.PID_SETTINGS.ROT.X.P,
	-- 												self.ship_constants.PID_SETTINGS.ROT.X.I,
	-- 												self.ship_constants.PID_SETTINGS.ROT.X.D,
	-- 												-max_ang_acc[1][1],max_ang_acc[1][1])
	-- self.rot_y_PID = pidcontrollers.PID_Continuous_Scalar(self.ship_constants.PID_SETTINGS.ROT.Y.P,
	-- 												self.ship_constants.PID_SETTINGS.ROT.Y.I,
	-- 												self.ship_constants.PID_SETTINGS.ROT.Y.D,
	-- 												-max_ang_acc[2][1],max_ang_acc[2][1])
	-- self.rot_z_PID = pidcontrollers.PID_Continuous_Scalar(self.ship_constants.PID_SETTINGS.ROT.Z.P,
	-- 												self.ship_constants.PID_SETTINGS.ROT.Z.I,
	-- 												self.ship_constants.PID_SETTINGS.ROT.Z.D,
	-- 												-max_ang_acc[3][1],max_ang_acc[3][1])
end

function DroneBaseClassSP:calculateAcceleration(rotation_error,position_error)--return rotational-acceletarion and lateral-acceleration in that order
	return 	matrix({
				{self.rot_x_PID:run(rotation_error.x)},
				{self.rot_y_PID:run(rotation_error.y)},
				{self.rot_z_PID:run(rotation_error.z)}
			}),
			self.pos_PID:run(position_error)
end
--OVERRIDABLE FUNCTIONS--

function DroneBaseClassSP:initSensors(configs)
	self.sensors = SensorsSP(configs)
end

function DroneBaseClassSP:initSensorRadar(radar_config)
	radar_config.radar_range=radar_config.radar_range or 200
	self.sensors:initRadar(radar_config)
end

--pre-calculate thruster placement compensation:
function DroneBaseClassSP:getInertiaTensors()
	return self.sensors.shipReader:getInertiaMatrix()
end

function DroneBaseClassSP:rotateInertiaTensors()
	self.ship_constants.LOCAL_INERTIA_TENSOR = quaternion.rotateMatrix(
												self.ship_constants.LOCAL_INERTIA_TENSOR,
												self.ship_constants.DEFAULT_NEW_LOCAL_SHIP_ORIENTATION)

	self.ship_constants.LOCAL_INV_INERTIA_TENSOR = quaternion.rotateMatrix(
													self.ship_constants.LOCAL_INV_INERTIA_TENSOR,
													self.ship_constants.DEFAULT_NEW_LOCAL_SHIP_ORIENTATION)
end

function DroneBaseClassSP:resetRedstone()
	self:powerThrusters(0)
	self:onResetRedstone()
end

function DroneBaseClassSP:getThrusterTable()
	self:powerThrusters(1)
	os.sleep(1)
	
	local thrusters = vst_components.get_thrusters()
	self:powerThrusters(0)

	local thruster_table = {}

	for i,thruster in pairs(thrusters) do
		
		local radius = vector.new(thruster.pos.x,thruster.pos.y,thruster.pos.z) - vector.new(0.5,0.5,0.5) -- tournament 1.1.0 beta 4.1 has the thruster pos value off by 0.5
		
		local force = vector.new(thruster.force.x,thruster.force.y,thruster.force.z)
		local direction = force:normalize()
		
		thruster_table[1+#thruster_table] = {direction=direction,radius=radius,base_force=force:length()}
		
	end
	--[[
	local h = fs.open("./input_thruster_table/NEW_thruster_table.json","w")
	h.writeLine(JSON:encode_pretty(thruster_table))
	h.flush()
	h.close()
	]]--
	print(#thrusters," Thrusters Detected")
	return self:organizeThrusterTable(thruster_table)
end

function DroneBaseClassSP:buildJacobianTranspose(thruster_table)
	local inverse_new_default_ship_orientation = self.ship_constants.DEFAULT_NEW_LOCAL_SHIP_ORIENTATION:inv()
	local jacobian_transpose = {}

	for i,v in pairs(thruster_table) do
		local dir = v.direction
		dir = vector.new(dir.x,dir.y,dir.z)
		local r = v.radius
		r = vector.new(r.x,r.y,r.z)
		local base_thrust = v.base_force
		local new_dir = inverse_new_default_ship_orientation:rotateVector3(dir)
		local new_r = inverse_new_default_ship_orientation:rotateVector3(r)
		local force = new_dir*base_thrust
		local torque = utilities.round_vector3(new_r:cross(force))
		jacobian_transpose[i] = {
			max(0,force.x==0 and 0 or force.x), --positive
			abs(min(0,force.x==0 and 0 or force.x)),--negative
			max(0,force.y==0 and 0 or force.y),
			abs(min(0,force.y==0 and 0 or force.y)),
			max(0,force.z==0 and 0 or force.z),
			abs(min(0,force.z==0 and 0 or force.z)),
		
			max(0,torque.x==0 and 0 or torque.x),
			abs(min(0,torque.x==0 and 0 or torque.x)),
			max(0,torque.y==0 and 0 or torque.y),
			abs(min(0,torque.y==0 and 0 or torque.y)),
			max(0,torque.z==0 and 0 or torque.z),
			abs(min(0,torque.z==0 and 0 or torque.z)),
		}
	end

	local total = {0,0,0,0,0,0,0,0,0,0,0,0}

	for i,v in ipairs(jacobian_transpose) do
		for ii,vv in ipairs(v) do
			if(jacobian_transpose[i][ii]~=0)then
				total[ii] = total[ii]+(jacobian_transpose[i][ii])
			end
		end
	end
	--the total force/torque is distributed depending on each thruster's contribution by percentage
	for i,v in ipairs(jacobian_transpose) do
		for ii,vv in ipairs(v) do
			if(jacobian_transpose[i][ii]~=0) then 
				local thruster_contribution_percentage = (jacobian_transpose[i][ii])/total[ii]
				jacobian_transpose[i][ii] = thruster_contribution_percentage/jacobian_transpose[i][ii]
			end
		end
	end

	return jacobian_transpose
end


--redstone:
function DroneBaseClassSP:initFlightConstants()
	
	local min_time_step = 0.05 --how fast the computer should continuously loop (the max is 0.05 for ComputerCraft)
	local ship_mass = self.sensors.shipReader:getMass()
	local gravity_acceleration_vector = vector.new(0,-9.8,0)
	
	local max_redstone = 15
	
	local thruster_table = self:getThrusterTable()

	local JACOBIAN_TRANSPOSE = matrix(self:buildJacobianTranspose(thruster_table))
	
	local minimum_base_thruster_force = 9999999999
	local minimum_radius_vector = vector.new(99999999,99999999,99999999)
	local minimum_thruster_direction = vector.new(0,1,0)
	
	for i,v in pairs(thruster_table) do
		local thruster_radius = v.radius
		thruster_radius = vector.new(thruster_radius.x,thruster_radius.y,thruster_radius.z)
		if (thruster_radius:length() < minimum_radius_vector:length()) then
			minimum_radius_vector = thruster_radius
			minimum_thruster_direction = v.direction
			minimum_thruster_direction = vector.new(minimum_thruster_direction.x,minimum_thruster_direction.y,minimum_thruster_direction.z)
		end
		if(v.base_force<minimum_base_thruster_force) then
			minimum_base_thruster_force = v.base_force
		end
	end
	
	local inverse_new_default_ship_orientation = self.ship_constants.DEFAULT_NEW_LOCAL_SHIP_ORIENTATION:inv()
	local new_min_dir = inverse_new_default_ship_orientation:rotateVector3(minimum_thruster_direction)
	local new_min_r = inverse_new_default_ship_orientation:rotateVector3(minimum_radius_vector)
	
	local max_thruster_force = max_redstone*minimum_base_thruster_force
	local max_linear_acceleration = max_thruster_force/ship_mass
	
	local torque_saturation = new_min_r:cross(new_min_dir) * max_thruster_force
	
	torque_saturation = utilities.abs_vector3(torque_saturation)	
	torque_saturation = matrix({{torque_saturation.x},{torque_saturation.y},{torque_saturation.z}})
	
	
	
	local max_angular_acceleration = matrix.mul(self.ship_constants.LOCAL_INV_INERTIA_TENSOR,torque_saturation)
	
	self.min_time_step = min_time_step
	self.ship_mass = ship_mass
	self.gravity_acceleration_vector = gravity_acceleration_vector
	self.JACOBIAN_TRANSPOSE = JACOBIAN_TRANSPOSE
	self.max_linear_acceleration = max_linear_acceleration
	self.max_angular_acceleration = max_angular_acceleration

end

function DroneBaseClassSP:calculateMovement()

	self:initFlightConstants()

	self:initAccelerationControllers()
	
	self.pwmMatrixList = utilities.PwmMatrixList(10)
	
	self:customPreFlightLoopBehavior()
	
	local customFlightVariables = self:customPreFlightLoopVariables()
	
	while self.run_firmware do
		if(self.ship_mass ~= ship.getMass()) then
			self:initFlightConstants()
		end
		self:customFlightLoopBehavior(customFlightVariables)

		self.ship_rotation = self.sensors.shipReader:getRotation(true)
		self.ship_rotation = quaternion.new(self.ship_rotation.w,self.ship_rotation.x,self.ship_rotation.y,self.ship_rotation.z)
		self.ship_rotation = self:getOffsetDefaultShipOrientation(self.ship_rotation)

		self.ship_global_position = self.sensors.shipReader:getWorldspacePosition()
		self.ship_global_position = vector.new(self.ship_global_position.x,self.ship_global_position.y,self.ship_global_position.z)
		
		self.rotation_error = getQuaternionRotationError(self.target_rotation,self.ship_rotation)
		self.position_error = getLocalPositionError(self.target_global_position,self.ship_global_position,self.ship_rotation)
		
		local pid_output_angular_acceleration,pid_output_linear_acceleration = self:calculateAcceleration(self.rotation_error,self.position_error)

		local net_torque = matrix.mul(self.ship_constants.LOCAL_INERTIA_TENSOR,pid_output_angular_acceleration)
		
		local local_gravity_acceleration = self.ship_rotation:inv():rotateVector3(self.gravity_acceleration_vector)
		local net_linear_acceleration = pid_output_linear_acceleration:sub(local_gravity_acceleration)

		local net_force = net_linear_acceleration*self.ship_mass

		local net = matrix(
		{
			{max(0,net_force.x)},--positive
			{abs(min(0,net_force.x))},--negative
			
			{max(0,net_force.y)},
			{abs(min(0,net_force.y))},
			
			{max(0,net_force.z)},
			{abs(min(0,net_force.z))},
			
			{max(0,net_torque[1][1])},
			{abs(min(0,net_torque[1][1]))},
			
			{max(0,net_torque[2][1])},
			{abs(min(0,net_torque[2][1]))},
			
			{max(0,net_torque[3][1])},
			{abs(min(0,net_torque[3][1]))}
		})
		
		local thruster_redstone_power = matrix.mul(self.JACOBIAN_TRANSPOSE,net)
		self:applyRedStonePower(thruster_redstone_power)
		sleep(self.min_time_step)
	end
end

function DroneBaseClassSP:applyRedStonePower(redstone_power)
	local pwm_redstone_power = self.pwmMatrixList:run(redstone_power)
	self:powerThrusters(pwm_redstone_power)
end

return DroneBaseClassSP