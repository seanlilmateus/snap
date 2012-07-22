class NSData
	def int32_offset(offset)
		int_bytes = self.bytes.cast!('i')
		Game.ntohl(int_bytes[offset / 4])
	end

	def int16_offset(offset)
		short_bytes = self.bytes.cast!('s')
		Game.ntohs(short_bytes[offset/2])
	end
  
	def int8_offset(offset)
		char_bytes = self.bytes.cast!('c')
		char_bytes[offset]
	end

	def string_offset(offset, bytesRead:amount)
		char_bytes = self.bytes.cast!('c')
		string = NSString.stringWithUTF8String(char_bytes + offset)# || "Mateus"
		amount.assign(string.length + 1)
		string
	end
end

class NSMutableData
	def append_int32(value)
		ptr = Pointer.new(:int)
		ptr.assign(Game.htonl(value))
		self.appendBytes(ptr, length:4)
	end

	def append_int16(value)
		ptr = Pointer.new(:int)
		ptr.assign(Game.htons(value))
		self.appendBytes(ptr, length:2)
	end

	def append_int8(value)
		ptr = Pointer.new(:int)
		ptr.assign(value)
		self.appendBytes(ptr, length:1)
	end

	def append_string(str)
		value = str.UTF8String
		ptr = Pointer.new(:string)
		ptr.assign(value)
		# data.appendData(value.to_data)
		self.appendBytes(ptr, length:value.length+1)
	end
end

