#!/usr/bin/ruby

require 'fileutils'
require 'csv'

require 'section'

class Book
  attr_reader :name, :directory
  attr_accessor :sections, :description

  @@all = []

  def initialize(directory, filename, description)
    @directory = directory
    @filename = filename
    @name = filename.sub(/\.pdf$/, '')
    @description = description
    @@all.push self
    @sections = []
    read_index
    calculate_last_pages
  end

  def self.all
    @@all
  end

  def add_section(section)
    @sections.push section
  end

  def pdf
    directory + '/' + name + '.pdf'
  end

  def index
    directory + '/' + name + '-index.csv'
  end

  def inspect
    "#<Book:#{name} (#{sections.length} sections)>"
  end

  def <=>(other)
    @description <=> other.description
  end

  def read_index
    $stderr.puts "Processing #{index} ..."
    File.open(index) do |file|
      file.each_line do |line|
        # $stderr.puts "  #{name}: #{line}"
        next if line =~ /^\s*(#|$)/
        line.chomp!

        begin
          name, first_page, last_page = CSV.parse_line(line)
        rescue CSV::MalformedCSVError => e
          abort "Failed to parse line #{file.lineno} of #{index} (#{e}):\n[#{line}]"
        end
        Section.new(name, self, first_page.to_i, last_page ? last_page.to_i : nil)
      end
    end

    sections.sort!
  end

  def calculate_last_pages
    # Look at the page numbers of adjacent sections to calculate
    # how many pages each section occupies
    for i in 0..(sections.length - 2)
      this_section = sections[i]
      next if this_section.last_page

      # Last page was not specified so figure it out by looking at the
      # page the next section starts on
      next_section = sections[i+1]
      pages_until_next_section = next_section.first_page - this_section.first_page
      num_pages =
        if pages_until_next_section == 0
          1
        elsif pages_until_next_section > 6
          raise "WARNING: #{this_section.name} p#{this_section.first_page} in #{name} " \
          "followed by #{next_section.name} p#{next_section.first_page}"
        else
          pages_until_next_section
        end
      this_section.last_page = this_section.first_page + num_pages - 1
    end
  end

  def explode(split_dir)
    #FileUtils.rm_rf(split_dir)
    Dir.mkdir(split_dir) unless File.directory? split_dir
    $stderr.puts "Exploding #{name} to #{split_dir} ..."
    sections.each { |section| section.extract(split_dir) }
  end
end
