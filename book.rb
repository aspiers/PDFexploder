#!/usr/bin/ruby

require 'fileutils'
require 'csv'

require 'tune'

class Book
  attr_reader :name, :directory
  attr_accessor :tunes, :description

  @@all = []

  def initialize(directory, filename, description)
    @directory = directory
    @filename = filename
    @name = filename.sub(/\.pdf$/, '')
    @description = description
    @@all.push self
    @tunes = []
    read_index
    calculate_last_pages
  end

  def self.all
    @@all
  end

  def add_tune(tune)
    @tunes.push tune
  end

  def pdf
    directory + '/' + name + '.pdf'
  end

  def index
    directory + '/' + name + '-index.csv'
  end

  def inspect
    "#<Book:#{name} (#{tunes.length} tunes)>"
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
        Tune.new(name, self, first_page.to_i, last_page ? last_page.to_i : nil)
      end
    end

    tunes.sort!
  end

  def calculate_last_pages
    # Look at the page numbers of adjacent tunes to calculate
    # how many pages each tune occupies
    for i in 0..(tunes.length - 2)
      this_tune = tunes[i]
      next if this_tune.last_page

      # Last page was not specified so figure it out by looking at the
      # page the next tune starts on
      next_tune = tunes[i+1]
      pages_until_next_tune = next_tune.first_page - this_tune.first_page
      num_pages =
        if pages_until_next_tune == 0
          1
        elsif pages_until_next_tune > 6
          raise "WARNING: #{this_tune.name} p#{this_tune.first_page} in #{name} " \
          "followed by #{next_tune.name} p#{next_tune.first_page}"
        else
          pages_until_next_tune
        end
      this_tune.last_page = this_tune.first_page + num_pages - 1
    end
  end

  def explode(split_dir)
    #FileUtils.rm_rf(split_dir)
    Dir.mkdir(split_dir) unless File.directory? split_dir
    $stderr.puts "Exploding #{name} to #{split_dir} ..."
    tunes.each { |tune| tune.extract(split_dir) }
  end
end
