----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           i_clk : in std_logic;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

    type state is (state1, state2, state3, state4);
    
    signal f_Q, f_Q_next : state;
    signal prev_adv : std_logic := '0';  
    signal adv_edge : std_logic := '0';  

begin

--f_Q_next <= state1 when (i_adv = '0' and f_Q = state1) else
         --   state2 when (i_adv = '0' and f_Q = state2) else
         --   state3 when (i_adv = '0' and f_Q = state3) else
         --   state4 when (i_adv = '0' and f_Q = state4) else
            
          --  state2 when (i_adv = '1' and f_Q = state1) else
          --  state3 when (i_adv = '1' and f_Q = state2) else
          --  state4 when (i_adv = '1' and f_Q = state3) else
          --  state1 when (i_adv = '1' and f_Q = state4);
          
process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            prev_adv <= '0';
            adv_edge <= '0';
        elsif rising_edge(i_clk) then
            if (i_adv = '1' and prev_adv = '0') then
                adv_edge <= '1';  -- rising edge detected
            else
                adv_edge <= '0';
            end if;
            prev_adv <= i_adv;  -- store the current state of the button
        end if;
    end process;
    
process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            f_Q <= state1;  -- Start in state1
        elsif rising_edge(i_clk) then
            if adv_edge = '1' then
            case f_Q is
                    when state1 => f_Q <= state2;  -- Transition to state2
                    when state2 => f_Q <= state3;  -- Transition to state3
                    when state3 => f_Q <= state4;  -- Transition to state4
                    when state4 => f_Q <= state1;  -- Transition back to state1
                end case;
            end if;
        end if;
    end process;
 
            
with f_Q select
    o_cycle <= 
     "0001" when state1,
     "0010" when state2,
     "0100" when state3,
     "1000" when state4;     
        
end FSM;
