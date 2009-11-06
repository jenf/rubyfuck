class CPUCore
 def initialize()
  @core = CPULoader.new()
  @core.load(ARGV[0])
 end
 def begin
  puts @core.inspect
  puts "Start!"
 end
end

class CPULoader
 def initialize()
  @opcodes = {}
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
  args.each { |arg| opcode options.merge(:opcode=>arg), &block }
  return unless args.empty?
  puts "Defining opcode " + (options.inspect)
  @opcodes[options[:opcode]] = block
 end

 def mem(args)
  @mem=Array.new(args[:size],0)
 end
 def pc(args)
  @pc=args[:start]
  puts args.inspect
 end
 def register(args)
  instance_variable_set(args[:name],0)
  puts args.inspect
 end
 def rom(options)
  if options[:file]
   file = options[:file]
   rom :string => File.read(file), :name => options[:name] || file
  elsif options[:string]
   @rom = options[:string]
  end
  puts options.inspect
 end
 
 def run()
  
 end
end
