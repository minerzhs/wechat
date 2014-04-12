class XiniosController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :check_xinio_legality

  def show
    render :text => params[:echostr]
  end

  def create
    if params[:xml][:MsgType] == "text"
      render "reply", :formats => :xml
    end
  end

  def reply
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.xml{
        xml.ToUserName <![CDATA[params[:xml][:FromUserName]]]>
        xml.FromUserName <![CDATA[params[:xml][:ToUserName]]]>
        xml.CreateTime Time.now.to_i
        xml.MsgType <![CDATA[text]]>
        xml.Content <![CDATA["This is the reply test"]]>
      }
    end
    puts builder.to_xml
  end

  private
  def check_xinio_legality
    array = [Rails.configuration.xinio_token, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
