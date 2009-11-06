opcode ">" do @dp+=1 end
opcode "<" do @dp-=1 end
opcode "+" do @mem[@dp]+=1 end
opcode "-" do @mem[@dp]-=1 end
opcode "." do putc @mem[@dp] end
opcode "," do
 a = STDIN.getc
 exit if a = nil
 @mem[@dp] = a
end
opcode "[" do
  if (0 == @mem[@dp])
    count = 1
    while count != 0
      @pc +=1
      if @rom[@pc]== 91 # [
        count+=1
      elsif @rom[@pc]== 93 # ]
        count-=1
      end
    end
  end
end
opcode "]" do
  if (0 != @mem[@dp])
    count = 1
    while count != 0
      @pc -=1
#      puts "%i %i" % [@pc,@rom[@pc]]
      if @rom[@pc]== 91 # [
#        puts "] [ %i" % count
        count-=1
      elsif @rom[@pc]== 93 # ]
#        puts "] ] %i" % count
        count+=1
      end
    end
    {:no_inc_pc=>true}
  end
end

mem :size=>30000 # Classical brainfuck
pc :start=>0
register :name=>:@dp
rom :file=>ARGV[1],:invisible_codespace=>true
