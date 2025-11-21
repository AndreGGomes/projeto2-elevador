library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.custom_types.all;

entity call_dispatcher is
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
    rej_going_down    : out call_vector((2**w)-1 downto 0));
end call_dispatcher;

architecture arch of call_dispatcher is
begin
  gen : for i in 0 to (2**w)-1 generate
  begin
    -- Rejection Logic (Still depends on state)
    rej_going_up(i) <= (going_up_caught(i).active, (others => '0'), "00") when
                       (going_up_caught(i).respondent = "00" or scan_direction='0')
                       else ('0', (others => '0'), "00");
    rej_going_down(i) <= (going_down_caught(i).active, (others => '0'), "00") when
                       (going_down_caught(i).respondent = "00" or scan_direction='1')
                       else ('0', (others => '0'), "00");

    -- Output Logic (STABILIZED: Removed dependency on scan_direction)
    el1_going_up(i) <= going_up_caught(i).active when going_up_caught(i).respondent = "01" else '0';
    el2_going_up(i) <= going_up_caught(i).active when going_up_caught(i).respondent = "10" else '0';
    el3_going_up(i) <= going_up_caught(i).active when going_up_caught(i).respondent = "11" else '0';

    el1_going_down(i) <= going_down_caught(i).active when going_down_caught(i).respondent = "01" else '0';
    el2_going_down(i) <= going_down_caught(i).active when going_down_caught(i).respondent = "10" else '0';
    el3_going_down(i) <= going_down_caught(i).active when going_down_caught(i).respondent = "11" else '0';
  end generate;
end arch;
