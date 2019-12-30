module Fastlane
  module Actions
    module SharedValues
      JIRA_UTIL_UPDATE_JIRA_VERSION_VERSION_ID = :JIRA_UTIL_UPDATE_JIRA_VERSION_VERSION_ID
    end

    class UpdateJiraVersionAction < Action
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
        name         = params[:name]
        new_name     = params[:new_name]
        description  = params[:description]
        archived     = params[:archived]
        released     = params[:released]
        start_date   = params[:start_date]

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
        raise ArgumentError.new('Project not found') if project_id.nil?

        if start_date.nil?
          start_date = Date.today.to_s
        end

        version = nil
        if !params[:id].nil?
          version = project.versions.find { |version| version.id == params[:id] }
        elsif !params[:name].nil?
          version = project.versions.find { |version| version.name == params[:name] }
        end

        raise ArgumentError.new('Version not found') if version.nil?

        version_fields = {
        }

        unless new_name.nil?
          version_fields['name'] = new_name
        end

        unless description.nil?
          version_fields['description'] = description
        end

        unless archived.nil?
          version_fields['archived'] = archived
        end

        unless released.nil?
          version_fields['released'] = released
        end

        unless start_date.nil?
          version_fields['startDate'] = start_date
        end

        raise ArgumentError.new('Nothng to update') if version_fields.empty?

        version.save!(version_fields)

        Actions.lane_context[SharedValues::JIRA_UTIL_UPDATE_JIRA_VERSION_VERSION_ID] = version.id
        version.id
      rescue
        UI.user_error!("Failed to update JIRA version: #{$!.response.body}")
        false
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Creates a new version in your JIRA project"
      end

      def self.details
        "Use this action to create a new version in JIRA"
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
                                         UI.user_error!("Empty verison id") unless value and !value.empty?
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
                                          UI.user_error!("Empty verison name") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :new_name,
                                       optional: true,
                                       description: "New name for the version. E.g. 1.0.0",
                                       verify_block: proc do |value|
                                         UI.user_error!("new_name is empty") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :description,
                                       optional: true,
                                       description: "The description of the JIRA project version"),
          FastlaneCore::ConfigItem.new(key: :archived,
                                       description: "Whether the version should be archived",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :released,
                                       description: "Whether the version should be released",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :start_date,
                                       description: "The date this version will start on",
                                       type: String,
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['JIRA_UTIL_UPDATE_JIRA_VERSION_VERSION_ID', 'The id for the updated JIRA project version']
        ]
      end

      def self.return_value
        'The id for the updated JIRA project version'
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
