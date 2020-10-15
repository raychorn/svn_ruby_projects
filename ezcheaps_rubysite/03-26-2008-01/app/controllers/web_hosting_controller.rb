class WebHostingController < ApplicationController
  def index
    render:text => 'Welcome to the Hosting Page.'
  end
  def show
    render:text => 'Welcome to the Hosting Page (show).'
  end
end
