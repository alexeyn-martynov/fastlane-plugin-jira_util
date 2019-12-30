# jira_util fastlane plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-jira_util)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-jira_util`, add it to your project by running:

```bash
fastlane add_plugin jira_util
```

## About jira_util

Manage your JIRA project's releases/versions with this plugin.

Currently, jira_util comes with following actions actions: `create_jira_issue`, `create_jira_version`, `get_jira_release_report_link`, `get_jira_version`, `release_jira_version` and `update_jira_version`.
About actions:
* `create_jira_issue` - will create a new issue in your JIRA project.
* `create_jira_version` - will create a new version. It fails if version with same name already exists in JIRA project.
* `get_jira_release_report_link` - returns link to JIRA release report.
* `get_jira_version` - returns existing JIRA version.
* `release_jira_version` - release existing version in JIRA project.
* `update_jira_version` -  updates existing version.

## Create Version Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins`, modifying the placeholder variables in the Fastfile lane and running `bundle exec fastlane create_version`. 

## Release Version Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins`, modifying the placeholder variables in the Fastfile lane and running `bundle exec fastlane release_version`. 

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use 
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Notes for developers

### Useful links
* This plugin uses jira-ruby gem. Here is jira-ruby [examples](https://github.com/sumoheavy/jira-ruby/blob/master/example.rb)
* How to create fastlane plugin [documentation](https://docs.fastlane.tools/plugins/create-plugin/)

### Rubygems how-to
* Buld
	```shell
	gem build fastlane-plugin-jira_util.gemspec
	```
* Install local gem
	```shell
	gem install --local ./fastlane-plugin-jira_util-0.1.6.gem
	```
* Publish
	```shell
	gem push fastlane-plugin-jira_util-0.1.6.gem
	```
* Delete published version
	```shell
	gem yank fastlane-plugin-jira_util -v <version>
	```
