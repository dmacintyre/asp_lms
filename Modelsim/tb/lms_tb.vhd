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

use work.lms_pkg.all;

entity lms_tb is
end lms_tb;

architecture tb of lms_tb is

--------------------------------------------------------------------------------
-- Signal Declarations
--------------------------------------------------------------------------------
signal clk : std_logic := '0';
--------------------------------------------------------------------------------
-- Component Declarations
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

procedure nop( signal clk : in std_logic ; count : natural ) is
begin
    for i in 1 to count loop
        wait until rising_edge(clk);
    end loop;
end procedure;

begin

stim_proc : process
begin
    wait for 500 ns;
    assert false report "Simulation over" severity failure;
end process stim_proc;

clk_gen_proc : process
begin
    wait for 1 ns;
    clk <= not clk;
end process clk_gen_proc;

end tb;