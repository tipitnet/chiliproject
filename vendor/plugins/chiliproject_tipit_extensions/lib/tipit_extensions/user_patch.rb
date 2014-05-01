require_dependency 'user'

module TipitExtensions

  module UserPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        class << self
          alias_method_chain :find_by_mail, :tipit_patch
        end
        safe_attributes 'secondary_mail'
      end

    end

    module ClassMethods

      def find_by_mail_with_tipit_patch(mail)
        user = find_by_mail_without_tipit_patch(mail)
        if user.nil?
          user = User.find_by_secondary_mail(mail)
        end
        user
      end

    end

    module InstanceMethods


    end
  end

end