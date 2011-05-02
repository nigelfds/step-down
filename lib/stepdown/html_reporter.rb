require 'fileutils'
require 'stepdown/reporter'
require 'haml'
require 'sass'

module Stepdown
  class HTMLReporter < Reporter

    def output_overview()
      puts "Generating report..." unless Stepdown.quiet
      FileUtils.mkdir_p(Reporter::OUTPUT_DIR)
      copy_files

      template = File.open(File.expand_path(File.dirname(__FILE__)) + '/../../templates/main.html.haml').read()
      engine = Haml::Engine.new(template)

      out = File.new(Reporter::OUTPUT_DIR + '/analysis.html','w+')
      out.puts engine.render(self)
      out.close

      template = File.open(File.expand_path(File.dirname(__FILE__))  + '/../../templates/style.sass').read
      sass_engine = Sass::Engine.new(template)

      out = File.new(Reporter::OUTPUT_DIR + '/style.css', 'w+')
      out.puts sass_engine.render

      out.close

      puts "\nReport output to #{Reporter::OUTPUT_DIR}/analysis.html" unless Stepdown.quiet
    end

    protected

    def copy_files
      ['step_down.js', 'jquery-1.4.3.min.js'].each do |file|
        src = File.expand_path("#{File.dirname(__FILE__)}/../../public/#{file}")
        FileUtils.cp(src, File.join(OUTPUT_DIR, "#{file}"))
      end
    end
  end
end
