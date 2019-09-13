Gem::Specification.new do |s|
  s.name        = "mongoid_alize"
  s.version     = "1.0.0"
  s.author      = "Josh Dzielak"
  s.email       = "jdzielak@gmail.com"
  s.homepage    = "https://github.com/dzello/mongoid_alize"
  s.summary     = "Comprehensive field denormalization for Mongoid that stays in sync."
  s.description = "Keep data in sync as you denormalize across any type of relation."
  s.license     = "MIT"

  s.files        = Dir["{config,lib,spec}/**/*"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'mongoid', ">= 7.0"
  s.add_dependency "mongoid-compatibility"
  s.add_development_dependency 'rspec', '~> 2.6.0'
end
