class ActionUrlController  < ApplicationController
  respond_to :html, :json
  before_filter :init_agent


  def show
    url=params[:url]
    url='http://'+url unless url.starts_with?('http://')
    begin
      page = @agent.get(url)
      if page.response['content-type'] =~ /image/i
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

end