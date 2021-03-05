# frozen_string_literal: true
module Transactions
  class Fetch
    DOWNLOAD_PATH = ENV['DOWNLOAD_PATH']

    def initialize
      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome)
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

      import
    end

    def import
      Dir["#{ENV['DOWNLOAD_PATH']}*.csv"].each do |file_name|
        csv = File.open file_name

        Transactions::FromCsv.import(csv)
      end

      Transaction.where(category: nil).each do |transaction|
        # let's categorise thism manually so we don't confuse transfers
        # if transaction.amount.positive?
        #   transaction.update_attribute(:category, 'income')
        # else
        category = CategoryDetail.find_by(detail: transaction.detail.parameterize)

        transaction.update_attribute(:category, category&.category)
      end
      # TODO: delete files
    end
  end
end
