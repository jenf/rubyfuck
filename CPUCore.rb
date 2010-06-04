class Array
 def pop_zero
  j=self.pop
  j=0 if j==nil
  return j
 end
 
 def round(x)
  return self[x % self.length]
 end
end

class String
 def round(x)
  return self[x % self.length]
 end
end

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
  @special_mode = []
  @special_modes = {}
  @pc_block = nil
  @pc_args = {}
 end
 def debug(a)
 # puts a
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
  options[:block]=block
  opcode = options[:opcode]
  opcode = opcode[0] if opcode.is_a?(String)
  @opcodes[opcode] = options
 end
 
 def special_mode(*args,&block)
  options = args.last.is_a?(Hash) ? args.pop : {}
  args.each { |arg| special_mode options.merge(:opcode=>arg), &block }
  return unless args.empty?
  debug "Defining special mode " + (options.inspect)
  opcode = options[:opcode]
  opcode = opcode[0] if opcode.is_a?(String)

  @special_modes[opcode] = block
 end

 def mem(args)
  @mem="\0" * args[:size]
 end
 
 def pc(args,&block)
  @pc_args = args
  @pc=args[:start]
  @pc_block = block
  debug args.inspect
 end
 
 def register(args)
  args[:initial] = 0 unless args.include? :initial
  instance_variable_set(args[:name],args[:initial])
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
 
 def push_special_mode(mode)
  @special_mode.push(mode)
  debug "Entering special mode"
 end
 
 def pop_special_mode()
  @special_mode.pop()
  debug "Exiting special mode"
 end
 
 def run()
  while true
   j = @rom[@pc] unless @pc_args.include? :pc_read
   j = @pc_args[:pc_read].call if @pc_args.include? :pc_read
   return if nil == j
   values = {:instruction_size=>1}
   #debug "%x PC: %i %i %i" % [j, @pc, @dp, @mem[@dp]]
   #debug "%c PC: %i %s" % [j, @pc, @stack.inspect]
   if nil != @special_mode[-1]
    debug "Special mode %s" % j
    if @special_modes.include?(@special_mode[-1][0])
      debug @special_modes[j].inspect
      k = @special_modes[@special_mode[-1][0]].call(j)
      values.merge!(k) if k.is_a?(Hash)
      debug "Return : " + k.inspect
     end
   else
     if @opcodes.include?(j)
      values.merge!(@opcodes[j]) # Take the options for this opcode.
      #debug @opcodes[j].inspect
      k = @opcodes[j][:block].call
      values.merge!(k) if k.is_a?(Hash)
      debug "Return : " + k.inspect
     end
   end
   if nil == @pc_block
    @pc+=values[:instruction_size]
   else
    @pc_block.call(values)
   end
  end
 end
end
