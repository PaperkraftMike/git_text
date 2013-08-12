require 'rubygems'
require 'github_api'
require 'chronic'
require 'bundler/setup'
require 'sinatra/activerecord'
require 'appscript'
require 'yaml'
require 'twilio-ruby'
require './models'

twilio_sid = ENV['TWILIO_ACCOUNT_SID']
twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']

ActiveRecord::Base.establish_connection "sqlite3:///git_text.sqlite3"

@client = Twilio::REST::Client.new(twilio_sid.to_s.strip, twilio_auth_token.to_s.strip)

settings = YAML.load_file(File.open('git_text.yml'))

def text_issue(settings)
  issues = github_query(settings)
   unless issues.nil?
    issues.body.each do |issue|
      number_milestone = "##{issue.number} #{('MS-'+ issue.milestone.title) if !issue.milestone.nil? && !issue.milestone.title.nil?}"
      @client.account.sms.messages.create({
        :from => ENV['TWILIO_NUMBER'],
        :to =>   ENV['RECIPIANT_NUMBER'],
        :body => "TO: #{issue.assignee.login} #{number_milestone} #{issue.title} #{Chronic.parse(issue.updated_at).in_time_zone(-5).strftime("%m/%d/%Y at%l:%M %p")}" 
      })
    end
  end
end

def text_latest(settings, first_run)
  puts "git_print is running..." unless first_run == false
  issues = github_query(settings)
  unless issues.nil?
    issues.body.each do |issue|
      number_milestone = "##{issue.number} #{('MS-'+ issue.milestone.title) if !issue.milestone.nil? && !issue.milestone.title.nil?}"
      begin
        db_issue = Issue.where(:number => issue.number).first
        if db_issue.updated_at.in_time_zone(-5) < issue.updated_at.in_time_zone(-5)
          text_issue(settings) unless first_run
          db_issue.updated_at = issue.updated_at.in_time_zone(-5)
          db_issue.save
        end
      rescue
          text_issue(settings) unless first_run
          Issue.create(number: issue.number, title: issue.title, body: issue.body, updated_at: Chronic.parse(issue.updated_at))
      end
    end
    puts "github fetch complete"
  else
    puts "github fetch empty"
  end
  sleep(10)
  text_latest(settings, false)
end
  

def github_query(settings)
  begin
    github = Github.new login: ENV['GITHUB_USERNAME'], password: ENV['GITHUB_PASSWORD']
    issues = github.issues.list(repo: settings["repo"], user: settings["user"], filter: settings["filter"], assignee: settings["assignee"])
  rescue
    sleep(10)
    github_query(settings)
  end
  issues
end

text_latest(settings, true)


