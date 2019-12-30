module Fastlane
  module Actions
    module SharedValues
      JIRA_UTIL_GET_JIRA_VERSION_RESULT = :JIRA_UTIL_GET_JIRA_VERSION_RESULT
    end

    class GetJiraVersionAction < Action
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        site         = params[:url]
        context_path = ""
        auth_type    = :basic
        username     = params[:username]
        password     = params[:password]
        project_name = params[:project_name]
        project_id   = params[:project_id]
        released     = true

        options = {
          username:     username,
          password:     password,
          site:         site,
          context_path: context_path,
          auth_type:    auth_type,
          read_timeout: 120
        }

        client = JIRA::Client.new(options)

        unless project_name.nil?
          project = client.Project.find(project_name)
          project_id = project.id
        end
        raise ArgumentError.new("Project not found.") if project_id.nil?

        version = nil
        if !params[:id].nil?
          version = project.versions.find { |version| version.id == params[:id] }
        elsif !params[:name].nil?
          version = project.versions.find { |version| version.name == params[:name] }
        end

        version_attrs = if !version.nil? then
          Helper::JiraUtilHelper.transform_keys_to_symbols(version.attrs)
        else
          nil
        end

        Actions.lane_context[SharedValues::JIRA_UTIL_GET_JIRA_VERSION_RESULT] = version_attrs
        version_attrs
      rescue RuntimeError
        UI.user_error!("#{$!}")
        nil
      rescue JIRA::HTTPError
        UI.user_error!("Failed to find JIRA version: #{$!.response.body}")
        nil
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Finds project version in your JIRA project by id or by name"
      end

      def self.details
        "Use this action to find a version in JIRA"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                      env_name: "FL_JIRA_UTIL_SITE",
                                      description: "URL for Jira instance",
                                      type: String,
                                      verify_block: proc do |value|
                                        UI.user_error!("No url for Jira given, pass using `url: 'url'`") unless value and !value.empty?
                                      end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_JIRA_UTIL_USERNAME",
                                       description: "Username for JIRA instance",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No username given, pass using `username: 'jira_user'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_JIRA_UTIL_PASSWORD",
                                       description: "Password for Jira",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No password given, pass using `password: 'T0PS3CR3T'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_JIRA_UTIL_PROJECT_NAME",
                                       description: "Project ID for the JIRA project. E.g. the short abbreviation in the JIRA ticket tags",
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:project_id],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'project_name' and '#{project_id}' options in one run")
                                       end,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Project ID given, pass using `project_id: 'PROJID'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_id,
                                       env_name: "FL_JIRA_UTIL_PROJECT_ID",
                                       description: "Project ID for the JIRA project. E.g. the short abbreviation in the JIRA ticket tags",
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:project_name],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'project_id' and '#{project_name}' options in one run")
                                       end,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Project ID given, pass using `project_id: 'PROJID'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :id,
                                       description: "JIRA version id. E.g. 123456",
                                       optional: true,
                                       conflicting_options: [ :name ],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'id' and 'name' options in one run")
                                       end,
                                       verify_block: proc do |value|
                                         UI.user_error!("Empty verison id") unless !value.nil? and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :name,
                                       description: "JIRA version name",
                                       is_string: false,
                                       optional: true,
                                       conflicting_options: [:id],
                                       conflict_block: proc do |value|
                                          UI.user_error!("You can't use 'id' and 'name' options in one run")
                                       end,
                                       verify_block: proc do |value|
                                          UI.user_error!("Empty verison name") unless !value.nil? and !value.empty?
                                       end)
        ]
      end

      def self.output
        [
          ['JIRA_UTIL_GET_JIRA_VERSION_RESULT', 'Hash containing all version attributes']
        ]
      end

      def self.return_value
        'Hash containing all version attributes'
      end

      def self.authors
        [ "https://github.com/alexeyn-martynov" ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
