require 'pg'

# Represents a person in an address book.
class Contact

  attr_accessor :name, :email
  # Will be nil for a new object - data not stored in the db yet
  attr_reader :id

  # TODO: PG::Connection.new({options}) -- look into the difference
  CONN = PG.connect(
    host: 'localhost',
    dbname: 'contact_list',
    user: 'dev',
    password: 'dev'
  )

  def initialize(name, email, id=nil)
    @name = name
    @email = email
    @id = id # default nil
    # @phone = phone
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
      # Is this redundant? What of .create?
      result = CONN.exec_params("INSERT INTO contact (name, email) VALUES ($1, $2) RETURNING id;", [name, email])
      @id = result[0]['id'].to_i
    end
  end

  def self.destroy(id)
    CONN.exec_params("DELETE FROM contact WHERE id = $1", [id])
    # Don used self.garbage_collection for this -- I think this is wrong
    # THat is, to destory the object instance
  end

  # DEFS: create, all, find, filter, destroy, save

  # Takes an Integer page_num for OFFSET and Integer per_page for LIMIT
  # Returns an Array of Contacts loaded from the database.
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
    # Sanitize data; use exec_params
    result = CONN.exec_params("INSERT INTO contact (name, email) VALUES ($1, $2) RETURNING id;", [name, email])
    contact = self.new(name, email, result[0]['id'].to_i)
  end

  # Returns the contact with the specified id. If no contact has the id, returns nil.
  def self.find(id)
    result = CONN.exec_params('SELECT * FROM contact WHERE id=$1 LIMIT 1;', [id])
    contact = result[0]
    Contact.new(contact['name'], contact['email'], contact['id'])
  end

  # Look into the problem with the key, value inputs here; use string interp for key; but 
  # find a better way
  def self.where(key, value)
    result = CONN.exec_param('SELECT * FROM contact WHERE $1=$2;', [key, value])
    # CALL THE PROCESS METHOD
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
end