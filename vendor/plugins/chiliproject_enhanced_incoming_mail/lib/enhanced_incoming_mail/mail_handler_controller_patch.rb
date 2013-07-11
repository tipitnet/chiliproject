require_dependency 'mail_handler_controller'

module EnhancedIncomingMail

  module MailHandlerControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        alias_method_chain :index, :tipit_patch
      end

    end

    module ClassMethods
    end

    module InstanceMethods

      def index_with_tipit_patch
        call_hook(:controller_mail_handler_new_before_save, { :params => params, :issue => @issue })
        index_without_tipit_patch
      end


    end
  end

end