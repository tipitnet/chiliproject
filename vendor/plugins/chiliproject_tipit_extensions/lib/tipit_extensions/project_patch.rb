require_dependency 'project'

module TipitExtensions

  module ProjectPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        safe_attributes 'default_watchers'
        safe_attributes 'wiki_template'
      end

    end

    module ClassMethods
    end

    module InstanceMethods

      def is_default_watcher(user)
        return false if default_watchers.nil?
        return default_watchers.include?(user.id.to_s)
      end

    end
  end

end