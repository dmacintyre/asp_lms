--------------------------------------------------------------------------------
-- Project : LMS
-- Author : Donald MacIntyre - djm4912
-- Date : 4/8/2018
-- File : lms_tb.vhd
--------------------------------------------------------------------------------
-- Description : Testbench for LMS UUT
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library std ;
use std.textio.all ;

use work.lms_pkg.all;

entity lms_tb is
end lms_tb;

architecture tb of lms_tb is

--------------------------------------------------------------------------------
-- Signal Declarations
--------------------------------------------------------------------------------
signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal in_valid : std_logic := '0';
signal xin : signed(15 downto 0) := (others => '0');
signal expected : signed(15 downto 0) := (others => '0');
signal out_valid : std_logic;
signal weights : q15_reg_t;
--------------------------------------------------------------------------------
-- Component Declarations
--------------------------------------------------------------------------------
component lms is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        in_valid    : in std_logic;
        xin         : in signed(15 downto 0);
        expected    : in signed(15 downto 0);
        out_valid   : out std_logic;
        sys_weights : out q15_reg_t
    );
end component;
--------------------------------------------------------------------------------

procedure nop( signal clk : in std_logic ; count : natural ) is
begin
    for i in 1 to count loop
        wait until rising_edge(clk);
    end loop;
end procedure;

begin

uut : lms
    Port Map(
        clk         => clk, 
        rst         => rst, 
        in_valid    => in_valid,
        xin         => xin,
        expected    => expected,
        out_valid   => out_valid, 
        sys_weights => weights
    );

-- This process asserts the input onto the UUT
stim_proc : process
constant filename : string := "../Python/input_data.txt";
file fin : text;
variable l : line;
variable s      :   file_open_status ;
variable channel_input : integer;
variable channel_output : integer;
begin
    rst <= '1';
    nop(clk,100);
    rst <= '0';
    nop(clk,10);
    
    file_open(s, fin, filename, READ_MODE ) ;
    if( s /= OPEN_OK ) then
        report "Error opening file (" & file_open_status'image(s) & "): " & filename severity failure ;
    end if ;
    
    -- Loop over all samples in the input file and push them into the UUT
    while(not endfile(fin)) loop
        readline(fin,l);
        read(l,channel_input);
        read(l,channel_output);
        xin <= to_signed(channel_input,xin'length);
        expected <= to_signed(channel_output,expected'length);
        in_valid <= '1';    -- assert the UUT inputs are valid for one clock
        nop(clk,1);
        in_valid <= '0';
        nop(clk,9);
    end loop;
    
    nop(clk,100);
    assert false report "Simulation over" severity failure;
    
end process stim_proc;

-- This process capture the output weights as they are updated each iteration
save_weights_proc : process
    constant FNAME : string := "lms_weights.txt";
    file fout      : text;
    variable l     : line;
    variable s     : file_open_status;
begin
    file_open(s, fout, FNAME, WRITE_MODE) ;
    if( s /= OPEN_OK ) then
        report "Error opening file (" & file_open_status'image(s) & "): " & FNAME severity failure ;
    end if;
        loop
            -- If weights are valid, write them to a file
            wait until rising_edge(clk) and out_valid = '1';
            for i in 0 to 15 loop
                write(l, to_integer(weights(i)));
                write(l, character'(' ') ) ;
            end loop;
            writeline(fout, l) ;
        end loop;
end process save_weights_proc;

-- this process captures the error signal as it is updated each iteration
save_error_proc : process
    constant FNAME : string := "lms_error.txt";
    file fout      : text;
    variable l     : line;
    variable s     : file_open_status;
    
    alias error_valid is << signal .lms_tb.uut.error_valid : std_logic>>;
    alias error_signal is << signal .lms_tb.uut.error : signed(15 downto 0)>>;
    
begin
    file_open(s, fout, FNAME, WRITE_MODE) ;
    if( s /= OPEN_OK ) then
        report "Error opening file (" & file_open_status'image(s) & "): " & FNAME severity failure ;
    end if;
    loop
        -- If the error signal is valid
        wait until rising_edge(clk) and error_valid = '1';
            write(l, to_integer(error_signal));
            writeline(fout, l) ;
    end loop;
end process save_error_proc;


clk_gen_proc : process
begin
    wait for 1 ns;
    clk <= not clk;
end process clk_gen_proc;

end tb;