module Fastlane
  module Actions
    module SharedValues
      JIRA_UTIL_GET_JIRA_RELEASE_REPORT_LINK_RESULT = :JIRA_UTIL_GET_JIRA_RELEASE_REPORT_LINK_RESULT
    end

    class GetJiraReleaseReportLinkAction < Action
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
          project_id = project.key
        end
        raise ArgumentError.new("Project not found.") if project_id.nil?

        version = nil
        if !params[:version_id].nil?
          version = project.versions.find { |version| version.id == params[:version_id] }
        elsif !params[:version_name].nil?
          version = project.versions.find { |version| version.name == params[:version_name] }
        end

        raise ArgumentError.new("Version not found.") if version.nil?

        version_id = version.id

        raise ArgumentError.new("Version has empty id.") if version_id.nil?

        release_report_path = "/projects/#{project.key}/versions/#{version_id}/tab/release-report-all-issues"
        release_report_link = URI.join(site, release_report_path).to_s

        Actions.lane_context[SharedValues::JIRA_UTIL_GET_JIRA_RELEASE_REPORT_LINK_RESULT] = release_report_link
        release_report_link
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
        "Return link to JIRA release report."
      end

      def self.details
        "Return link to JIRA release report. Link looks like https://JIRA_SITE/projects/PROJ/versions/VERSION/tab/release-report-all-issues"
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
          FastlaneCore::ConfigItem.new(key: :version_id,
                                       description: "JIRA version id. E.g. 123456",
                                       optional: true,
                                       conflicting_options: [ :version_name ],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'id' and 'name' options in one run")
                                       end,
                                       verify_block: proc do |value|
                                         UI.user_error!("Empty verison id") unless !value.nil? and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_name,
                                       description: "JIRA version name",
                                       is_string: false,
                                       optional: true,
                                       conflicting_options: [:version_id],
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
          ['JIRA_UTIL_GET_JIRA_RELEASE_REPORT_LINK_RESULT', 'JIRA release report link']
        ]
      end

      def self.return_value
        'JIRA release report link'
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
