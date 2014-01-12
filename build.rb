#!/usr/bin/ruby

LIMIT = 0 # use as many pages as required
#LIMIT = 130 # for quick testing
LATEX = '00-index.latex'

require 'csv'
require 'erb'
require 'fileutils'

books_dir = Dir.pwd

require 'book'

abort "Usage: #$0 CSV TEMPLATE OUTDIR" unless ARGV.length == 3
csv_file, template_file, out_dir = ARGV

title = nil
File.open(csv_file) do |csv|
  title = csv.readline.chomp
  csv.each_line do |line|
    next if line =~ /^\s*#/
    filename, description = CSV.parse_line(line)
    Book.new(books_dir, filename, description)
  end
end

template = ERB.new(File.read(template_file), nil, '-')
File.open(LATEX, 'w') do |latex|
  latex.puts template.result(binding)
end

system 'pdflatex', LATEX
Dir.mkdir(out_dir) unless File.directory? out_dir
FileUtils.mv('00-index.pdf', out_dir)

Book.all.each do |book|
  book.explode(out_dir)
end
