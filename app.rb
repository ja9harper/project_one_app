require 'sinatra/base'
require 'json'
require 'uri'
require 'redis'
require 'date'
require 'pry'
require 'npr'
# require 'nokogiri'
require 'open-uri'
require 'securerandom'
require 'httparty'
require 'uri'
# require 'rss'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions
    set :session_secret, 'super secret'
    uri = URI.parse(ENV["REDISTOGO_URL"])
    $redis = Redis.new
    ({:host => uri.host,
                        :port => uri.port,
                        :password => uri.password})
    @blogs = {
      :blog_title => "Saving for vacation",
      :topic => "Savings",
      :blog_post => "Packing a lunch can really add up. "
    }
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end
  ################################
  #DB Configuration
  ################################
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])
####################################
#TODO Facebook
  APP_ID = "1498608590382223"
  APP_SECRET = "ba6bc01fd56ddb8d76b60313f0207639"
  CALLBACK_URL = "https://www.facebook.com/connect/login_success.html"

#######################################
  #TODO API key for NPR
  NPR.configure do |config|
    config.apiKey         = "MDE2NjE4NjIyMDE0MTAwMzY4NzJkODEyMQ001"
    config.sort           = "date descending"
    config.requiredAssets = "text"
  end

  ########################
  # Routes
  ########################
#provide navigation
  # get ('/') do
#Facebook

#     base_url = "https://www.facebook.com/dialog/oauth?client_id={app-id}
#    &redirect_uri={redirect-uri}"
#     scope = "user"
#     state = SecureRandom.urlsafe_base64
#     session[:state] = state
#     @url = "#{base_url}?client_id=#{APP_ID}&scope=#{scope}&redirect_uri=#{CALLBACK_URL}&state=#{state}"
#     render(:erb, :index)
#   end

#     get('oauth_callback') do
#       puts session
#       state = params[:state]
#       code = params[:code]
# send a POST
#     HTTParty.post("https://www.facebook.com/dialog/oauth/:access_token",
#             :body => {
#               client_id => APP_ID,
#               client_secret => APP_SECRET,
#               code   => code,
#               redirect_uri => CALLBACK_URL
#                },
#             :headers => {
#               "Accept" => "application/json"
#         })
#     session[:access_token] = response[:access_token]
#     #access_token = 2d0ef67365c642f40d6fec7f5a489648
#   redirect to('/')
#   end
#   get('/logout') do
#    session[:access_token] = nil
#    redirect ('/')
#   end


# #goes to a page which prints out all blog entries "R"
  get('/') do
     render(:erb, :index)
   end
#RSS for CNN Money
  # url = 'http://rss.cnn.com/rss/money_pf.rss'

  # open('http://rss.cnn.com/rss/money_pf.rss') do |rss|
  #  feed = RSS::Parser.parse(rss)
  #  puts "Title: #{feed.channel.title}"
  #  feed.items.each do |item|
  #  puts "Item: #{item.title}"

  # end
  get('/blogs') do
    @blogs = []
  #   @blogs = $redis.keys("*blogs*").map { |blog| JSON.parse($redis.get(blog)) }
  #   render(:erb, :index)
  # end
    $redis.smembers("blog_ids").each do |id|
      full_blog_post = $redis.get("blogs:#{id}")
      blog_hash = JSON.parse(full_blog_post)
      @blogs.push(blog_hash)
    render(:erb, :blogs)
  end

# binding.pry

#allow users to submit a new entry "C"

  #POST
  post('/blogs') do
      new_post = {
        :blog_title=> params[:blog_title],
        :topic => params[:topic],
        :blog_post => params[:blog_post]
      }
    id =  $redis.incr("new_blog_id")
    new_post[:id] = id
    $redis.sadd("blog_ids", id)
    $redis.set("blogs:#{id}", new_post.to_json)

    redirect to('/blogs')
  end

  get('/blogs/new') do
    render(:erb, :blog_post)
  end

  post('/blogs/new') do
   new_post = {
        :blog_title=> params[:blog_title],
        :topic => params[:topic],
        :blog_post => params[:blog_post]
      }
    id =  $redis.incr("new_blog_id")
    new_post[:id] = id
    $redis.sadd("blog_ids", id)
    $redis.set("blogs:#{id}", new_post.to_json)

    redirect to('/blogs')
  end

  get('/blogs/:id') do
    requested_post = params[:id]
    post_json = $redis.get("blogs:#{requested_post}")
   @blog = JSON.parse(post_json)
    render(:erb, :blogs)
  end

  get('/blogs/:id/edit') do
    requested_post = params[:id]
    post_json = $redis.get("blogs:#{requested_post}")
   @blog = JSON.parse(post_json)
    render(:erb, :edit)
  end

  # edits blog posting "U"
  put('/blogs/:id/edit') do
    id = params[:id]
    edited_blog = $redis.set("blog_title", "id")
    $redis.set("blogs:#{id}",
      edited_blog.to_json)
    redirect to("/blogs/#{id}")
  end

      # delete a blog post "D"
  delete('/blogs/:id') do
    id = params[:id]
    $redis.del("blogs:#{id}")
    render(:erb, :delete)
    puts 'your post has been deleted'
    redirect to('/blogs')
  end

  #collects users information and personalizes the page
  get('/articles') do
    base_url = "http://api.npr.org/query?id=1018&apiKey=API_KEY"
    @articles = []
    response = HTTParty.get("http://api.npr.org/query?id=1018&apiKey=MDE2NjE4NjIyMDE0MTAwMzY4NzJkODEyMQ001")
    @articles.push(response).to_json
    render(:erb, :articles)
  end

  post('/articles') do
    rel_articles = {
      :query => "1018",
      :API_KEY => "MDE2NjE4NjIyMDE0MTAwMzY4NzJkODEyMQ001"

    }
  end

  get('/sign_up') do
    render(:erb, :sign_up)
  end

  post('/sign_up') do
    new_user = {
      :name => name,
      :email => email
    }

    $redis.set("new_user:#{name}", new_contact.to_json)
  end
  redirect ('/')
  end

  get('/contact') do
    render(:erb, :contact)
  end

  post('/contact') do
    new_contact= {
      :name => name,
      :concerns => concerns
    }
    $redis.set("new_contact:#{name}", new_contact.to_json)
    redirect to('/')
  end
end
#TODO RSS
#turning this thing into an rss feed
# rss = RSS::Maker.make("atom") do |maker|
#   maker.channel.author = "janine"
#   maker.channel.updated = Time.now.to_s
#   maker.channel.about = "http://www.ruby-lang.org/en/feeds/news.rss"
#   maker.channel.title = "Example Feed"

#   maker.items.new_item do |item|
#     item.link = "http://www.ruby-lang.org/en/news/2010/12/25/ruby-1-9-2-p136-is-released/"
#     item.title = "Ruby 1.9.2-p136 is released"
#     item.updated = Time.now.to_s
#   end
#rss url for cnn is http://rss.cnn.com/rss/money_pf.rss
# binding.pry
#   def index
#   end
#   def blogs
#    @blogs
#   end
#   def save(blog)
#   key = "blog:#{blog[:blog_title]}:#{blog[:topic]}"
#   redis.set(key, blog.to_json)
#   end
#   def new
#     @blog = Blog.new
#   end
#   def edit
#   end
# end

#redis=Redis.new
# blogs=Blogs.new
# blogs = {:key, value}
# blogs = blogs.to_json
#redis.set("blog1", hash)
# redis.get("blog1")
# JSON.parse redis.get("blog1")
# blog1{blog_title}

# endpost



