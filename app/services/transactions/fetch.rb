# frozen_string_literal: true

module Transactions
  class Fetch
    def initialize
      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(app, :browser => :chrome)
      end

      Capybara.javascript_driver = :chrome
    end

    def start
      session = Capybara::Session.new(:chrome)
      session.visit(ENV['URL'])
      sleep(5)
      session.find('input#user-id').set(ENV['ID'])
      sleep(5)
      session.find('input#password').set(ENV['PASSWORD'])
      sleep(5)
      session.find('button#submit').click
      sleep(5)

      session.find_link('Go').click
      sleep(20)
      session.find_button('Export').click
      sleep(5)
      session.find('button#transaction-export-submit').click
      sleep(5)
      session.go_back
      sleep(5)

      session.find_link('Freedom').click
      sleep(20)
      session.find_button('Export').click
      sleep(5)
      session.find('button#transaction-export-submit').click
      sleep(5)
      session.go_back
      sleep(5)

      session.find_link('Airpoints Visa').click
      sleep(20)
      session.find_button('Export').click
      sleep(5)
      session.find('button#transaction-export-submit').click
      sleep(5)
    end
  end
end
