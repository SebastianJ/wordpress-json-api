RSpec.describe Wordpress::Json::Api do
  before(:all) do
    @client = Wordpress::Json::Api::Client.new(ENV['URL'])
  end

  it 'retrieves all categories' do
    response = @client.get('categories')
    expect(response).to be_kind_of(Array)
  end
end
