require 'feature_parser'
require 'pp'
require 'haml'
require 'sass'

require 'step_instance'
require 'step_group'
require 'step_usage'
require 'html_reporter'
require 'text_reporter'
class StepDown

  def initialize(steps_dir, feature_dir, reporter)
    @feature_files = Dir.glob(feature_dir + '/**/*.feature')
    @step_files = Dir.glob(steps_dir + '/**/*.rb')
    @reporter = reporter
  end

  def analyse
    puts "Parsing feature files..."
    parser = FeatureParser.new

    scenarios = []
    @feature_files.each do |feature|
      scenarios << parser.process_feature(feature, instance)
    end
    scenarios.flatten!

    puts "Performing analysis..."
    usages = step_usage(scenarios)
    usages = usages.sort{|a,b| b.total_usage <=> a.total_usage }
    grouping = grouping(scenarios).sort{|a,b| b.use_count <=> a.use_count}

    reporter = reporter(@reporter, scenarios, usages, grouping, instance.steps)
    reporter.output_overview

#    #pp grouping(@scenarios)
#       puts YAML::dump(scenario) if scenario.use_count > 100  &&  scenario.use_count < 500
#    end
  end
 
  # don't want a factory just yet 
  def reporter(type, scenarios, usages, grouping, steps)
    case type
    when "html"
      HTMLReporter.new(scenarios, usages, grouping, steps)
    when "text"
      TextReporter.new(scenarios, usages, grouping, steps)
    end
  end

  def step_usage(scenarios)
    usages = instance.steps.collect{|step| StepUsage.new(step) }
    scenarios.each do |scenario|

      scenario.steps.each do |step|
        usage = usages.detect{|use| use.step.id == step.id}
        usage.total_usage += 1 if usage
      end

      scenario.uniq_steps.each do |step|
        usage = usages.detect{|use| use.step.id == step.id}
        usage.number_scenarios += 1 if usage
      end

    end

    usages.each do |usage|
      if usage.number_scenarios > 0
        use = sprintf "%.2f", (usage.total_usage / Float(usage.number_scenarios))
        usage.use_scenario = use
      end
    end

    usages
  end

  def grouping(scenarios)
    step_groups = instance.steps.collect{|step| StepGroup.new(step) }

    step_groups.each do |step_group|
      scenarios.each do |scenario|
         used = scenario.steps.any?{|s| s.id == step_group.id}

         if used
           scenario.steps.each do |scen_step|
             step_group.add_step(scen_step)
           end
           step_group.update_use_count
         end

      end

    end
    step_groups
  end

  def step(id)
    instance.steps.detect{|step| step.id == id}
  end

  def instance
    @instance ||= begin
      new_inst = StepInstance.new

      Dir.glob(@step_files).each do |file_name|
        new_inst.instance_eval File.read(file_name)
      end
      new_inst
    end
  end
end
