core :Brainfuck "A Brainfuck CPU" do
  opcode ">" { dp+=1 }
  opcode "<" { dp-=1 }
  opcode "+" { mem[dp]+=1}
  opcode "-" { mem[dp]-=1}
  opcode "." { putc mem[dp] }
  opcode "," { mem[dp] = STDIN.getc }
  opcode "[" do |x|
    # Urgh
  end
  opcode "]" do |x|
    # Urgh
  end
end
