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
    return unless response_hash # Выход, если xml пустой

    # Проверить на ошибку
    @error_message = response_hash['response']['error']
    return if error? # Выход, если ошибка

    # Посчитать лимиты
    if response_hash['response']['limits']
      limits_without_timestamps = response_hash['response']['limits']['time_interval']

      # Сумма на сутки
      @limits_day_amount = 0
      limits_without_timestamps.each do |h|
        @limits_day_amount += h.to_i
      end

      # Здесь трудно будет понять что происходит, поэтому напишу много комментариев
      # Возможно, надо было всё-таки парсить лимиты на Nokogiri (ниже)
      #
      # В исходном xml все лимиты передаются по часам
      # С яндекса лимиты всегда приходили в одном и том же порядке, начиная с 21 часа
      # В их документации об этом ни слова
      #
      # Xml-фрагмент первого лимита в списке:
      # <time-interval from="2021-07-22 21:00:00 +0000" to="2021-07-22 22:00:00 +0000">0</time-interval>
      # Время, видимо, лондонское, но я менять не стал
      @limits_by_hours = Hash.new
      hour = 21
      limits_without_timestamps.each do |l|
        @limits_by_hours["#{hour}:00-#{hour + 1}:00"] = l.to_i
        hour += 1
        hour = 0 if hour == 24
      end

      # -------  Первый вариант подчета лимитов на Nokogiri -----------
      # Здесь из атрибутов достается время для каждого лимита

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

    end

    #Кол-во ответов
    if response_hash['response']['found']
      @number_of_results = response_hash['response']['found'][0]
    end

    # Распарсить страницы
    if response_hash['response']['results']
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

  def error?
    !@error_message.nil?
  end

  private
  def parse_docs(groups)
    docs = []
    doc_pos = 0
    # Для каждой группы
    groups.each do |group|
      # Для каждой страницы
      group['doc'].each do |doc|
        #TODO? Ошибка, если в ответе только один док
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
