class PhoneNumber

  attr_accessor :label, :number, :contact_id
  attr_reader :id

  # THIS SHOULD ONLY BE IN ONE PLACE
  CONN = PG.connect(
    host: 'localhost',
    dbname: 'contact_list',
    user: 'dev',
    password: 'dev'
  )

  def initialize(label, number, contact_id, id=nil)
    @label = label
    @number = number
    @contact_id = contact_id
  end

  # TODO: Finish this method
  def save
    if persisted?
      CONN.exec_params("UPDATE phone_numbers SET label = $1, number = $2 WHERE id = $3;", [label, number, @id])
    else
      result = CONN.exec_params("INSERT INTO phone_numbers (label, num) VALUES ($1, $2) RETURNING id;", [label, number])
      @id = result[0]['id'].to_i
    end    
  end

  def self.create(label, number, contact_id)
    result = CONN.exec_params("INSERT INTO phone_numbers (label, num, contact_id) VALUES ($1, $2, $3) RETURNING id;", [label, number, contact_id])
    contact = self.new(name, number, contact_id, result[0]['id'].to_i)
  end

  def self.find(contact_id)
    phones = []
    # result = CONN.exec_params("SELECT * FROM phone_numbers INNER JOIN contact ON contact_id = contact.id;") do |res|
    result = CONN.exec_params("SELECT * FROM phone_numbers WHERE contact_id = $1;", [contact_id]) do |res|
      res.each { |el| phones << PhoneNumber.new(el['label'], el['num'], el['id'], el['contact_id']) }
    end
    phones
  end

  def self.destroy(id)
    CONN.exec_params("DELETE FROM phone_number WHERE id = $1", [id])
  end

end