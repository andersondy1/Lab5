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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

    
    signal f_Q : std_logic_vector(3 downto 0):= "0001";
    signal  f_Q_next : std_logic_vector(3 downto 0);

begin

--f_Q_next <= state1 when (i_adv = '0' and f_Q = state1) else
         --   state2 when (i_adv = '0' and f_Q = state2) else
         --   state3 when (i_adv = '0' and f_Q = state3) else
         --   state4 when (i_adv = '0' and f_Q = state4) else
            
          --  state2 when (i_adv = '1' and f_Q = state1) else
          --  state3 when (i_adv = '1' and f_Q = state2) else
          --  state4 when (i_adv = '1' and f_Q = state3) else
          --  state1 when (i_adv = '1' and f_Q = state4);
          
    
controller : process(i_adv, i_reset)
    begin
        if i_reset = '1' then
            f_Q <= "0001";  -- Start in state1
        elsif rising_edge(i_adv) then
            f_Q <= f_Q_next;
        end if;
    end process;
 
f_Q_next(0) <= f_Q(3);  
f_Q_next(1) <= f_Q(0);           
f_Q_next(2) <= f_Q(1);           
f_Q_next(3) <= f_Q(2);           
         
o_cycle <= f_Q; 
        
end FSM;
