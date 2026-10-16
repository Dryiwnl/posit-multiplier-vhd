----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 29/09/2026
-- Last modification date: 29/09/2026
--
-- Module Name: tb_posit_multiplier_top
-- Description: Testbench for Posit (8,1) multiplier
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_posit_multiplier_top is
end tb_posit_multiplier_top;

architecture Behavioral of tb_posit_multiplier_top is

    -- Inputs
    signal positA : std_logic_vector(7 downto 0);
    signal positB : std_logic_vector(7 downto 0);

    -- Output
    signal positResult : std_logic_vector(7 downto 0);

begin

    DUT: entity work.posit_multiplier_top
        port map(
            positA      => positA,
            positB      => positB,
            positResult => positResult
        );

    stimulus: process
    begin

        ------------------------------------------------
        -- Test 1: 1 × 1 = 1
        -- Esperado: 40
        ------------------------------------------------

        positA <= x"40";
        positB <= x"40";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 2: 2 × 2 = 4
        -- Esperado: 60
        ------------------------------------------------

        positA <= x"50";
        positB <= x"50";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 3: (-1) × 2 = -2
        -- Esperado: B0
        ------------------------------------------------

        positA <= x"C0";
        positB <= x"50";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 4: (-2) × (-2) = 4
        -- Esperado: 60
        ------------------------------------------------

        positA <= x"B0";
        positB <= x"B0";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 5: 0.5 × 2 = 1
        -- Esperado: 40
        ------------------------------------------------

        positA <= x"30";
        positB <= x"50";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 6: 1.5 × 1.5 = 2.25
        -- Esperado: 52
        ------------------------------------------------

        positA <= x"48";
        positB <= x"48";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 7: 4 × 4 = 16
        -- Esperado: 70
        ------------------------------------------------

        positA <= x"60";
        positB <= x"60";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 8: (-1) × (-1) = 1
        -- Esperado: 40
        ------------------------------------------------

        positA <= x"C0";
        positB <= x"C0";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 9: 1.25 × 1.5 = 1.875
        -- Esperado: 4E
        ------------------------------------------------

        positA <= x"44";
        positB <= x"48";
        wait for 10 ns;


        ------------------------------------------------
        -- Test 10: (-1.5) × 2 = -3
        -- Esperado: A8
        ------------------------------------------------

        positA <= x"B8";
        positB <= x"50";
        wait for 10 ns;

        wait;

    end process;

end Behavioral;
