namespace :transactions do
  desc "Fetches transactions"

  task fetch: :environment do
    Transactions::Fetch.new.start
  end
end
