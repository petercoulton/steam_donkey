module SteamDonkey
	class Config
		def self.load(rc_file, global)
			myini = IniFile.load(File.absolute_path('/Users/petercoulton/.donkeyrc'))
			global[:rc] = {}

			config = { :package => {} }
			myini['cloudformation "package"'].each do |k, v| 
				 config[:package][k.gsub(/"/, '')] = v
			end
			global[:rc][:cloudformation] = config
		end
	end
end