module EnhancedIncomingMail

	class EnhancedIncomingMailError < StandardError
		def initialize(message)
			super("Enhanced incoming mail plugin - #{message}")
		end
	end

end