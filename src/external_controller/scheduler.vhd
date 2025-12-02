library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.all;

entity scheduler is
  generic (w : natural := 5);
  port (
    clk : in std_logic;

    going_up    : in std_logic_vector((2**w)-1 downto 0);
    going_down  : in std_logic_vector((2**w)-1 downto 0);

    el1_floor       : in std_logic_vector(w-1 downto 0);
    el1_status      : in std_logic_vector(1 downto 0);
    el1_intention   : in std_logic_vector(1 downto 0);
    el1_going_up    : out std_logic_vector((2**w)-1 downto 0);
    el1_going_down  : out std_logic_vector((2**w)-1 downto 0);

    el2_floor       : in std_logic_vector(w-1 downto 0);
    el2_status      : in std_logic_vector(1 downto 0);
    el2_intention   : in std_logic_vector(1 downto 0);
    el2_going_up    : out std_logic_vector((2**w)-1 downto 0);
    el2_going_down  : out std_logic_vector((2**w)-1 downto 0);

    el3_floor       : in std_logic_vector(w-1 downto 0);
    el3_status      : in std_logic_vector(1 downto 0);
    el3_intention   : in std_logic_vector(1 downto 0);
    el3_going_up    : out std_logic_vector((2**w)-1 downto 0);
    el3_going_down  : out std_logic_vector((2**w)-1 downto 0)
  );
end scheduler;

architecture arch of scheduler is
  signal scan_direction : std_logic;
  signal reset_internal : std_logic := '0';
  
  signal rej_up, rej_down : call_vector((2**w)-1 downto 0);
  signal rej_up_next, rej_down_next : call_vector((2**w)-1 downto 0);

  component scheduler_pc
    port (
      clk           : in std_logic;
      reset         : in std_logic;
      scan_direction: out std_logic
    );
  end component;

  component scheduler_po
    generic (w : natural := 5);
    port (
      scan_direction : in std_logic;
      going_up    : in std_logic_vector((2**w)-1 downto 0);
      going_down  : in std_logic_vector((2**w)-1 downto 0);
      el1_floor, el2_floor, el3_floor : in std_logic_vector(w-1 downto 0);
      el1_status, el2_status, el3_status : in std_logic_vector(1 downto 0);
      el1_intention, el2_intention, el3_intention : in std_logic_vector(1 downto 0);
      rej_up_in   : in call_vector((2**w)-1 downto 0);
      rej_down_in : in call_vector((2**w)-1 downto 0);
      el1_going_up, el1_going_down : out std_logic_vector((2**w)-1 downto 0);
      el2_going_up, el2_going_down : out std_logic_vector((2**w)-1 downto 0);
      el3_going_up, el3_going_down : out std_logic_vector((2**w)-1 downto 0);
      rej_going_up_out   : out call_vector((2**w)-1 downto 0);
      rej_going_down_out : out call_vector((2**w)-1 downto 0)
    );
  end component;

begin
  PC: scheduler_pc port map (
      clk => clk,
      reset => reset_internal,
      scan_direction => scan_direction
  );

  PO: scheduler_po generic map (w => w)
    port map (
      scan_direction => scan_direction,
      going_up => going_up, going_down => going_down,
      el1_floor => el1_floor, el2_floor => el2_floor, el3_floor => el3_floor,
      el1_status => el1_status, el2_status => el2_status, el3_status => el3_status,
      el1_intention => el1_intention, el2_intention => el2_intention, el3_intention => el3_intention,
      rej_up_in => rej_up, rej_down_in => rej_down,
      el1_going_up => el1_going_up, el1_going_down => el1_going_down,
      el2_going_up => el2_going_up, el2_going_down => el2_going_down,
      el3_going_up => el3_going_up, el3_going_down => el3_going_down,
      rej_going_up_out => rej_up_next, rej_going_down_out => rej_down_next
  );

  process(clk)
  begin
    if rising_edge(clk) then
       rej_up <= rej_up_next;
       rej_down <= rej_down_next;
    end if;
  end process;
end arch;
