require '../lib/yandex_xml/parsed_response'


RSpec.describe YandexXml:ParsedResponse do

  before do
    @mocks_path = "./spec/mock/"
  end

  it "Should correctly parse errors" do
    xml_string = File.read(@mocks_path + 'response_with_error.xml')
    response = ParsedResponse.new(xml_string)
    expect(response.no_error?).to eql false
    expect(response.error_message).to eql("Искомая комбинация слов нигде не встречается")
  end

  it "Should parse limits" do
    xml_string = File.read(@mocks_path + 'limits.xml')
    response = ParsedResponse.new(xml_string)
    expect(response.limits_day_amount).to eql(0)
    expect(response.limits_by_hours.size).to eql(24)

  end

  context "query results" do

    it "Should parse many groups with few docs in each" do
      xml_string = File.read(@mocks_path + 'many_groups_few_docs.xml')
      response = ParsedResponse.new(xml_string)
      expect(response.found_docs.size).to eql(19)

      # Зачем я написал эти ↓ проверки ??
      #
      expect(response.found_docs[13][:url]).to eql("https://yandex.tm/games/app/171107")
      # Пример поиска позиции домена в результатах поиска
      actual_position = response.found_docs.select do |doc|
        doc[:domain] == "chatovka.net"
      end[0][:pos]
      expect(actual_position).to eql(11)
    end

    it "Should correctly parse only one doc" do
      xml_string = File.read(@mocks_path + 'one_group_one_doc.xml')
      response = ParsedResponse.new(xml_string)

      expect(response.found_docs.size).to eql(1)
    end

    it "Should parse two docs in one group" do
      xml_string = File.read(@mocks_path + 'one_group_two_docs.xml')
      response = ParsedResponse.new(xml_string)
      expect(response.found_docs.size).to eql(2)
    end

  end
end

