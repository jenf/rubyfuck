opcode ">" do dp+=1 end
opcode "<" do dp-=1 end
opcode "+" do mem[dp]+=1 end
opcode "-" do mem[dp]-=1 end
opcode "." do putc mem[dp] end
opcode "," do mem[dp] = STDIN.getc end
opcode "[" do
  if (0 == mem[dp])
    count = 1
    while count != 0
      pc +=1
      if mem[pc]== 91 # [
        count+=1
      elsif mem[pc]== 93 # ]
        count-=1
      end
    end
  end
end
opcode "]" do
  if (0 == mem[dp])
    count = 1
    while count != 0
      pc -=1
      if mem[pc]== 91 # [
        count-=1
      elsif mem[pc]== 93 # ]
        count+=1
      end
    end
  end
  :no_inc_pc
end

memsize :name=>:mem,:size=>30000 # Classical brainfuck
pc :name=>:pc,:start=>0
register :name=>:dp,:var=>:dp
rom :file=>ARGV[1],:invisible_codespace=>true
