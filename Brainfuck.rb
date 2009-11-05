core :Brainfuck "A Brainfuck CPU" do
  opcode ">" { dp+=1 }
  opcode "<" { dp-=1 }
  opcode "+" { mem[dp]+=1}
  opcode "-" { mem[dp]-=1}
  opcode "." { putc mem[dp] }
  opcode "," { mem[dp] = STDIN.getc }
  opcode "[" do |x|
    if (0 == mem[dp])
      count = 1
      while x != 0
        pc +=1
        if mem[pc]== 91 # [
          count+=1
        elsif mem[pc]== 93 # ]
          count-=1
        end
      end
    end
  end
  opcode "]" do |x|
    # Urgh
  end

  memsize :name=>mem,:size=>30000 # Classical brainfuck
  pc :name=>:pc,:start=0
  register :name=>:dp,:var=>:dp
end
