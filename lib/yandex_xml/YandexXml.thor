require 'thor'
require './ApiController'

class YandexXml < Thor

  desc "show_limits USER KEY", "Запрос лимитов на ближайшие сутки"
  method_option :by_hours, :aliases => "-h", :desc => "Показать лимиты по часам"

  def show_limits (user, key)
    response = ApiController.new(user, key).limits

    if options[:by_hours] && response.no_error?
      puts "Лимиты по часам:", response.limits_by_hours
    else
      puts response
    end
  end

  # ------------- Всё что ниже тестировалось только с ошибкой (например, неверные вх. данные) -------------

  desc "get_request USER KEY QUERY", "GET-запрос"
  method_option :sortby, :default => "rlv"
  method_option :filter, :default => "none" # Это не все возможные параметры

  def get_request (user, key, query_str)
    response = ApiController.new(user, key).get_query(query_str, options)
    puts response
  end

  desc "get_top_n USER KEY QUERY N", "Показать первые N результатов на поисковый запрос;"
  method_option :sortby, :default => "rlv"
  method_option :filter, :default => "none"

  def get_top_n(user, key, query_str, n)
    raise "n must be Integer" unless n.to_i.to_s == n
    n = n.to_i
    raise "n must be between 1 and 100" if n < 1 || 100 < n

    response = ApiController.new(user, key).get_query(query_str, options)
    if response.no_error?
      puts response.found_docs[0, n]
    else
      puts response
    end
  end

  desc "get_first USER KEY QUERY", "Показать первый результат в выдаче на поисковый запрос"
  method_option :sortby, :default => "rlv"
  method_option :filter, :default => "none"

  def get_first(user, key, query_str)
    response = ApiController.new(user, key).get_query(query_str, options)
    if response.no_error?
      puts response.found_docs.first
    else
      puts response
    end
  end

  desc "get_occurrence_number USER KEY QUERY DOMAIN", "Получить позицию выдачи сайта при определенном поисковом запросе"
  method_option :sortby, :default => "rlv"
  method_option :filter, :default => "none"

  def get_occurrence_number (user, key, query_str, domain)
    response = ApiController.new(user, key).get_query(query_str, options)
    if response.no_error?
      occurrences = response.found_docs.select { |doc| doc[:domain] == domain }
      puts "Позиция сайта: #{occurrences.first[:pos]}"
    else
      puts response
    end
  end

  desc "post_request USER KEY QUERY", "POST-запрос"
  method_option :sortby, :default => 'rlv'
  method_option :maxpassages, :default => '4'
  method_option :page, :default => '0'

  def post_request(user, key, query_str)
    response = ApiController.new(user, key).post_query(query_str, options)
    puts response
  end
end