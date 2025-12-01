library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_tb is
end top_tb;

architecture sim of top_tb is
  constant w : natural := 5;
  constant CLK_PERIOD : time := 10 ns;
  constant SIMULATION_TIME : time := 2000 ns;  -- Tempo máximo de simulação

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
  
  signal simulation_finished : boolean := false;

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
    while not simulation_finished loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  -- Simulation Process (único driver para simulation_finished)
  stim_proc: process
  procedure send_requests(
      el1_kb_stim, el2_kb_stim, el3_kb_stim : in std_logic_vector(31 downto 0) := (others => '0');
      out_kb_up_stim, out_kb_down_stim      : in std_logic_vector(31 downto 0) := (others => '0');
      duration                              : in natural := 1
  ) is
  begin
    el1_kb <= el1_kb_stim;
    el2_kb <= el2_kb_stim;
    el3_kb <= el3_kb_stim;
    out_kb_up <= out_kb_up_stim;
    out_kb_down <= out_kb_down_stim;
    wait for CLK_PERIOD * duration;
    el1_kb <= (others => '0');
    el2_kb <= (others => '0');
    el3_kb <= (others => '0');
    out_kb_up <= (others => '0');
    out_kb_down <= (others => '0');
  end procedure;

    -- Variável para controle de timeout
    variable start_time : time;
    
  begin
    start_time := now;
    
    wait for CLK_PERIOD * 5;
    
    report "=== TESTE 1: Chamadas para Subir e Descer ===";
    
    -- Test 1: Press 'UP' button at Floors 4 and 6
    report "Chamada UP nos andares 0, 4 e 6";
    send_requests(
      out_kb_up_stim => (0 => '1', 4 => '1', 6 => '1', others => '0'),
      out_kb_down_stim => (others => '0')
    );
    -- Wait for elevator to potentially reach one of the floors
    wait for CLK_PERIOD * 20;
    
    report "=== TESTE 2: Chamadas externas simples ===";
    report "||Elevador 1: " & integer'image(to_integer(unsigned(el1_floor)));
    report "||Elevador 2: " & integer'image(to_integer(unsigned(el2_floor)));
    report "||Elevador 3: " & integer'image(to_integer(unsigned(el3_floor)));

    -- Test 2: Mixed calls
    report "Chamada UP no andar 2, DOWN nos andares 4 e 9";
    -- press_button(out_kb_down, (4 => '1', 9 => '1', others => '0'));

    send_requests(
      out_kb_up_stim => (2 => '1', others => '0'),
      out_kb_down_stim => (4 => '1', 9 => '1', others => '0')
    );

    wait for CLK_PERIOD * 40;

    report "=== TESTE 3: Chamadas Internas e Externas ===";
    report "||Elevador 1: " & integer'image(to_integer(unsigned(el1_floor)));
    report "||Elevador 2: " & integer'image(to_integer(unsigned(el2_floor)));
    report "||Elevador 3: " & integer'image(to_integer(unsigned(el3_floor)));

    -- Test 3: Internal and external calls in same clock cycle
    report "Chamadas Internas: EL1[3,9], EL3[4, 12]";
    send_requests(
        el1_kb_stim => (3 => '1', 9 => '1', others => '0'),
        el3_kb_stim => (4 => '1', 12 => '1', others => '0')
    );
    wait for CLK_PERIOD * 10;

    report "Chamadas Externas: UP[2, 14], DOWN[5, 18]";

    report "||Elevador 1: " & integer'image(to_integer(unsigned(el1_floor)));
    report "||Elevador 2: " & integer'image(to_integer(unsigned(el2_floor)));
    report "||Elevador 3: " & integer'image(to_integer(unsigned(el3_floor)));

    send_requests(
        out_kb_up_stim => (2 => '1',  14 => '1', others => '0'),
        out_kb_down_stim => (5 => '1', 18 => '1', others => '0')
    );

wait for CLK_PERIOD * 500;


    report "=== Testes Completos==="; 

    -- Stop simulation (único driver)
    simulation_finished <= true;
    wait;
  end process;

  -- Monitoring process to track elevator states
  monitor_process: process
    variable last_el1_floor : integer := -1;
    variable last_el2_floor : integer := -1;
    variable last_el3_floor : integer := -1;
  begin
    wait for CLK_PERIOD;
    
    if to_integer(unsigned(el1_floor)) /= last_el1_floor then
      report "Elevador 1: " & integer'image(to_integer(unsigned(el1_floor)));
      last_el1_floor := to_integer(unsigned(el1_floor));
    end if;
    
    if to_integer(unsigned(el2_floor)) /= last_el2_floor then
      report "Elevador 2: " & integer'image(to_integer(unsigned(el2_floor)));
      last_el2_floor := to_integer(unsigned(el2_floor));
    end if;
    
    if to_integer(unsigned(el3_floor)) /= last_el3_floor then
      report "Elevador 3: " & integer'image(to_integer(unsigned(el3_floor)));
      last_el3_floor := to_integer(unsigned(el3_floor));
    end if;
    
    -- Exit when simulation is finished
    if simulation_finished then
      wait;
    end if;
  end process;

  door_monitor: process(clk)
      variable el_num, el_floor : integer;
  begin
    if rising_edge(clk) then
      if el1_dr = '1' or el2_dr ='1' or el3_dr='1' then
        if el1_dr = '1' then
          el_num := 1;
          el_floor := to_integer(unsigned(el1_floor));
        elsif el2_dr = '1' then
          el_num := 2;
          el_floor := to_integer(unsigned(el2_floor));
        else
          el_num := 3;
          el_floor := to_integer(unsigned(el3_floor));
        end if;
        report "-- Elevador " & integer'image(el_num) & 
               " abrindo portas no andar " & integer'image(el_floor);
      end if;
    end if;
  end process;

end sim;