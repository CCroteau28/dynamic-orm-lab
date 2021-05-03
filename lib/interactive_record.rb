require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{table_name});"
    table_info = DB[:conn].execute(sql)
    table_info.map { |column_info| column_info['name'] }.compact
  end

  def initialize(options={})
    options.each do |property, value|
        self.send("#{property}=", value)
    end
end

  def self.find_by(attr)
    key, value = attr.first
    sql = "SELECT * FROM #{self.table_name} WHERE #{key.to_s} = ?"
    DB[:conn].execute(sql, value)
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|c| c == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |name_column|
        values << "'#{send(name_column)}'" unless send(name_column).nil?
    end
    values.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    key, value = hash.first
    sql = "SELECT * FROM #{self.table_name} WHERE #{key.to_s} = ?"
    DB[:conn].execute(sql, value)
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
end