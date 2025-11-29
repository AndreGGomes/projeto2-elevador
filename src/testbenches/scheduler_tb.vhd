library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity scheduler_tb is
end scheduler_tb;

architecture sim of scheduler_tb is

  constant w : natural := 5;
  constant CLK_PERIOD : time := 10 ns;

  component scheduler
    generic (w : natural := 5);
    port (
      clk : in std_logic;
      going_up    : in std_logic_vector((2**w)-1 downto 0);
      going_down  : in std_logic_vector((2**w)-1 downto 0);
      el1_floor, el2_floor, el3_floor : in std_logic_vector(w-1 downto 0);
      el1_status, el2_status, el3_status : in std_logic_vector(1 downto 0);
      el1_intention, el2_intention, el3_intention : in std_logic_vector(1 downto 0);
      el1_going_up, el1_going_down : out std_logic_vector((2**w)-1 downto 0);
      el2_going_up, el2_going_down : out std_logic_vector((2**w)-1 downto 0);
      el3_going_up, el3_going_down : out std_logic_vector((2**w)-1 downto 0)
    );
  end component;

  signal clk : std_logic := '0';
  signal going_up   : std_logic_vector(31 downto 0) := (others => '0');
  signal going_down : std_logic_vector(31 downto 0) := (others => '0');

  signal el1_floor, el2_floor, el3_floor : std_logic_vector(w-1 downto 0) := (others => '0');
  signal el1_status, el2_status, el3_status : std_logic_vector(1 downto 0) := "00";
  signal el1_intention, el2_intention, el3_intention : std_logic_vector(1 downto 0) := "00";

  signal el1_up_out, el1_dn_out : std_logic_vector(31 downto 0);
  signal el2_up_out, el2_dn_out : std_logic_vector(31 downto 0);
  signal el3_up_out, el3_dn_out : std_logic_vector(31 downto 0);

begin

  DUT: scheduler generic map (w => w)
    port map (
      clk => clk,
      going_up => going_up, going_down => going_down,
      el1_floor => el1_floor, el1_status => el1_status, el1_intention => el1_intention,
      el2_floor => el2_floor, el2_status => el2_status, el2_intention => el2_intention,
      el3_floor => el3_floor, el3_status => el3_status, el3_intention => el3_intention,
      el1_going_up => el1_up_out, el1_going_down => el1_dn_out,
      el2_going_up => el2_up_out, el2_going_down => el2_dn_out,
      el3_going_up => el3_up_out, el3_going_down => el3_dn_out
    );

  clk_process : process
  begin
    while true loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
  end process;

  stim_proc: process
  begin
    wait for CLK_PERIOD * 2;
    report "=== STARTING SCHEDULER TEST ===";

    -- CASE 1: Basic Proximity
    -- El1: Floor 0, Stop. El2: Floor 8, Stop. Call at 10.
    report "Test 1: Basic Proximity (El2 closest)";
    el1_floor <= std_logic_vector(to_unsigned(0, w));  el1_status <= "00"; 
    el2_floor <= std_logic_vector(to_unsigned(8, w));  el2_status <= "00"; 
    
    going_up <= (10 => '1', others => '0');
    wait for CLK_PERIOD * 4;

    assert el2_up_out(10) = '1' report "FAIL: El2 should take call" severity error;
    assert el1_up_out(10) = '0' report "FAIL: El1 should NOT take call" severity error;
    
    going_up <= (others => '0');
    wait for CLK_PERIOD * 2;

    -- CASE 2: Optimization (Direction Priority)
    -- Call UP at 5.
    -- El1: Floor 0, Moving UP (Correct Dir).
    -- El2: Floor 4, Moving DOWN (Wrong Dir).
    report "Test 2: Direction Priority";
    el1_floor <= std_logic_vector(to_unsigned(0, w)); 
    el1_status <= "10"; el1_intention <= "10"; 
    el2_floor <= std_logic_vector(to_unsigned(4, w)); 
    el2_status <= "01"; el2_intention <= "01"; 

    going_up <= (5 => '1', others => '0');
    wait for CLK_PERIOD * 4;

    assert el1_up_out(5) = '1' report "FAIL: El1 should win (correct direction)" severity error;
    assert el2_up_out(5) = '0' report "FAIL: El2 should lose (wrong direction)" severity error;

    wait;
  end process;

end sim;
