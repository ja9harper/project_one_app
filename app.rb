require 'sinatra/base'
require 'json'
require 'uri'
require 'redis'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions
    uri = URI.parse(ENV["REDISTOGO_URL"])
    $redis = Redis.new({:host => uri.host,
                        :port => uri.port,
                        :password => uri.password})
    @blogs = []
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])

  API_KEY= "MDE2NjE4NjIyMDE0MTAwMzY4NzJkODEyMQ001"
  ########################
  # Routes
  ########################
#provide navigation
  get('/') do
    render(:erb, :index)
  end
#goes to a page which prints out all blog entries
#GET ('/')
  get('/blogs') do
    @blogs
    render(:erb, :blogs)
  end

#allow users to submit a new entry
  get('/blog/new') do
    render(:erb, :blogs)
    redirect to('/')
  end
  post('/blog/new') do
    new_post = {
      :name => name,
      :topic => topic,
      :blog_title=> blog_title,
      :blog_post => blog_post
    }
    new_post.to_json
    @blogs.push(new_post)
  end
  # get('blog/:id')
  # requested_post = params[:id]
  # end
  #allow users to delete a blog post

   delete('/blog/:id') do
    id = params[:id]
    $redis.del("blog_title")
    redirect to('/')
  end
  #collects users information and personalizes the page
  get('contact') do
    render(:erb, :contact)
  end
end

#redis=Redis.new
# hash=Hash.new
# hash = {:key, value}
# hash = hash.to_json
#redis.set("post1", hash)
# redis.get("post1")
# JSON.parse redis.get("post1")
# post1{title}

# endpost


