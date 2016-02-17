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

  def self.create(label, number, contact_id)
    result = CONN.exec_params("INSERT INTO phone_numbers (label, num, contact_id) VALUES ($1, $2, $3) RETURNING id;", [label, number, contact_id])
    contact = self.new(name, number, contact_id, result[0]['id'].to_i)
  end

  def self.find(contact_id)
    phones = []
    result = CONN.exec_params("SELECT * FROM phone_numbers WHERE contact_id = $1;", [contact_id]) do |res|
      res.each { |el| phones << PhoneNumber.new(el['label'], el['num'], el['id'], el['contact_id']) }
    end
    phones
  end
end