require 'nori'
#require 'nokogiri'

class ParsedResponse
  attr_reader :found_docs, #not sure about name
              :number_of_results,
              :limits_day_amount,
              :limits_by_hours,
              :error_message

  def initialize (xml_string)
    response_hash = Nori.new.parse(xml_string)['yandexsearch']

    # Проверить на ошибку
    @error_message = response_hash['response']['error']
    return unless @error_message.nil?

    # Посчитать лимиты
    if response_hash['response']['limits']
      @limits_by_hours = response_hash['response']['limits']['time_interval']
      @limits_day_amount = 0
      @limits_by_hours.each { |h| @limits_day_amount += h.to_i }
    end

    # -------  Первый вариант подчета лимитов на Nokogiri -----------
    # Здесь из атрибутов достается время для каждого лимита
    # Nori не имеет доступа к атрибутам тегов (вроде)

    # doc = Nokogiri::XML(xml_string)
    # limits = doc.css("response>limits>time-interval")
    # unless limits.empty?
    #   @limits_day_amount = 0
    #   @limits_by_hours = []
    #   limits.each_with_index do |x, i|
    #     @limits_day_amount += x.content.to_i
    #     @limits_by_hours[i] = "#{x.attr('from')[/\d\d:\d\d:\d\d/]} = #{x.content.to_s}"
    #     i += 1
    #   end
    # end

    #Кол-во ответов
    @number_of_results = response_hash['response']['found'][0] unless response_hash['response']['found'].nil?

    # Распарсить страницы
    unless response_hash['response']['results'].nil?
      groups = response_hash['response']['results']['grouping']['group']
      @found_docs = parse_docs(groups)
    end
  end

  # Скорее всего эту функцию надо убрать, но тестировать было удобно
  def to_s
    s = "Ответ от YandexXML:\n"
    s += "ОШИБКА: #{@error_message}\n" unless @error_message.nil?
    s += "Сумма лимитов на сутки: #{@limits_day_amount}\n" unless @limits_day_amount.nil?

    # результаты гет запроса
    s += "Нашлось #{@number_of_results} ответов\n" unless @number_of_results.nil?
    unless @found_docs.nil?
      s += "Информация о страницах: \n"
      @found_docs.each { |doc| s += "#{doc}\n" }
    end
    s
  end

  def no_error?
    @error_message.nil?
  end

  private
  def parse_docs(groups)
    docs = []
    doc_pos = 0
    # Для каждой группы
    groups.each do |group|
      # Для каждой страницы
      group['doc'].each do |doc|
        doc_desc = {
          pos: doc_pos,
          url: doc['url'],
          domain: doc['domain'],
          title: doc['title'],
          modtime: doc['modtime'],
          size: doc['size'],
          charset: doc['charset'],
          lang: doc['properties']['lang']
        }
        doc_pos += 1
        docs << doc_desc
      end
    end
    docs
  end
end