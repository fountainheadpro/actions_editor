class ActionUrlController  < ApplicationController
  respond_to :html, :json

  def show
    url=params[:url]
    url='http://'+url unless url.starts_with?('http://')
    #url=url.gsub("_", ".")
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'
    page = @agent.get(url)
    render :json => {:success => true, :title => page.title}
  end

end