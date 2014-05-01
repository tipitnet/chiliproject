require_dependency 'watchers_controller'

module TipitExtensions

  module WatchersControllerPatch
=begin
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :unwatch, :tipit_patch
      end

    end

    module ClassMethods
    end

    module InstanceMethods

      def unwatch_with_tipit_patch
        unwatch_without_tipit_patch
        nowatcher = Nowatcher.all(:conditions => "user_id=#{User.current.id} and watchable_id=#{@watched.id} and watchable_type='#{@watched.class}'").first
        if nowatcher.nil?
          nowatcher = Nowatcher.new
          nowatcher.user_id = User.current.id
          nowatcher.watchable_id = @watched.id
          nowatcher.watchable_type = @watched.type.to_s
          nowatcher.save
        end
      end


    end
=end    
  end

end