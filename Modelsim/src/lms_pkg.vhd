library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work ;

package lms_pkg is

constant NUM_TAPS : natural := 4;
type q15_reg_t is array(15 downto 0) of signed(15 downto 0) ;
type q30_reg_t is array(15 downto 0) of signed(31 downto 0) ;

end package lms_pkg;
