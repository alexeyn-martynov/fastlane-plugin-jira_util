require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class JiraUtilHelper
      # class methods that you define here become available in your action
      # as `Helper::JiraUtilHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the jira_util plugin helper!")
      end

      def self.transform_keys_to_symbols(value)
        return value if not value.is_a?(Hash)
        return value.inject({}){|memo,(k,v)| memo[k.to_sym] = Helper::JiraUtilHelper.transform_keys_to_symbols(v); memo}
      end
    end
  end
end
