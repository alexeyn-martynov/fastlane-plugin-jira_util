describe Fastlane::Actions::JiraUtilAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_util plugin is working!")

      Fastlane::Actions::JiraUtilAction.run(nil)
    end
  end
end
