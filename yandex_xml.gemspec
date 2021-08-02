require_relative 'lib/yandex_xml/version'

Gem::Specification.new do |spec|
  spec.name          = "yandex_xml"
  spec.version       = YandexXml::VERSION
  spec.authors       = ["gvterechov"]
  spec.email         = ["123freedom123@mail.ru"]
  spec.executables   = ['yandex_xml']
  spec.summary       = %q{Write a short summary, because RubyGems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/propimo/yandex_xml"
  spec.license       = "MIT"
  spec.bindir        = "bin"
  spec.require_paths = ["./lib"]

  # Здесь всё как было по дефолту
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
end
