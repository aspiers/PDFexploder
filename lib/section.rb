#!/usr/bin/ruby

class Section
  attr_reader :name, :book, :first_page, :latex_name
  attr_accessor :last_page, :sections

  @@all = []

  def initialize(name, book, first_page, last_page=nil)
    @name = name
    @latex_name = name.gsub(/[#&%]/, "\\\\&") # escape LaTeX meta-characters
    @book = book
    book.add_section self
    @first_page = first_page
    @last_page = last_page
    @@all.push self
  end

  def self.all
    @@all
  end

  def <=>(other)
    @first_page <=> other.first_page
  end

  def filename
    "#{name} (#{book.name} p#{first_page}).pdf".gsub('/', '_')
  end

  def extract(dir)
    outfile = dir + '/' + filename
    if File.exists? outfile
      $stderr.puts "  exists:    #{filename}"
      return
    end

    cmd = [ 'pdfjam', book.pdf, "#{first_page}-#{last_page}", '-o', outfile ]
    system(*cmd)
    abort "pdfjam failed with args #{cmd[1..-1]}" unless $?.success?
    $stderr.puts "  extracted: #{filename}"
  end
end
