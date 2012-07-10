require 'rubygems'
require 'fog'
require 'base64'
require 'uuid'

class ActionUrlController  < ApplicationController
  respond_to :json
  before_filter :init_agent

  def create
    type=params["type"]
    body=StringIO.new(Base64.decode64(params["data"].gsub(/^data:#{type};base64,/, "")))
    url=publish(body, type)
    render :json => {:success => true, :type=>'image', :url => url}
  end

  def show
    url=params[:url]
    url='http://'+url unless url.starts_with?('http://')
    begin
      page = @agent.get(url)
      if page.response['content-type'] =~ /image/i
        url=publish(page.body, page.response['content-type'])
        render :json => {:success => true, :type=>'image', :url => url}
      end
      if page.response['content-type'] =~ /text/i
        render :json => {:success => true, :type=>'link', :title => page.title}
      end
    rescue
      render :json => {:success => false, :type=>'error', :url => url}
    end
  end

  private

  def init_agent
    unless @agent
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Safari'
    end
  end

  def publish(body, type)
    key=UUID.new.generate
    # create a connection
    connection = Fog::Storage.new({})

    directory = connection.directories.get('actionsimages')

    file=directory.files.create(
      :content_type=> type,
      :body =>  body,
      :key=> key,
      :public => true,
      :storage_class=>'REDUCED_REDUNDANCY'
    )
    file.public_url
  end

end