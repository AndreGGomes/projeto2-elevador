library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_tb is
end top_tb;

architecture sim of top_tb is
  constant w : natural := 5;
  constant CLK_PERIOD : time := 10 ns;

  component top
    generic (w : natural := 5);
    port (
      clk : in std_logic;
      out_kb_up    : in std_logic_vector((2**w)-1 downto 0);
      out_kb_down  : in std_logic_vector((2**w)-1 downto 0);
      el1_kb, el2_kb, el3_kb : in std_logic_vector((2**w)-1 downto 0);
      el1_dr, el2_dr, el3_dr : out std_logic;
      el1_floor, el2_floor, el3_floor : out std_logic_vector(w-1 downto 0);
      el1_status, el2_status, el3_status : out std_logic_vector(1 downto 0)
    );
  end component;

  signal clk : std_logic := '0';
  signal out_kb_up, out_kb_down : std_logic_vector(31 downto 0) := (others => '0');
  signal el1_kb, el2_kb, el3_kb : std_logic_vector(31 downto 0) := (others => '0');

  signal el1_floor, el2_floor, el3_floor : std_logic_vector(w-1 downto 0);
  signal el1_status, el2_status, el3_status : std_logic_vector(1 downto 0);
  signal el1_dr, el2_dr, el3_dr : std_logic;
  signal sim_ended         : boolean := false;

begin

  DUT: top generic map (w => w)
    port map (
      clk => clk,
      out_kb_up => out_kb_up, out_kb_down => out_kb_down,
      el1_kb => el1_kb, el2_kb => el2_kb, el3_kb => el3_kb,
      el1_dr => el1_dr, el2_dr => el2_dr, el3_dr => el3_dr,
      el1_floor => el1_floor, el2_floor => el2_floor, el3_floor => el3_floor,
      el1_status => el1_status, el2_status => el2_status, el3_status => el3_status
    );

  -- Clock generation
  clk_process : process
  begin
    while not sim_ended loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
  end process;

  -- Simulation Process
  stim_proc: process
  begin
    wait for CLK_PERIOD * 5;
    
    report "=== SYSTEM TEST START ===";
    
    -- 1. Press 'UP' button at Floor 4
    report "Action: Call UP at Floor 4 and 6";
    out_kb_up <= (4 => '1', 6 => '1', others => '0');
    
    -- Hold button for a few clocks to ensure it's caught
    wait for CLK_PERIOD * 2;
    out_kb_up <= (others => '0');

    -- 2. Wait and observe movement
    -- Elevator 1 starts at 0. It should go 0 -> 1 -> 2 -> 3 -> 4.
    -- This takes time (physically), so we wait.
    
    wait for CLK_PERIOD * 20; 
    
    -- Check if it arrived
    assert unsigned(el1_floor) = 6 report "FAIL: Elevator did not arrive at floor 6" severity warning;
    
    if unsigned(el1_floor) = 6 then
        report "SUCCESS: Elevator arrived at floor 6!";
    else
        report "STATUS: Elevator is currently at floor " & integer'image(to_integer(unsigned(el1_floor)));
    end if;

    report "Action: Call UP at Floor 2 to go up and 1 to go down";

    out_kb_up <= (2 => '1', others => '0');
    out_kb_down <= (4 => '1', 9 => '1', others => '0');

    wait for CLK_PERIOD * 2; 

    out_kb_up <= (others => '0');
    out_kb_down <= (others => '0');
    
    wait for CLK_PERIOD * 40; 

    report "=== SYSTEM TEST END ===";

    sim_ended <= true;

    wait;
  end process;

end sim;
