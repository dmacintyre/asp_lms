--------------------------------------------------------------------------------
-- Project : PROJECTNAME
-- Author : Donald MacIntyre - djm4912
-- Date : 4/8/2018
-- File : lms.vhd
--------------------------------------------------------------------------------
-- Description :
--------------------------------------------------------------------------------
-- $Log$
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.lms_pkg.all;

entity lms is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        in_valid    : in std_logic;
        xin         : in signed(15 downto 0);
        expected    : in signed(15 downto 0);
        out_valid   : out std_logic;
        sys_weights : out q15_reg_t
    );
end lms;

architecture behav of lms is

--------------------------------------------------------------------------------
-- Signal Declarations
--------------------------------------------------------------------------------
signal shift_reg        : q15_reg_t;
signal shift_reg_dot    : q15_reg_t;
signal weights          : q15_reg_t;
signal weight_update_valid : std_logic;
signal shift_valid      : std_logic;
signal dot_prod_valid   : std_logic;
signal dot_out_valid   : std_logic;
signal lms_res          : signed(15 downto 0);
signal error            : signed(15 downto 0);
signal error_valid : std_logic;
signal weight_update_q30 : q30_reg_t;
signal expected_latch : signed(15 downto 0);
--------------------------------------------------------------------------------
-- Component Declarations
--------------------------------------------------------------------------------
component dot_prod is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        x           : in q15_reg_t;
        h           : in q15_reg_t;
        in_valid    : std_logic;
        y           : out signed(15 downto 0);
        out_valid   : out std_logic
    );
end component;
--------------------------------------------------------------------------------

begin

uDot_prod : dot_prod
    Port map(
        clk         => clk,
        rst         => rst,
        x           => shift_reg_dot,
        h           => weights,
        in_valid    => dot_prod_valid,
        y           => lms_res,
        out_valid   => dot_out_valid
    );

lms_proc : process(clk)
begin
    if rst = '1' then
        out_valid <= '0';
        shift_valid <= '0';
        dot_prod_valid <= '0';
        error_valid <= '0';
        weight_update_valid <= '0';
        shift_reg <= (others => (others => '0'));
        shift_reg_dot <= (others => (others => '0'));
        weight_update_q30 <= (others => (others => '0'));
        weights <= (others => (others => '0'));
        expected_latch <= (others => '0');
        error <= (others => '0');
    elsif rising_edge(clk) then
    
        -- Default value for strobes
        shift_valid <= '0';
        out_valid <= '0';
        dot_prod_valid <= '0';
        error_valid <= '0';
        weight_update_valid <= '0';
    
        -- Shift in the latest sample
        if in_valid = '1' then
            shift_valid <= '1';
            shift_reg <= shift_reg(14 downto 0) & xin;
            expected_latch <= expected;
        end if;    
        
        if shift_valid = '1' then
            dot_prod_valid <= '1';
        -- Zero out un-used taps. Design is capable of searching for upto 16 taps,
            for i in 0 to 15 loop
                if i < NUM_TAPS then
                    shift_reg_dot(i) <= shift_reg(i);
                else
                    shift_reg_dot(i) <= (others => '0');
                end if;
            end loop;
        end if;
        
        -- Calculate the LMS error signal (expected - actual LMS output)
        if dot_out_valid = '1' then
            error_valid <= '1';
            error <= expected_latch - lms_res;
        end if;
        
        -- Update the weights
        if error_valid = '1' then
            weight_update_valid <= '1';
            for i in 0 to NUM_TAPS-1 loop
                weight_update_q30(i) <= shift_reg(i) * error;
            end loop;
        end if;
        
        -- Register the new weights
        if weight_update_valid = '1' then
            out_valid <= '1';
            for i in 0 to NUM_TAPS-1 loop
                weights(i) <= weights(i) + signed(weight_update_q30(i)(30 downto 15));
            end loop;
        end if;
        
    
    end if;
end process lms_proc;

sys_weights <= weights;

end behav;