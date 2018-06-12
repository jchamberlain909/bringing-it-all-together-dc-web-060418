class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize (name:, breed:, id:nil)
        @name, @breed, @id = name, breed, id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end 

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end 

    def update 
        sql = <<-SQL
            UPDATE dogs
            SET name=?, breed=?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(dog_hash)
        new_dog = Dog.new (dog_hash)
        new_dog.save
    end 

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        Dog.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name=? AND breed=?
        SQL
        dog = DB[:conn].execute(sql , name, breed)
        if !dog.empty?
            Dog.new(name:dog[0][1],breed:dog[0][2],id:dog[0][0])
        else
            self.create(name:name, breed:breed)
        end
    end 

    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        Dog.new_from_db(DB[:conn].execute(sql,name)[0])

    end


end