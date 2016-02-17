class Contact

  attr_accessor :name, :email, :phone
  attr_reader :id

  CONN = PG.connect(
    host: 'localhost',
    dbname: 'contact_list',
    user: 'dev',
    password: 'dev'
  )

  def initialize(name, email, id=nil)
    @name = name
    @email = email
    @id = id
    @phone = PhoneNumber.find(id)
  end

  # test to see if the object has been saved, based on the whether id is nil or not
  def persisted?
    !id.nil?
  end

  # Save new and save a persisted; depends on self.persisted?
  def save
    if persisted?
      CONN.exec_params("UPDATE contact SET name = $1, email = $2 WHERE id = $3;", [name, email, @id])
    else
      result = CONN.exec_params("INSERT INTO contact (name, email) VALUES ($1, $2) RETURNING id;", [name, email])
      @id = result[0]['id'].to_i
    end
  end

  def self.destroy(id)
    CONN.exec_params("DELETE FROM contact WHERE id = $1", [id])
  end

  # Takes an Integer page_num for OFFSET and Integer per_page for LIMIT. Returns an Array of Contacts loaded from the database.
  def self.all(page_index, per_page)
    contacts = []
    offset = page_index * per_page
    result = CONN.exec_params("SELECT * FROM contact ORDER BY id LIMIT $1 OFFSET $2;", [per_page, offset]) do |res|
      res.each { |el| contacts << Contact.new(el['name'], el['email'], el['id']) }
    end
    contacts
  end

  # Creates a new contact, adding it to the database, returning the new contact.
  def self.create(name, email)
    result = CONN.exec_params("INSERT INTO contact (name, email) VALUES ($1, $2) RETURNING id;", [name, email])
    contact = self.new(name, email, result[0]['id'].to_i)
  end

  # Returns the contact with the specified id. If no contact has the id, returns nil.
  def self.find(id)
    begin
      result = CONN.exec_params('SELECT * FROM contact WHERE id=$1 LIMIT 1;', [id])
      contact = result[0]
      Contact.new(contact['name'], contact['email'], contact['id'])
    rescue IndexError
      "ID does not exist!"
    end
  end

  # Returns an array of contacts who match the given term.
  def self.search(term)
    found = []
    result = CONN.exec_params("SELECT * FROM contact WHERE name LIKE '%#{term}%' OR email LIKE '%#{term}%';") do |res|
      res.each { |el| found << Contact.new(el['name'], el['email'], el['id']) }
    end
    found
  end

  # Take a string email and checks to see of it already exists in the contact_list. Returns boolean
  def self.uniq_email?(email)
    result = CONN.exec_params('SELECT email FROM contact WHERE email = $1 LIMIT 1;', [email])
    true if result.count == 0
  end

  # Takes a String email and returns matching records
  def self.find_by_email(email)
    self.where('email', email)
  end

  # Takes a String name and returns matching records
  def self.find_by_name(name)
    self.where('name', name)
  end

  # Takes Strings key, value and returns matching records
  def self.where(key, value)
    CONN.exec_params("SELECT * FROM contact WHERE #{key} = $1;", [value])
  end
end