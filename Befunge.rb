# Jumps & Core
opcode '"' do push_special_mode("\"") end
opcode "@" do exit end
opcode ">" do @pc_direction=:right end
opcode "<" do @pc_direction=:left end
opcode "^" do @pc_direction=:up end
opcode "v" do @pc_direction=:down end

opcode "?" do
 j=rand(4)
 @pc_direction= case j
  when 0 then :right
  when 1 then :left
  when 2 then :up
  else :down
 end
end

# Conditional Jumps
opcode "_" do
 k=@stack.pop_zero # This isn't specified but appears to be the behaviour.
 @pc_direction = :left if k!=0
 @pc_direction = :right if k==0
end
opcode "|" do
 k=@stack.pop_zero # This isn't specified but appears to be the behaviour.
 @pc_direction = :up if k!=0
 @pc_direction = :down if k==0
end

opcode "#" do {:repeat_pc=>2} end

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
 @stack.push(b/a)
end

opcode '%' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push(b % a)
end

special_mode '"' do |x|
 @stack.push(x) unless x=='"'[0]
 debug @stack.inspect
 pop_special_mode if x=='"'[0]
end

pc_read = Proc.new {

 a=@rom.round(@pc[1]).round(@pc[0])
 debug "%c PC: %s %s" % [a, @pc.inspect, @stack.inspect]
# sleep(0.1)
 a

}

pc :start=>[0,0], :pc_read=>pc_read do |values|
 if values[:no_inc_pc]!=true
  times=1
  times=values[:repeat_pc] unless values[:repeat_pc]==nil
  @pc[0]+=times if @pc_direction==:right
  @pc[0]-=times if @pc_direction==:left
  @pc[1]-=times if @pc_direction==:up
  @pc[1]+=times if @pc_direction==:down
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
register :name=>:@stack,:initial=>[]
register :name=>:@pc_direction,:initial=>:right