
befunge98=true

# Jumps & Core
opcode '"' do push_special_mode("\"") end
special_mode '"' do |x|
 @stack.push(x) unless x=='"'[0]
 debug @stack.inspect
 pop_special_mode if x=='"'[0]
end

opcode "@" do exit end
opcode ">" do @pc_direction=[1,0] end
opcode "<" do @pc_direction=[-1,0] end
opcode "^" do @pc_direction=[0,-1] end
opcode "v" do @pc_direction=[0,1] end

opcode "?" do
 j=rand(4)
 @pc_direction= case j
  when 0 then [0,-1]
  when 1 then [0,1]
  when 2 then [1,0]
  else [-1,0]
 end
end

# Conditional Jumps
opcode "_" do
 k=@stack.pop_zero # This isn't specified but appears to be the behaviour.
 @pc_direction = [-1,0] if k!=0
 @pc_direction = [1,0] if k==0
end
opcode "|" do
 k=@stack.pop_zero # This isn't specified but appears to be the behaviour.
 @pc_direction = [0,-1] if k!=0
 @pc_direction = [0,1] if k==0
end

opcode "#",:instruction_size=>2 do end # Do nothing

# IO
opcode "," do
 $stdout.putc @stack.pop
 $stdout.flush
end
opcode "." do
 $stdout.puts "%i" % @stack.pop_zero
 $stdout.flush
end
opcode "~" do
 a = $stdin.getc
 a = 0 if a == nil
 @stack.push(a)
end

opcode '0' do @stack.push(0) end
opcode '1' do @stack.push(1) end
opcode '2' do @stack.push(2) end
opcode '3' do @stack.push(3) end
opcode '4' do @stack.push(4) end
opcode '5' do @stack.push(5) end
opcode '6' do @stack.push(6) end
opcode '7' do @stack.push(7) end
opcode '8' do @stack.push(8) end
opcode '9' do @stack.push(9) end

# Get and put
opcode 'g' do
 y=@stack.pop_zero
 x=@stack.pop_zero
 @stack.push(@rom.round(y).round(x))
 debug "Get %i from %i %i" % [@stack[-1],x,y]
end
opcode 'p' do
 y=@stack.pop_zero
 x=@stack.pop_zero
 value=@stack.pop_zero
 debug "Put %i to %i %i (prev %i)" % [value,x,y,@rom.round(y).round(x)]
 a=@rom[y % @rom.length]
 a[x % a.length] = value
end

# Logic
opcode '`' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push 1 if b>a
 @stack.push 0 unless b>a
end
opcode '!' do
 a=@stack.pop_zero
 @stack.push 0 if a!=0
 @stack.push 1 if a==0
end

# Stack manipulations
opcode ":" do @stack.push(@stack[-1]) end
opcode "$" do @stack.pop end
opcode "\\" do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push(a)
 @stack.push(b)
end

# Math
opcode '+' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push(b+a)
end
opcode '-' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push(b-a)
end
opcode '*' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push(b*a)
end
opcode '/' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push(b/a) if a!=0
 @stack.push(0)   if a==0
end

opcode '%' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push(b % a) if a!=0
 @stack.push(0)     if a==0
end


opcode ' ' do end # Noop

# Befunge 98 extensions
if befunge98
 opcode 'a' do @stack.push(0xa) end
 opcode 'b' do @stack.push(0xb) end
 opcode 'c' do @stack.push(0xc) end
 opcode 'd' do @stack.push(0xd) end
 opcode 'e' do @stack.push(0xe) end
 opcode 'f' do @stack.push(0xf) end
 opcode 'n' do @stack=[] end
 opcode 'z' do end # Noop
 opcode 'r' do @pc_direction = [-@pc_direction[0],-@pc_direction[1]] end
 
 opcode ';' do push_special_mode(";") end
 special_mode ';' do |x|
  pop_special_mode if x==';'[0]
 end
 
 opcode '\'',:instruction_size=>2 do
  @stack.push(@rom.round(@pc[1]+@pc_direction[1]).round(@pc[0]+@pc_direction[0]))
 end
 opcode 's',:instruction_size=>2 do
  a=@rom[(@pc[1]+@pc_direction[1]) % @rom.length]
  a[(@pc[0]+@pc_direction[0]) % a.length] = @stack.pop
 end
 opcode 'k' do
  @interate=@stack.pop
 end
end

pc_read = Proc.new {

 a=@rom.round(@pc[1]).round(@pc[0])
 debug "%c PC: %s %s" % [a, @pc.inspect, @stack.inspect]
# sleep(0.1)
 a

}

pc :start=>[0,0], :pc_read=>pc_read do |values|
 if @iterate == 0
 times=values[:instruction_size]
 vertical = @pc_direction[1]
 horizontal = @pc_direction[0]
 @pc[0]+=horizontal*times
 @pc[1]+=vertical*times
 else
  @iterate -=1
 end
end

h=IO.readlines(ARGV[1]).collect {|line| line.chomp}

# Find the maximum length to allow negatives to work correctly
max = 0
h.each {|x|
v = x.length
max = v if v>max
}

h.map! {|x|
 x=x+(" "*(max-x.length))
}
rom :string=>h,:invisible_codespace=>true
register :name=>:@iterate,:initial=>0 # Repeat the next instruction iterator
register :name=>:@stack,:initial=>[]
register :name=>:@pc_direction,:initial=>:right