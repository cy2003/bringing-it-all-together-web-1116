require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id:nil, name:, breed:)
    #by putting the colon after the attribute you're giving a key/value pair
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    # self.name and self.breed are the values added to the SQL string
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM Dogs
      WHERE id = ?
      SQL

    dog_info = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(dog_info)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(array)
    hash = {
      id: array[0],
      name: array[1],
      breed: array[2]
    }
    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM Dogs
      WHERE name = ?
      SQL

    dog_info = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(dog_info)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
