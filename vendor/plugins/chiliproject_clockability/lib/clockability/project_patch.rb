require_dependency 'project'

module Clockability

  module ProjectPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        safe_attributes 'sync_with_clock'
      end

    end

    module ClassMethods
    end

    module InstanceMethods
    end

  end

end