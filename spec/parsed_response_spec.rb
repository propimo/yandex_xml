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
    # # TODO? Ошибка в ParsedResponse::parse_docs()
    # it "Should parse only one query result" do
    #   xml_string = File.read(@mocks_path + 'one_result.xml')
    #   response = ParsedResponse.new(xml_string)
    #   puts response.inspect
    # end

    it "Should parse many query results" do
      xml_string = File.read(@mocks_path + 'few_results.xml')
      response = ParsedResponse.new(xml_string)
      expect(response.found_docs.size).to eql(4)
      expect(response.found_docs[0][:url]).to eql("https://www.yandex.ru/")
    end

  end
end

