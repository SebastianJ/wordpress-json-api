RSpec.describe Wordpress::Json::Api do
  before(:all) do
    raise new ArgumentError, "You have to specify a URL using e.g. URL=https://some.random.url in order to run specs" if ENV.fetch('URL', nil).to_s.empty?
    @client = Wordpress::Json::Api::Client.new(ENV['URL'])
  end

  it 'retrieves all categories' do
    response = @client.get('categories')
    expect(response).to be_kind_of(Array)
  end
end
