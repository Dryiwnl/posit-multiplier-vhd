-- Measurement wrapper for the combinational Posit(8,1) multiplier.
-- Registers isolate the combinational datapath for clock-to-clock timing.
library ieee;
use ieee.std_logic_1164.all;

entity posit_mul_synth_wrapper is
    port (
        clk    : in  std_logic;
        positA : in  std_logic_vector(7 downto 0);
        positB : in  std_logic_vector(7 downto 0);
        y      : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of posit_mul_synth_wrapper is
    signal a_reg, b_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal product_comb : std_logic_vector(7 downto 0);
    signal y_reg : std_logic_vector(7 downto 0) := (others => '0');
begin
    dut : entity work.posit_multiplier_top
        port map (
            positA => a_reg,
            positB => b_reg,
            positResult => product_comb
        );

    process(clk)
    begin
        if rising_edge(clk) then
            a_reg <= positA;
            b_reg <= positB;
            y_reg <= product_comb;
        end if;
    end process;

    y <= y_reg;
end architecture;
