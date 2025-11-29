library IEEE;
use IEEE.std_logic_1164.all;

entity scheduler_pc is
  port (
    clk           : in std_logic;
    reset         : in std_logic;
    scan_direction: out std_logic -- 1=UP, 0=DOWN
  );
end scheduler_pc;

architecture arch of scheduler_pc is
  type state_type is (CHECK_UP, CHECK_DOWN);
  signal current_state : state_type := CHECK_UP;
  signal next_state    : state_type;
begin
  process(clk, reset)
  begin
    if reset = '1' then
      current_state <= CHECK_UP;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;

  process(current_state)
  begin
    case current_state is
      when CHECK_UP =>
        scan_direction <= '1';
        next_state <= CHECK_DOWN;
      when CHECK_DOWN =>
        scan_direction <= '0';
        next_state <= CHECK_UP;
    end case;
  end process;
end arch;
