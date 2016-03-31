#!/usr/bin/ruby

LIMIT = 0 # use as many pages as required
#LIMIT = 130 # for quick testing
LATEX = '00-index.latex'

require 'csv'
require 'erb'
require 'fileutils'
require 'tmpdir'

books_dir = Dir.pwd

require 'book'

unless ARGV.length == 5
  abort "Usage: #$0 CSV TEMPLATE PDF-DIR INDEX-DIR OUTPUT-DIR"
end

csv_file, template_file, pdf_dir, index_dir, out_dir = ARGV

title = nil
File.open(csv_file) do |csv|
  title = csv.readline.chomp
  csv.each_line do |line|
    next if line =~ /^\s*#/
    book_name, description = CSV.parse_line(line)
    book_name.sub!(/\.pdf$/, '')
    filename = "#{pdf_dir}/#{book_name}.pdf"
    index_filename = "#{index_dir}/#{book_name}.csv"
    book = Book.new(filename, index_filename, description)
    book.missing_pages.tap do |missing|
      if missing.empty?
        puts "no missing pages in #{book.name}!"
      else
        puts "%s is missing pages: %s" % [book.name, missing.join(", ")]
      end
    end
  end
end

template = ERB.new(File.read(template_file), nil, '-')
Dir.mktmpdir do |tmpdir|
  puts tmpdir
  File.open(tmpdir + '/' + LATEX, 'w') do |latex|
    latex.puts template.result(binding)
  end

  Dir.chdir(tmpdir)
  system 'pdflatex', LATEX
  Dir.mkdir(out_dir) unless File.directory? out_dir
  FileUtils.mv('00-index.pdf', out_dir)
end

Book.all.each do |book|
  book.explode(out_dir)
end
