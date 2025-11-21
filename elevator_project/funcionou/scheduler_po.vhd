library IEEE;
use IEEE.std_logic_1164.all;
use work.custom_types.all;

entity scheduler_po is
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
end scheduler_po;

architecture arch of scheduler_po is
  signal going_up_calls, going_down_calls : call_vector((2**w)-1 downto 0);
  signal el1_caught_up, el1_caught_down : call_vector((2**w)-1 downto 0);
  signal el2_caught_up, el2_caught_down : call_vector((2**w)-1 downto 0);
  signal el3_caught_up, el3_caught_down : call_vector((2**w)-1 downto 0);

  -- FIXED: Explicit ranges added to match Entity exactly
  component call_catcher
    generic (w : natural := 5);
    port (
      current_floor     : in  std_logic_vector(w-1 downto 0);
      current_status    : in  std_logic_vector(1 downto 0);
      current_intention : in  std_logic_vector(1 downto 0);
      my_resp_id        : in  std_logic_vector(1 downto 0);
      going_up          : in  call_vector((2**w)-1 downto 0);
      going_down        : in  call_vector((2**w)-1 downto 0);
      going_up_caught   : out call_vector((2**w)-1 downto 0);
      going_down_caught : out call_vector((2**w)-1 downto 0)
    );
  end component;

  -- FIXED: Explicit ranges added here too
  component call_dispatcher
    generic (w : natural := 5);
    port (
      scan_direction    : in std_logic;
      going_up_caught   : in call_vector((2**w)-1 downto 0);
      going_down_caught : in call_vector((2**w)-1 downto 0);
      el1_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el1_going_down    : out std_logic_vector((2**w)-1 downto 0);
      el2_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el2_going_down    : out std_logic_vector((2**w)-1 downto 0);
      el3_going_up      : out std_logic_vector((2**w)-1 downto 0);
      el3_going_down    : out std_logic_vector((2**w)-1 downto 0);
      rej_going_up      : out call_vector((2**w)-1 downto 0);
      rej_going_down    : out call_vector((2**w)-1 downto 0)
    );
  end component;

begin
  -- Input Mixing
  gen_inputs : for i in 0 to ((2**w)-1) generate
    going_up_calls(i).score      <= (others => '0');
    going_up_calls(i).respondent <= "00";
    going_up_calls(i).active     <= going_up(i) or rej_up_in(i).active; 

    going_down_calls(i).score      <= (others => '0');
    going_down_calls(i).respondent <= "00";
    going_down_calls(i).active     <= going_down(i) or rej_down_in(i).active;
  end generate;

  -- Daisy Chain
  el1 : call_catcher generic map (w => w)
    port map (el1_floor, el1_status, el1_intention, "01", 
              going_up_calls, going_down_calls, el1_caught_up, el1_caught_down);
  el2 : call_catcher generic map (w => w)
    port map (el2_floor, el2_status, el2_intention, "10", 
              el1_caught_up, el1_caught_down, el2_caught_up, el2_caught_down);
  el3 : call_catcher generic map (w => w)
    port map (el3_floor, el3_status, el3_intention, "11", 
              el2_caught_up, el2_caught_down, el3_caught_up, el3_caught_down);

  -- Dispatcher
  disp : call_dispatcher generic map (w => w)
    port map (
      scan_direction    => scan_direction,
      going_up_caught   => el3_caught_up,
      going_down_caught => el3_caught_down,
      el1_going_up => el1_going_up, el1_going_down => el1_going_down,
      el2_going_up => el2_going_up, el2_going_down => el2_going_down,
      el3_going_up => el3_going_up, el3_going_down => el3_going_down,
      rej_going_up => rej_going_up_out,
      rej_going_down => rej_going_down_out
    );
end arch;
