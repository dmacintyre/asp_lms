--------------------------------------------------------------------------------
-- Project : PROJECTNAME
-- Author : Donald MacIntyre - djm4912
-- Date : 4/8/2018
-- File : lms_tb.vhd
--------------------------------------------------------------------------------
-- Description :
--------------------------------------------------------------------------------
-- $Log$
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
    
    while(not endfile(fin)) loop
        readline(fin,l);
        read(l,channel_input);
        read(l,channel_output);
        xin <= to_signed(channel_input,xin'length);
        expected <= to_signed(channel_output,expected'length);
        in_valid <= '1';
        nop(clk,1);
        in_valid <= '0';
        nop(clk,9);
    end loop;
    
    
    assert false report "Simulation over" severity failure;
end process stim_proc;

clk_gen_proc : process
begin
    wait for 1 ns;
    clk <= not clk;
end process clk_gen_proc;

end tb;