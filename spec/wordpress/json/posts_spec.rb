RSpec.describe Wordpress::Json::Api do
  before(:all) do
    @client = Wordpress::Json::Api::Client.new(ENV['URL'])
  end

  it 'retrieves all posts' do
    response = @client.get('posts')
    expect(response).to be_kind_of(Array)
  end

  it 'retrieves paginated posts' do
    response = @client.get('posts', params: {page: 1, per_page: 100})
    expect(response).to be_kind_of(Array)
  end

  it 'retrieves all posts' do
    response = @client.all('posts')
    expect(response).to be_kind_of(Array)
  end
end
