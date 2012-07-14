Gem::Specification.new do |s|
  s.name = "ejs"
  s.version = "1.1.2"
  s.summary = "EJS (Embedded JavaScript) template compiler"
  s.description = "Compile and evaluate EJS (Embedded JavaScript) templates from Ruby."

  s.files = Dir["README.md", "LICENSE", "lib/**/*.rb"]

  s.add_development_dependency "execjs", "~> 0.4"

  s.authors = ["Sam Stephenson", "Aaron Blohowiak"]
  s.email = ["sstephenson@gmail.com", "Aaron.Blohowiak@gmail.com"]
  s.homepage = "https://github.com/aaronblohowiak/ruby-ejs/"
end
