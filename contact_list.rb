#!/usr/bin/env ruby 

require_relative 'lib/contact'
require_relative 'lib/phone_number'
require 'colorize'

class ContactList

  PER_PAGE = 5

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
      search\t- Search contacts\n
      delete\t- Delete contact\n\n"
    puts menu
  end

  # Check the instant variable @command for possible inputs; routes to the proper method
  def check_command
    case @command
    when 'list' then show_contacts
    when 'new' then add_contact
    when 'find' then get_contact # TODO: Input check
    when 'update' then update_contact
    when 'search' then search_contacts
    when 'delete' then delete_contact
    else 
      puts "\n> Command not recognized"
      show_menu
    end
  end

  # Prints all contacts to the console
  def show_contacts
    page = 0
    contacts = Contact.all(page, PER_PAGE)
    display_contacts(contacts, false)
    wait_for_enter

    while contacts.count > 0
      page += 1
      contacts = Contact.all(page, PER_PAGE)
      if contacts.count == 0
        puts " BYE!\n".colorize(:green)
        return
      end
      display_contacts(contacts, false)
      wait_for_enter
    end
  end

  # Waits for user input and creates a new contact record
  def add_contact
    puts "\n> Enter contact name:".colorize(:yellow)
    name = STDIN.gets.chomp
    puts "\n> Enter contact email:".colorize(:yellow)
    email = STDIN.gets.chomp
    if Contact.uniq_email?(email)
      contact = Contact.create(name, email)
      add_phone_number(contact.id)
      puts "\n> #{name} successfully added to contact list\n".colorize(:green)
    else
      puts "\n> #{email} already exists! Contact not added\n\n".colorize(:red)
    end
  end

  # Takes ID and display contact if it exists
  def get_contact
    contact = [Contact.find(@arg)]
    puts contact.nil? ? "> Contact not found" : display_contacts(contact, false)
  end

  def update_contact
    contact = Contact.find(@arg)
    puts " #{contact.id}: #{contact.name} (#{contact.email})"
    # puts in some asks for these, or CHOOSE A FIELD TO UPDATE
    puts "Update Name:"
    contact.name = STDIN.gets.chomp
    puts "Update Email:"
    contact.email = STDIN.gets.chomp
    contact.save
  end

  def delete_contact
    Contact.destroy(@arg)
  end

  # Takes user input and searches contact list. Outputs all unique entries
  def search_contacts
    contacts = Contact.search(@arg.downcase).uniq
    display_contacts(contacts, false)
  end

  # Takes an array of contacts and a Boolean if paginated and formats the output
  def display_contacts(contacts, paginated)
    puts "\n ID \t NAME \t\t EMAIL".colorize(:yellow)
    contacts.each do |contact| 
      puts "------------------------------------------------------------"
      puts " #{contact.id}\t #{contact.name}\t (#{contact.email})".colorize(:green)
      numbers = contact.phone.each { |el| puts " #{el.label}: #{el.number}"}
    end
    puts "============================================================"
    puts " #{contacts.size} records shown\n\n".colorize(:yellow) unless paginated
  end

  def add_phone_number(contact_id)
    puts " > Would you like to add a phone number? (y/n)".colorize(:yellow)
    input = STDIN.gets.chomp.downcase
    while input == 'y'
      puts "\n> Phone Type (Home/Work/Mobile)".colorize(:yellow)
      label = STDIN.gets.chomp
      puts "\n> Phone Number".colorize(:yellow)
      number = STDIN.gets.chomp
      PhoneNumber.create(label, number, contact_id)

      puts "\nAdd another? (y/n)".colorize(:yellow)
      input = STDIN.gets.chomp.downcase
    end
  end

  # Waits for input from from the user before continuing; returns the input
  def wait_for_enter
    puts "> Press Enter key to continue".colorize(:red)
    STDIN.gets.chomp
  end
end

ContactList.new