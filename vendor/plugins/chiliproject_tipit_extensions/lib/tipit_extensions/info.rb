module TipitExtensions
  module Info
    class << self
      def current_release
        if(@current_release.nil?)
          @current_release = File.open(File.join(File.dirname(__FILE__),"current_release.txt")).read
        end
        @current_release
      end
    end
  end
end