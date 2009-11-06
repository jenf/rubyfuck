class CPUCore
 def initialize()
  @core = CPULoader.new()
  @core.load(ARGV[0])
 end
 def begin
  puts @core.inspect
  @core.run
#  puts @core.inspect
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
  opcode = options[:opcode]
  opcode = opcode[0] if opcode.is_a?(String)
  @opcodes[opcode] = block
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
  while true
   j = @rom[@pc]
   return if nil == j
   values = {}
   #puts "%x PC: %i" % [j, @pc]
   if @opcodes.include?(j)
    #puts @opcodes[j].inspect
    k = @opcodes[j].call
    values.merge(k) if k.is_a?(Hash)
    #puts "Return : " + k.inspect
   end
   @pc+=1 unless values[:no_inc_pc]==true
  end
 end
end
