require 'net/http'
require './lib/yandex_xml/parsed_response'

require 'nokogiri'

class ApiController
  def initialize(user, key)
    # @user = user
    # @key = key
    @base_url = "https://yandex.ru/search/xml?user=#{user}&key=#{key}"
  end

  def limits
    uri = URI("#{@base_url}&action=limits-info")
    ParsedResponse.new(Net::HTTP.get(uri))
  end

  # ------------- Всё что ниже тестировалось только с ошибкой (например, неверные вх. данные) -------------

  def get_request(options)
    uri = URI.parse("#{@base_url}&#{URI.encode_www_form(options)}")
    response = Net::HTTP.get(uri)
    ParsedResponse.new(response)
  end

  def post_request(options)
    url_options = options["url_options"]
    body_options = options["body_options"]

    if url_options.nil?
      uri = URI.parse("#{@base_url}")
    else
      uri = URI.parse("#{@base_url}&#{URI.encode_www_form(url_options)}")
    end


    xml_string = Nokogiri::XML::Builder.new do |xml|
      xml.request {
        xml.query body_options["query"] if body_options["query"]
        xml.sortby body_options["sortby"] if body_options["sortby"]
        xml.maxpassages body_options["maxpassages"] if body_options["maxpassages"]
        xml.page body_options["page"] if body_options["page"]
        if body_options["groupby"]
          xml.groupings {

            # Я уверен, здесь можно было проще
            if body_options["groupby"]["mode"] == "flat"
              xml.groupby(:attr => "f", :mode => "flat", "groups-on-page" => body_options["groupby"]["groups-on-page"], "docs-in-group" => body_options["groupby"]["docs-in-group"])
            elsif body_options["groupby"]["mode"] == "deep"
              xml.groupby(:attr => "d", :mode => "deep", "groups-on-page" => body_options["groupby"]["groups-on-page"], "docs-in-group" => body_options["groupby"]["docs-in-group"])
            end

          }
        end

      }
    end.to_xml

    # Прсто вставил нагугленный код, не понял как это работает
    request = Net::HTTP::Post.new(uri)
    request.body = xml_string
    request.content_type = 'text/xml'
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }

    ParsedResponse.new(response.body)
  end
end
