require "utils/polyfills"

require "engine/Engine"

require "tests/tests"

function love.load(args)

	for _, arg in ipairs(args) do
		if arg == "--test" then
			RunTestSuite()
			abort()
		end
	end

	Engine:init()	
end


