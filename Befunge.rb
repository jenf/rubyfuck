opcode '"' do push_special_mode("\"") end
opcode "@" do exit end
opcode ">" do @pc_direction=:right end
opcode "<" do @pc_direction=:left end
opcode "_" do
 k=@stack.pop_zero # This isn't specified but appears to be the behaviour.
 @pc_direction = :left if k!=0
 @pc_direction = :right if k==0
end
opcode ":" do @stack.push(@stack[-1]) end
opcode "#" do {:repeat_pc=>2} end
opcode "," do
 $stdout.putc @stack.pop
 $stdout.flush end
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
opcode 'g' do
 # This does not have multidimension support yet.
 y=@stack.pop_zero
 x=@stack.pop_zero
 @stack.push(@rom[0][x])
end
opcode '`' do
 a=@stack.pop_zero
 b=@stack.pop_zero
 @stack.push 1 if b>a
 @stack.push 0 unless b>a
end
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


special_mode '"' do |x|
 @stack.push(x) unless x=='"'[0]
 debug @stack.inspect
 pop_special_mode if x=='"'[0]
end

pc_read = Proc.new {
 @rom[0][@pc[0]]
}

pc :start=>[0,0], :pc_read=>pc_read do |values|
 if values[:no_inc_pc]!=true
  times=1
  times=values[:repeat_pc] unless values[:repeat_pc]==nil
  @pc[0]+=times if @pc_direction==:right
  @pc[0]-=times if @pc_direction==:left
  # This isn't correct.
  @pc[0] = 0 if @pc[0]==@rom[0].length
  @pc[0] = @rom[0].length-1 if @pc[0]==-1
 end
end

h=IO.readlines(ARGV[1])
rom :string=>h,:invisible_codespace=>true
register :name=>:@stack,:initial=>[]
register :name=>:@pc_direction,:initial=>:right