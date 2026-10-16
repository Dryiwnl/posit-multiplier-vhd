----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 29/09/2026
-- Last modification date: 29/09/2026
--
-- Module Name: tb_posit_component_packing
-- Description: Testbench for Posit (8,1) component packing
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_posit_component_packing is
end tb_posit_component_packing;

architecture Behavioral of tb_posit_component_packing is

    -- Inputs
    signal k        : signed(4 downto 0);
    signal exponent : std_logic;
    signal mantissa : std_logic_vector(9 downto 0);

    -- Outputs
    signal positPacked : std_logic_vector(7 downto 0);
    signal guardBit    : std_logic;
    signal stickyBit   : std_logic;

begin

    DUT: entity work.posit_component_packing
        port map(
            k           => k,
            exponent    => exponent,
            mantissa    => mantissa,
            positPacked => positPacked,
            guardBit    => guardBit,
            stickyBit   => stickyBit
        );

    stimulus: process
    begin

        ------------------------------------------------
        -- Test 1: k=0, e=0, mantissa=1.0
        -- Esperado: positPacked=40, G=0, S=0
        ------------------------------------------------

        k        <= to_signed(0, 5);
        exponent <= '0';
        mantissa <= "0100000000";

        wait for 10 ns;


        ------------------------------------------------
        -- Test 2: k=0, e=1
        -- Esperado: positPacked=5A, G=0, S=0
        ------------------------------------------------

        k        <= to_signed(0, 5);
        exponent <= '1';
        mantissa <= "0110100000";

        wait for 10 ns;


        ------------------------------------------------
        -- Test 3: Regime positivo
        -- Esperado: positPacked=66, G=0, S=0
        ------------------------------------------------

        k        <= to_signed(1, 5);
        exponent <= '0';
        mantissa <= "0111000000";

        wait for 10 ns;


        ------------------------------------------------
        -- Test 4: Regime negativo
        -- Esperado: positPacked=3A, G=0, S=0
        ------------------------------------------------

        k        <= to_signed(-1, 5);
        exponent <= '1';
        mantissa <= "0110100000";

        wait for 10 ns;


        -- Test 5: Guard = 1 e Sticky = 1
k        <= to_signed(1, 5);
exponent <= '0';
mantissa <= "0110111101";

wait for 10 ns;


-- Test 6: Guard = 1 e Sticky = 0
k        <= to_signed(1, 5);
exponent <= '0';
mantissa <= "0110110000";

wait for 10 ns;
        ------------------------------------------------
        -- Test 7: Regime negativo k=-2
        -- Esperado: positPacked=15, G=0, S=0
        ------------------------------------------------

        k        <= to_signed(-2, 5);
        exponent <= '0';
        mantissa <= "0110100000";

        wait for 10 ns;


        ------------------------------------------------
        -- Test 8: Regime positivo longo
        -- Esperado: positPacked=7B, G=1, S=0
        ------------------------------------------------

        k        <= to_signed(3, 5);
        exponent <= '1';
        mantissa <= "0110000000";

        wait for 10 ns;

        wait;

    end process;

end Behavioral;
