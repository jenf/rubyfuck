
class CPUCore
 def initialize()
  @core = CPULoader.new()
  @core.load(ARGV[0])
 end
 def begin
#  debug @core.inspect
  @core.run
#  puts @core.inspect
 end
end

class CPULoader
 def initialize()
  @opcodes = {}
  @regs = []
 end
 def debug(a)
  #puts a
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
  debug "Defining opcode " + (options.inspect)
  opcode = options[:opcode]
  opcode = opcode[0] if opcode.is_a?(String)
  @opcodes[opcode] = block
 end

 def mem(args)
  @mem="\0" * args[:size]
 end
 def pc(args)
  @pc=args[:start]
  debug args.inspect
 end
 def register(args)
  instance_variable_set(args[:name],0)
  @regs << args[:name]
  debug args.inspect
 end
 def rom(options)
  if options[:file]
   file = options[:file]
   rom :string => File.read(file), :name => options[:name] || file
  elsif options[:string]
   @rom = options[:string]
  end
  debug options.inspect
 end
 
 def run()
  while true
   j = @rom[@pc]
   return if nil == j
   values = {}
   #debug "%x PC: %i %i %i" % [j, @pc, @dp, @mem[@dp]]
   if @opcodes.include?(j)
    #debug @opcodes[j].inspect
    k = @opcodes[j].call
    values.merge(k) if k.is_a?(Hash)
    #debug "Return : " + k.inspect
   end
   @pc+=1 unless values[:no_inc_pc]==true
  end
 end
end
