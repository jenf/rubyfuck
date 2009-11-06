class CPUCore
 def initialize()
  @core = CPULoader.new()
  @core.load(ARGV[0])
 end
 def begin
  puts "Start!"
 end
end

class CPULoader
 def initialize()
 end
 
 def load(*args, &block)
  # Convert a parameter to a hash.
  options = args.last.is_a?(Hash) ? args.pop : {}
  args.each { |arg| load options.merge(:file=>arg) }
  return unless args.empty?
  
  if options[:file]
   file = options[:file]
   load :string => File.read(file), :name => options[:name] || file
  elsif options[:string]
   instance_eval(options[:string], options[:name]|| "<eval>")
  end
 end
 
 def opcode(*args,&block)
  options = args.last.is_a?(Hash) ? args.pop : {}
  args.each { |arg| opcode options.merge(:code=>arg) }
  return unless args.empty?
  puts "Defining opcode " + (options.inspect)
 end
 
 def memsize(args)
  puts args.inspect
 end
 def pc(args)
  puts args.inspect
 end
 def register(args)
  puts args.inspect
 end
 def rom(args)
  puts args.inspect
 end
end
