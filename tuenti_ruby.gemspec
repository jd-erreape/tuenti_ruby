Gem::Specification.new do |s|
  s.name        = 'tuenti_ruby'
  s.version     = '0.0.0'
  s.date        = '2012-07-03'
  s.summary     = "Tuenti access from Ruby"
  s.description = "Simple access to some of the tuenti functionalities from Ruby"
  s.authors     = ["Juan de Dios Herrero"]
  s.email       = 'juandediosherrero@gmail.com'
  s.files       = ["lib/tuenti_ruby.rb"]
  s.require_paths = ["lib"]
  s.homepage    =
    'http://rubygems.org/gems/tuenti_ruby'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_dependency 'mechanize'

end