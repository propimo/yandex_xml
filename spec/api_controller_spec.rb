require '../lib/yandex_xml/api_controller'

RSpec.describe YandexXml:ApiController do
  context "limits" do
    it "Should catch errors" do
      response = ApiController.new("Wrong user name", "Wrong key").limits
      expect(response.error_message).to eql("Версия ключа 'Wrong key' неверна")
    end

    it "Should get limits by hours and day amount of limits" do
      response = ApiController.new("kostyabot", "03.555764076:c8258c4b1fca68e6ceaf70943489628f").limits
      expect(response.limits_day_amount).to eql(0)
      expect(response.limits_by_hours.size).to eql(24)
    end

  end
end
