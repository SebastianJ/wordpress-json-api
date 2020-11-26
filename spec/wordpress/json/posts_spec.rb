RSpec.describe Wordpress::Json::Api do
  before(:all) do
    raise new ArgumentError, "You have to specify a URL using e.g. URL=https://some.random.url in order to run specs" if ENV.fetch('URL', nil).to_s.empty?
    @client = Wordpress::Json::Api::Client.new(ENV['URL'])
  end

  it 'retrieves all posts' do
    response = @client.get('posts')
    expect(response).to be_kind_of(Array)
  end

  it 'retrieves paginated posts' do
    response = @client.get('posts', params: {
        query: {
          page: 1,
          per_page: 2
        }
    })
    expect(response).to be_kind_of(Array)
  end
end
