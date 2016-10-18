library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use work.nondeterminism.all;


use std.textio.all;
use IEEE.std_logic_textio.all; 

entity CPU is
    Port ( reset : in   std_logic;
           Clock: in std_logic;
           seed: in integer;
           cpu_res: in std_logic_vector(50 downto 0);
           cpu_req : out std_logic_vector(50 downto 0);
           full_c: in std_logic;
           done: out std_logic:='0'
           );
end CPU;

architecture Behavioral of CPU is
 signal first_time : integer:=0;
 signal data: std_logic_vector(31 downto 0);
 signal adx : std_logic_vector(15 downto 0);
 signal tmp_req: std_logic_vector(50 downto 0);
 
 
 
 file trace_file: TEXT open write_mode is "console1.txt";
 file trace_file1: TEXT open write_mode is "console2.txt";
 procedure read( variable adx: in std_logic_vector(15 downto 0);
 				 signal req: out std_logic_vector(50 downto 0);
 				variable data: out std_logic_vector(31 downto 0)) is
   		begin
   			req <= "101" & adx & "00000000000000000000000000000000";
   			wait for 3 ps;
   			req <= (others => '0');
   			wait until cpu_res(50 downto 50)= "1";
   			data := cpu_res(31 downto 0);	
   			wait for 10 ps;
 end  read;
 
 procedure write( variable adx: in std_logic_vector(15 downto 0);
 				 signal req: out std_logic_vector(50 downto 0);
 				variable data: in std_logic_vector(31 downto 0)) is
   		begin
   			req <= "110" & adx & data;
   			wait for 3 ps;
   			req <= (others => '0');
   			wait until cpu_res(50 downto 50)= "1";
   			wait for 10 ps;	
 end  write;
 
 procedure power( variable cmd: in std_logic_vector(1 downto 0);
 				signal req: out std_logic_vector(50 downto 0);
 				variable hw: in std_logic_vector(1 downto 0)) is
   		begin
   			req <= "111" & cmd & hw & "00000000"&"00000000"&"00000000"&"00000000"&"00000000"&"0000" ;
   			wait for 3 ps;
   			req <= (others => '0');
   			---wait until cpu_res(50 downto 50)= "1";
   			wait for 50 ps;	
 end  power;
 
 
 
 
begin
   	req1: process(reset, Clock)
   	begin
   		if reset ='1' then
			cpu_req <= (others => '0');
			
		elsif (rising_edge(Clock)) then
			cpu_req <= tmp_req;
		end if;
   	end process;


-- processor random generate read or write request
 p1 : process 
     variable nilreq: std_logic_vector(50 downto 0):=(others=>'0');
     
     variable flag0: std_logic_vector(15 downto 0):="0000"&"0000"&"0010"&"0000";
     variable flag1: std_logic_vector(15 downto 0):="0000"&"0000"&"0011"&"0000";
     variable turn: std_logic_vector(15 downto 0):="0000"&"0000"&"0100"&"0000";
     variable shar: std_logic_vector(15 downto 0):="0000"&"0000"&"0101"&"0000";
     variable crit: std_logic_vector(15 downto 0):="0000"&"0000"&"0110"&"0000";


     variable turn_v: std_logic_vector(31 downto 0);
     variable flag0_v: std_logic_vector(31 downto 0);
     variable flag1_v: std_logic_vector(31 downto 0);
     variable crit_v: std_logic_vector(31 downto 0);
     
     variable crit_s: integer;
     
     variable zero: std_logic_vector(31 downto 0):="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
     variable one: std_logic_vector(31 downto 0):="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0001";
     variable two: std_logic_vector(31 downto 0):="0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0010";
     variable rand1:integer:=1;
      variable rand2: std_logic_vector(15 downto 0):="0101010101010111";
     variable rand3: std_logic_vector(31 downto 0):="10101010101010101010101010101010";
     variable line_output:line;
     variable logsr: string(8 downto 1);
     variable pwrcmd: std_logic_vector(1 downto 0);
     variable hwlc: std_logic_vector(1 downto 0);
    begin
    	wait for 70 ps;
    	---pwrcmd := "00";
    	---hwlc := "00";
    	---power(pwrcmd, tmp_req, hwlc);
	for I in 1 to 500 loop
	   rand1 := selection(2);
	   rand2 := selection(2**2-1,3)&"0000000000000";
	   rand3 := selection(2**15-1,32);
	   ---if rand1=1 then
	   ---    write(rand2,tmp_req,rand3);
	   ---else
	   ---    read(rand2,tmp_req,rand3);
	   ---end if;
    	if seed = 1 then    		 
    		write(flag0,tmp_req,one);
    		write(turn,tmp_req,one);
    		read(turn, tmp_req, turn_v);
    		read(flag1, tmp_req, flag1_v);
    		
    		logsr :="en0;trn:";
    		write(line_output, logsr);
    		write(line_output, turn_v);
			writeline(trace_file, line_output);
			logsr :="en0;fg1:";
    		write(line_output, logsr);
    		write(line_output, flag1_v);
			writeline(trace_file, line_output);
			
    		while turn_v=one and flag1_v=one loop
    			read(turn, tmp_req, turn_v);
    			read(flag1, tmp_req, flag1_v);
    			
    			logsr :="in0;trn:";
    			write(line_output, logsr);
    			write(line_output, turn_v);
				writeline(trace_file, line_output);
				logsr :="in0;fg1:";
    			write(line_output, logsr);
    			write(line_output, flag1_v);
				writeline(trace_file, line_output);
    			
    			
    		end loop;
			
    		read(crit, tmp_req, crit_v);  
    		  		
    		crit_v:= std_logic_vector(unsigned(crit_v)+1);
    		write(crit,tmp_req, crit_v);
    		
    		read(crit, tmp_req, crit_v);
    		logsr :="1citaft:";
    		write(line_output, logsr);
    		write(line_output, crit_v);
			writeline(trace_file, line_output);
			
    		write(flag0,tmp_req,zero);
    	elsif seed=2 then
    		
    		write(flag1,tmp_req,one);
    		
    		
    		write(turn,tmp_req,zero);
    		
    		
    		read(turn, tmp_req, turn_v);
    		
    		
    		read(flag0, tmp_req, flag0_v);
    		
    		
    		logsr :="en1;trn:";
    		write(line_output, logsr);
    		write(line_output, turn_v);
			writeline(trace_file1, line_output);
			logsr :="en1;fg0:";
    		write(line_output, logsr);
    		write(line_output, flag0_v);
			writeline(trace_file1, line_output);
    		
    		while turn_v=zero and flag0_v=one loop
    			read(turn, tmp_req, turn_v);
    			read(flag0, tmp_req, flag0_v);
    			
    		
    			logsr :="in1;trn:";
    			write(line_output, logsr);
    			write(line_output, turn_v);
				writeline(trace_file1, line_output);
				logsr :="in1;fg0:";
    			write(line_output, logsr);
    			write(line_output, flag0_v);
				writeline(trace_file1, line_output);
				
    		end loop;
    		
    		read(crit, tmp_req, crit_v); 
    		
    		   		
    		crit_v:= std_logic_vector(unsigned(crit_v)+1);
    		write(crit,tmp_req, crit_v);
    		
    		
    		
    		read(crit, tmp_req, crit_v);
    		logsr :="2citaft:";
    		write(line_output, logsr);
    		write(line_output, crit_v);
			writeline(trace_file1, line_output);
    		
    		write(flag1,tmp_req,zero);
    		
    	end if;
  end loop;	
  done<='1';
  wait;

  end process; 
 
  
end Behavioral;
