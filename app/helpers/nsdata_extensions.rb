class NSData
	def int32_offset(offset)
		int_bytes = self.bytes.cast!('i')
		TheGame.ntohl(int_bytes[offset / 4])
	end

	def int16_offset(offset)
		short_bytes = self.bytes.cast!('s')
		TheGame.ntohs(short_bytes[offset/2])
	end
  
	def int8_offset(offset)
		char_bytes = self.bytes.cast!('c')
		char_bytes[offset]
	end

	def string_offset(offset, bytesRead:amount)
		char_bytes = self.bytes.cast!('c')
		string = NSString.stringWithUTF8String(char_bytes + offset)
		amount.assign(string.length + 1)
		string
	end
end

class NSMutableData
	def append_int32(value)
		ptr = Pointer.new(:int)
		ptr.assign(TheGame.htonl(value))
		self.appendBytes(ptr, length:4)
	end

	def append_int16(value)
		ptr = Pointer.new(:int)
		ptr.assign(TheGame.htons(value))
		self.appendBytes(ptr, length:2)
	end

	def append_int8(value)
		ptr = Pointer.new(:int)
		ptr.assign(value)
		self.appendBytes(ptr, length:1)
	end

	def append_string(str)
  		self.appendBytes(str.to_data.bytes, length:str.length + 1)
	end
end

