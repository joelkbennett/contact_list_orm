#!/usr/bin/env ruby 

require_relative 'contact'

class ContactList

  PAGINATE = 5

  def initialize
    return show_menu if ARGV.empty?
    @command = ARGV[0]
    @arg = ARGV[1] unless ARGV[1] == nil
    check_command
  end

private

  # Print a list of available commands
  def show_menu
    menu = "\n Available Commands:
             new\t- Create a new contact
             list\t- List all contacts
             show\t- Show a contact
             search\t- Search contacts\n\n"
    puts menu
  end

  # Check the instant variable @command for possible inputs; routes to the proper method
  def check_command
    case @command
    when 'list' then show_contacts
    when 'new' then add_contact
    when 'find' then get_contact # TODO: Input check
    when 'search' then search_contacts
    else 
      puts "\n> Command not recognized"
      show_menu
    end
  end

  # Prints all contacts to the console -- I'd prefer to call this all_contacts
  def show_contacts
    contacts = Contact.all
    contacts.size <= 5 ? display_contacts(contacts, false) : paginate(contacts, PAGINATE)
  end

  # Waits for user input and creates a new contact record
  def add_contact
    puts "> Enter contact name:"
    name = STDIN.gets.chomp
    puts "> Enter contact email:"
    email = STDIN.gets.chomp
    if Contact.uniq_email?(email)
      phone_nums = []
      puts "> Would you like to add a phone number? Y/N"
      add_num = STDIN.gets.chomp.downcase
      while add_num == 'y' do
        (phone_nums << add_phone_number)
        puts "> Add another? Y/N"
        add_num = STDIN.gets.chomp
      end
      Contact.create(name, email, phone_nums)
      puts "> #{name} successfully added to contact list"
    else
      puts "> #{email} already exists! Contact not added"
    end
  end

  # Takes ID and display contact if it exists
  def get_contact
    contact = Contact.find(@arg)
    puts contact.nil? ? "> Contact not found" : " #{contact[1]} (#{contact[2]})"
  end

  # Takes user input and searches contact list. Outputs all unique entries
  def search_contacts
    contacts = Contact.search(@arg.downcase).uniq
    display_contacts(contacts, false)
  end

  # Takes an array of contacts and a Boolean if paginated and formats the output
  def display_contacts(contacts, paginated)
    contacts.each do |contact| 
      contact_str = " %{id}: %{name} (%{email}), (%{phone})"
      puts contact_str % contact
    end
    puts "---\n #{contacts.size} records total\n\n" unless paginated
  end

  def add_phone_number
    puts "> Phone Type (Home/Work/Mobile)"
    type = STDIN.gets.chomp.to_sym
    puts "> Phone Number"
    number = STDIN.gets.chomp
    {type => number}
  end

  # Take an array of contacts and paginates through them; returns nil
  def paginate(contacts, num_per_page)
    system "clear"
    pages = contacts.each_slice(num_per_page).to_a

    # # TODO: Future feature - Add forward and back navigation
    last_page = pages.count
    current_page = 0
    
    puts "> Page #{current_page + 1} of #{last_page}\n\n"

    # Display the first page
    page = pages[current_page]
    display_contacts(page, true)

    # Wait for initial input; Only go forward
    puts"\n> Hit N for next page anything else to quit"
    page_input = STDIN.gets.chomp
    while page_input.downcase != 'q'
      system('clear')
      # Display the previous page
      if page_input.downcase == 'p'
        current_page -= 1
        return if current_page < 0
        page = pages[current_page]
        puts "> Page #{current_page + 1} of #{pages.count}\n\n"
        display_contacts(page, true)
        puts"\n> Hit N for next page, P for previous page or Q quit"
        page_input = STDIN.gets.chomp
      # Display the next page on all other input
      elsif page_input.downcase == 'n'
        current_page += 1
        return if current_page >= last_page
        page = pages[current_page]
        puts "> Page #{current_page + 1} of #{pages.count}\n\n"
        display_contacts(page, true)
        puts"\n> Hit N for next page, P for previous page or Q to quit"
        page_input = STDIN.gets.chomp
      end
    end
    show_exit_message 
  end

  def show_exit_message
    puts "\n> Bye!\n\n"
  end

  # Waits for input from from the user before continuing; returns the input
  def wait_for_enter
    puts "\n> Press Enter key to continue"
    STDIN.gets.chomp
  end
end

ContactList.new