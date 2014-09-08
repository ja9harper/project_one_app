require 'sinatra/base'
require 'json'
require 'uri'
require 'redis'
require 'date'
require 'pry'


class App < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions
    uri = URI.parse(ENV["REDISTOGO_URL"])
    $redis = Redis.new
    #({:host => uri.host,
    #                     :port => uri.port,
    #                     :password => uri.password})
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
#API key for NPR
  API_KEY= "MDE2NjE4NjIyMDE0MTAwMzY4NzJkODEyMQ001"
  ########################
  # Routes
  ########################
#provide navigation
# get GET

  get('/') do

    render(:erb, :index)
  end
#goes to a page which prints out all blog entries "R"
#GET ('/')
  get('/blogs') do
    @blogs = []
    $redis.smembers("blog_ids").each do |id|
      full_blog_post = $redis.get("blogs:#{id}")
      blog_hash = JSON.parse(full_blog_post)
      @blogs.push(blog_hash)
    end
    render(:erb, :blogs)

  end
# binding.pry
  # get('/blog/new') do
  #   render(:erb, :blogs)
  #   redirect to('/')
  # end


#allow users to submit a new entry "C"

  #POST

  post('/blogs') do
    new_post = {
      :blog_title=> params[:blog_title],
      :topic => params[:topic],
      :blog_post => params[:blog_post]
    }
    id =  $redis.incr("new_blog_id")
    $redis.sadd("blog_ids", id)
    $redis.set("blogs:#{id}", new_post.to_json)

    redirect to('/blogs')
  end

  get('/blog/:id') do
    requested_post = params[:id]
    post_json = $redis.get("blogs:#{requested_post}")
   @blog = JSON.parse(post_json)

    render(:erb, :blog_post)
  end



  # # edits blog posting "U"
  #  put("/blog/:id/edit") do
  #   id = params[:id]
  #   edited_blog = $redis(blog_title: blog_title, id: id)
  #   $redis.set("blogs:#{id}",
  #     edited_blog.to_json)
  #   redirect to("/blogs/#{id}")
  # end

      # delete a blog post "D"
  delete('/blog/:id/delete') do
    id = params[:id]
    $redis.del("blogs:#{id}")
    redirect to('/')
  end
  #collects users information and personalizes the page

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
  get('/articles') do
    @articles = []
    response = $redis.get("http://api.npr.org/query?id=1018&apiKey=API_KEY")
    @articles = JSON.parse(response)
    render(:erb , :articles)
  end
  def index
  end
  def blogs
   @blogs
  end
  def save(blog)
  key = "blog:#{blog[:blog_title]}:#{blog[:topic]}"
  redis.set(key, blog.to_json)
  end
  def new
    @blog = Blog.new
  end
  def edit
  end
end

#redis=Redis.new
# blogs=Blogs.new
# blogs = {:key, value}
# blogs = blogs.to_json
#redis.set("blog1", hash)
# redis.get("blog1")
# JSON.parse redis.get("blog1")
# blog1{blog_title}

# endpost


