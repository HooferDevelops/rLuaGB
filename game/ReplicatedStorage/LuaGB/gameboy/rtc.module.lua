local gameboy = game.ReplicatedStorage.LuaGB.gameboy

local RTC = {}

function RTC.new(modules)
	local rtc = {}
	
	rtc.latch_enabled = false
	
	rtc.timezero = os.time()
	
	rtc.sec_latch = 0
	rtc.min_latch = 0
	rtc.hour_latch = 0
	rtc.day_latch_low = 0
	rtc.day_latch_high = 0
	rtc.day_carry = 0
	rtc.halt = 0
	
	rtc.latch_rtc = function(self)
		local delta_time = os.time() - self.timezero
		
		self.sec_latch = math.floor((delta_time % 60) + 0.5)
		self.min_latch = math.floor((delta_time / 60 % 60) + 0.5)
		self.hour_latch = math.floor((delta_time / 3600 % 24) + 0.5)
		local days = math.floor((delta_time / 3600 / 24) + 0.5)
		self.day_latch_low = bit32.band(days, 0xFF) 
		self.day_latch_high =  bit32.rshift(days, 8)
		
		if (self.day_latch_high > 1) then
			self.day_carry = 1
			self.day_latch_high = bit32.band(self.day_latch_high, 0b1) 
			self.timezero += 0x200 * 3600 * 24
		end
	end	
	
	rtc.write_command = function(self, value)
		if (value == 0x00) then
			self.latch_enabled = false
		elseif (value == 0x01) then
			if (not self.latch_enabled) then
				print("Latching RTC")
				self:latch_rtc()
			end
			self.latch_enabled = true
		else
			print("Invalid RTC Input: " .. value)
		end
	end
	
	rtc.get_register = function(self, register)
		if (not self.latch_enabled) then
			print("RTC attempted to get register, but latch is not enabled.")
		end
		
		if (register == 0x08) then
			return self.sec_latch
		elseif (register == 0x09) then
			return self.min_latch	
		elseif (register == 0x0A) then
			return self.hour_latch
		elseif (register == 0x0B) then
			return self.day_latch_low
		elseif (register == 0x0C) then
			local day_high = bit32.band(self.day_latch_high, 0b1)
			local halt = bit32.lshift(self.halt, 6)
			local day_carry = bit32.lshift(self.day_carry, 7)
			return day_high + halt + day_carry
		else
			print("Invalid RTC Register: "  .. register)
		end
	end
	
	rtc.set_register = function(self, register, value)
		if (not self.latch_enabled) then
			print("RTC attempted to set register, but latch is not enabled.")
		end
		
		local delta_time = os.time() - self.timezero
		
		if (register == 0x08) then
			self.timezero = self.timezero - math.floor((delta_time % 60) + 0.5) - value
		elseif (register == 0x09) then
			self.timezero = math.floor((delta_time / 60 % 60) + 0.5) - value
		elseif (register == 0x0A) then
			self.timezero = math.floor((delta_time / 3600 % 24) + 0.5) - value
		elseif (register == 0x0B) then
			self.timezero = math.floor((delta_time / 3600 / 24) + 0.5) - value
		elseif (register == 0x0C) then
			local day_high = bit32.band(value, 0b1)
			local halt = bit32.rshift(bit32.band(value, 0b1000000), 6)
			local day_carry = bit32.rshift(bit32.band(value, 0b10000000), 7)
			
			self.halt = halt
			if (self.halt == 0) then
				
			else
				print("Stopping RTC not implemented.")	
			end
			
			self.timezero = self.timezero - math.floor((delta_time / 3600 / 24) + 0.5) - (bit32.lshift(day_high, 8))
			self.day_carry  = day_carry
		else
			print("Invalid RTC Register: "  .. register .. ", " .. value)
		end
	end
	
	return rtc
end

return RTC
