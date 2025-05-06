--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
component controller_fsm is 
    port (
        i_reset : in STD_LOGIC;
        i_adv : in STD_LOGIC;
        o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
        );
      
end component controller_fsm;

component ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end component ALU;

component clock_divider is
	generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
											   -- Effectively, you divide the clk double this 
											   -- number (e.g., k_DIV := 2 --> clock divider of 4)
	port ( 	i_clk    : in std_logic;
			i_reset  : in std_logic;		   -- asynchronous
			o_clk    : out std_logic		   -- divided (slow) clock
	);
end component clock_divider;

component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
end component twos_comp;

component TDM4 is
	generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
end component TDM4;

component sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end component sevenseg_decoder;
        
-- signals


signal w_cycle : std_logic_vector(3 downto 0):= "1111";
signal w_clkdiv_reset : std_logic;

signal w_clkdivout : std_logic;

signal w_A : std_logic_vector(7 downto 0):="11111111";
signal w_B : std_logic_vector(7 downto 0):="11111111";

signal w_result : std_logic_vector(7 downto 0):="11111111";

signal w_flags : std_logic_vector(3 downto 0):= "1111";

signal w_mux : std_logic_vector(7 downto 0):= "11111111";

signal w_hund : std_logic_vector(3 downto 0):= "1111";
signal w_tens : std_logic_vector(3 downto 0):= "1111";
signal w_ones : std_logic_vector(3 downto 0):= "1111";

signal w_sign : std_logic_vector(3 downto 0):= "1111";

signal w_sign_bit : std_logic:='1';

signal w_data : std_logic_vector(3 downto 0):= "1111";

signal w_seltdm : std_logic_vector(3 downto 0):= "1111";

signal w_sel: std_logic_vector(3 downto 0):= "1111";
signal w_seg, w_seg_sign : std_logic_vector(6 downto 0):= "1111111";


begin
	-- PORT MAPS ----------------------------------------

w_clkdiv_reset <= BtnU;


--blanks the screen
with w_cycle select
    an <= "1111" when "0001",
          w_sel when others;
clock_divider_inst : clock_divider
generic map(
	k_DIV => 50000
	)
port map(
    i_clk => clk,
    i_reset => w_clkdiv_reset,
    o_clk => w_clkdivout
    );
    
controller_fsm_inst : controller_fsm
port map(
    i_reset => w_clkdiv_reset,
    i_adv => BtnC,
    o_cycle => w_cycle
    );
    
ALU_inst : ALU
port map(
    i_A => w_A,
    i_B => w_B,
    i_op => sw(2 downto 0),
    o_result => w_result,
    o_flags => led(15 downto 12)
    );
    
with w_cycle select
    w_mux <= w_A when "0010",
             w_B when "0100",
             w_result when "1000",
             "00000000" when others;
       
twos_comp_inst : twos_comp
port map(
    i_bin => w_mux,
    o_sign => w_sign_bit,
    o_hund => w_hund,
    o_tens => w_tens,
    o_ones => w_ones
    );
    
tdm_inst : TDM4
port map(
    i_D3 => w_sign,
    i_D2 => w_hund,
    i_D1 => w_tens,  
    i_D0 => w_ones,
    o_data => w_data,
    o_sel => w_sel,
    i_clk => w_clkdivout,
    i_reset => w_clkdiv_reset
    );        
    
decoder_inst : sevenseg_decoder
port map( 
    i_hex => w_data,
    o_seg_n => w_seg
    ); 
    
	-- CONCURRENT STATEMENTS ----------------------------
	with w_sign_bit select
	   w_seg_sign <= "1111111" when '0',
	            "0111111" when others;

    with w_sel select 
       seg <= w_seg_sign when "0111",
              w_seg when others;

process(w_clkdivout)
begin
    if rising_edge(w_clkdivout) then
        if BtnC = '1' then
            if w_cycle = "0010" then
                w_A <= sw(7 downto 0);
            elsif w_cycle = "0100" then
                w_B <= sw(7 downto 0);
            end if;    
        end if;
    end if;
end process;
led(11 downto 0) <= (others => '0');

end top_basys3_arch;
