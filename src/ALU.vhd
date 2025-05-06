----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;
 
architecture Behavioral of ALU is
 
    signal s_A : signed (7 downto 0);
    signal s_B : signed (7 downto 0);
    signal u_A : unsigned (7 downto 0);
    signal u_B : unsigned (7 downto 0);
    signal s_A_9 : signed (8 downto 0);
    signal s_B_9 : signed (8 downto 0);
    signal s2_A : std_logic_vector (7 downto 0);
    signal s2_B : std_logic_vector (7 downto 0);
    signal C_out : std_logic;
    signal result: std_logic_vector (7 downto 0);
    signal B_out : std_logic_vector (7 downto 0);
    signal a_result: std_logic_vector (8 downto 0);
    signal s_result: std_logic_vector (8 downto 0);
    signal as_result: std_logic_vector (7 downto 0);
    signal as2_result: std_logic_vector (7 downto 0);
    signal Z : std_logic_vector (3 downto 0);
    signal N : std_logic_vector (3 downto 0);
    signal C : std_logic_vector (3 downto 0);
    signal V : std_logic_vector (3 downto 0);

begin
 
    s_A <= signed(i_A);
    s_B <= signed(i_B);
   s_A_9(8) <= i_A(7); -- sign extension
   s_A_9 (7 downto 0) <= signed(i_A);
   s_B_9(8) <= i_B(7); -- sign extension
   s_B_9 (7 downto 0) <= signed(i_B);
    u_A <= unsigned(i_A);
    u_B <= unsigned(i_B);

 
    result <=   std_logic_vector(s_A + s_B) when (i_op = "000") else
                 std_logic_vector(s_A - s_B) when (i_op = "001") else
                 (i_A and i_B) when (i_op = "010") else
                 (i_A or i_B) when (i_op = "011");
    o_result <= result;
    Z <= "0100" when (result = "00000000") else
         "0000";
    N <= "1000" when (result(7) = '1') else
         "0000";
   a_result <= std_logic_vector(s_A_9 + s_B_9);  
   s_result <= std_logic_vector(s_A_9 - s_B_9);          
   C_out <= '1' when (i_op = "000" and a_result(8) = '1') or (i_op = "001" and s_result(8) = '1') else
            '0';

   C <= "0010" when ((i_op = "000" or i_op = "001") and (C_out = '1')) else
        "0000";    
    as_result <= std_logic_vector(s_A + s_B);  
    as2_result <= std_logic_vector(s_A + (-s_B));
    V <= "0001" when ((i_op = "000" and s_A(7) = '0' and s_B(7) = '0' and as_result(7) = '1') or 
                     (i_op = "000" and s_A(7) = '1' and s_B(7) = '1' and as_result(7) = '0') or
                     (i_op = "001" and s_A(7) = '1' and s_B(7) = '0' and as2_result(7) = '0') or
                     (i_op = "001" and s_A(7) = '0' and s_B(7) = '1' and as2_result(7) = '1')) else
                     "0000";

    o_flags <= (N or Z or C or V);
end Behavioral;