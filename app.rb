require 'sinatra/base'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

  ########################
  # Routes
  ########################

  get('/') do
    render(:erb, :index)
  end

  get('/blog') do
    render(:erb, :blog)
  end
  get('/blog/new') do
    render(:erb, :new)
  end
  post('blog/new') do
    new_post
  end
end
