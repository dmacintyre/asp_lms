--------------------------------------------------------------------------------
-- Project : LMS
-- Author : Donald MacIntyre - djm4912
-- Date : 4/9/2018
-- File : dot_prod.vhd
--------------------------------------------------------------------------------
-- Description : Dot product implementation. y = x*transpose(h)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.lms_pkg.all;

entity dot_prod is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        x           : in q15_reg_t;
        h           : in q15_reg_t;
        in_valid    : std_logic;
        y           : out signed(15 downto 0);
        out_valid   : out std_logic
    );
end dot_prod;

architecture behav of dot_prod is

--------------------------------------------------------------------------------
-- Signal Declarations
--------------------------------------------------------------------------------
signal mult_prod : q30_reg_t;
signal tree_sum : q15_reg_t;
signal tree_adder_valid : std_logic_vector(4 downto 0);
--------------------------------------------------------------------------------
-- Component Declarations
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

begin

dot_prod_proc : process(clk)
begin
    if rst = '1' then
        y <= (others => '0');
        out_valid <= '0';
        mult_prod <= (others => (others => '0'));
        tree_adder_valid <= (others => '0');
    elsif rising_edge(clk) then
    
        -- Default value for strobes
        tree_adder_valid <= (others => '0');
        out_valid <= '0';
    
        if in_valid = '1' then
            tree_adder_valid(0) <= '1';
            -- Q15 * Q15 multiplication produces a Q30 result
            for i in 15 downto 0 loop
                mult_prod(i) <= x(i)*h(i);
            end loop;
        end if;
        
        -- Tree Adder To accumulate the summation of the dot product multiplication
        
        -- Latch the value of the dot product
        if tree_adder_valid(0) = '1' then
            tree_adder_valid(1) <= '1';
            for i in 15 downto 0 loop
                -- Convert the Q30 multiplication result back to a Q15 number before summation
                tree_sum(i) <= signed(mult_prod(i)(30 downto 15));
            end loop;
        end if;
        
        -- Stage 1
        if tree_adder_valid(1) = '1' then
            tree_adder_valid(2) <= '1';
            for i in 0 to 7 loop
                tree_sum(i) <= tree_sum(i) + tree_sum(i+8);
            end loop;
        end if;
        
        -- Stage 2
        if tree_adder_valid(2) = '1' then
            tree_adder_valid(3) <= '1';
            for i in 0 to 3 loop
                tree_sum(i) <= tree_sum(i) + tree_sum(i+4);
            end loop;
        end if;
        
        -- Stage 3
        if tree_adder_valid(3) = '1' then
            tree_adder_valid(4) <= '1';
            for i in 0 to 1 loop
                tree_sum(i) <= tree_sum(i) + tree_sum(i+2);
            end loop;
        end if;
        
        -- Stage 4 and register
        if tree_adder_valid(4) = '1' then
            out_valid <= '1';
            y <= tree_sum(0) + tree_sum(1);
        end if;
        
    end if;
end process dot_prod_proc;

end behav;