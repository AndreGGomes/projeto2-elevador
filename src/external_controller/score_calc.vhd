library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity score_calc is
  generic (w : natural := 5);
  port (
    current_floor       : in std_logic_vector(w-1 downto 0);
    current_status      : in std_logic_vector(1 downto 0);
    current_intention   : in std_logic_vector(1 downto 0);
    target_floor        : in std_logic_vector(w-1 downto 0);
    target_intention    : in std_logic_vector(1 downto 0);
    -- MODIFICATION: Output width increased to match custom_types
    score               : out std_logic_vector(w+1 downto 0)
  );
end score_calc;

architecture arch of score_calc is
  signal dist : std_logic_vector(w-1 downto 0);
  constant MAX_VAL : unsigned(w-1 downto 0) := (others => '1');
  
  signal is_stopped, el_going_up, el_going_down : boolean;
  signal call_going_up, call_going_down : boolean;
  signal el_above_call, el_below_call : boolean;
  
  signal priority_val : std_logic_vector(1 downto 0);
  signal dist_score   : std_logic_vector(w-1 downto 0);

begin
  is_stopped    <= (current_status = "00");
  el_going_up   <= (current_status = "10");
  el_going_down <= (current_status = "01");
  
  call_going_up   <= (target_intention = "10");
  call_going_down <= (target_intention = "01");

  el_above_call <= unsigned(current_floor) >= unsigned(target_floor);
  el_below_call <= unsigned(current_floor) <= unsigned(target_floor);

  -- Distance Calculation (Inverted: Closer = Higher Value)
  dist <= std_logic_vector(MAX_VAL - (unsigned(current_floor) - unsigned(target_floor))) when el_above_call else
          std_logic_vector(MAX_VAL - (unsigned(target_floor) - unsigned(current_floor)));

  dist_score <= dist;

  -- Priority Logic (The "Smart" part from C++)
  process(is_stopped, el_going_up, el_going_down, current_intention, call_going_up, call_going_down, el_above_call, el_below_call)
  begin
      priority_val <= "00"; -- Default

      -- PRIORITY 1: Ideally positioned
      if (is_stopped) then
          priority_val <= "11";
      elsif (el_going_up and current_intention = "10" and call_going_up and el_below_call) then
          priority_val <= "11"; 
      elsif (el_going_down and current_intention = "01" and call_going_down and el_above_call) then
          priority_val <= "11"; 
      
      -- PRIORITY 2: Second Choice (Intercepting)
      elsif (el_above_call and el_going_down and current_intention = "10" and call_going_up) then
           priority_val <= "10";
      elsif (el_below_call and el_going_up and current_intention = "01" and call_going_down) then
           priority_val <= "10";
      end if;
  end process;

  score <= priority_val & dist_score;

end arch;
