require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
    self.column_names.each do |name_columns|
        attr_accessor name_columns.to_sym
    end
end
