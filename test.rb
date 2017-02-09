this_file_path = File.expand_path(File.dirname(__FILE__))
Dir["#{File.join(this_file_path, 'test')}/**/*_test.rb"].each { |file| require file }

