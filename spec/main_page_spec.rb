 require 'spec_helper'

 it "should render an index page" do
    get '/'
    response.should be_ok
    response.body.should include('Welcome')
  end

  it "should allow user to post a new blog" do
    get '/blogs'
    response.should be_ok
    response.body.should include('blog')
