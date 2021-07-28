def print_response(response, extra_params)
  if extra_params[:show_number_of_results]
    puts "Кол-во результатов: #{response.number_of_results}"
  end

  if extra_params[:first]
    puts "Первый результат запроса:"
    puts response.found_docs.first
  end

  if extra_params[:show_top]
    n = extra_params[:show_top]
    puts "Первые #{n} результатов:"
    puts response.found_docs[0, n]
  end

  if extra_params[:show_all]
    puts "Все результаты: "
    puts response.found_docs
  end

  if extra_params[:show_pos_of]
    all_occurrences = response.found_docs.select do |doc|
      doc[:domain] == extra_params[:show_pos_of]
    end
    puts "Позиция #{extra_params[:show_pos_of]}:"
    if all_occurrences.first
      puts all_occurrences.first[:pos]
    else
      puts "nil"
    end
  end

end
