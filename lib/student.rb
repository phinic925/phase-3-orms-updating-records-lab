require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id: nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
    DB[:conn].execute sql
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute sql
  end

  def update name, grade, id
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create name, grade
    student = Student.new name, grade
    student.save
  end

  def self.new_from_db row
    # DB[:conn].execute("SELECT * FROM students WHERE id = ?")
    self.new id: row[0], name: row[1], grade: row[2]
  end

  def self.find_by_name name
    sql = <<-SQL
      select *
      from students
      where name = ?
      limit 1
    SQL

    DB[:conn].execute(sql, name).map { |row| self.new_from_db(row)}.first
  end



end
