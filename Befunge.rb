opcode '"' do push_special_mode("\"") end
opcode "@" do exit end
opcode ">" do @pc_direction=:right end
opcode "<" do @pc_direction=:left end
opcode "_" do
 k=@stack.pop # This isn't specified but appears to be the behaviour.
 k=0 if k==nil
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


special_mode '"' do |x|
 @stack.push(x) unless x=='"'[0]
 debug @stack.inspect
 pop_special_mode if x=='"'[0]
end

pc :start=>0 do |values|
 if values[:no_inc_pc]!=true
  times=1
  times=values[:repeat_pc] unless values[:repeat_pc]==nil
  @pc+=times if @pc_direction==:right
  @pc-=times if @pc_direction==:left
 end
end

rom :file=>ARGV[1],:invisible_codespace=>true
register :name=>:@stack,:initial=>[]
register :name=>:@pc_direction,:initial=>:right