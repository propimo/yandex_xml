require 'net/http'
require './lib/yandex_xml/parsed_response'
#require '../yandex_xml/parsed_response'

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

  # Пока что в ответе выдает "ОШИБКА: Start tag expected, '<' not found"
  def post_request(query_str, options)
    uri = URI.parse(@base_url)
    response = Net::HTTP.post_form(uri,
                              'query'=>:query_str,
                              'sortby'=>options[:sortby],
                              'maxpassages'=>options[:maxpassages],
                              'page'=>options[:page]) # еще один возможный параметр - groupby

    ParsedResponse.new(response.body)
  end
end
