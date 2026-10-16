----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 29/09/2026
-- Last modification date: 29/09/2026
--
-- Module Name: tb_mantissa_multiplier
-- Description: Testbench for Posit (8,1) mantissa multiplier
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_mantissa_multiplier is
end tb_mantissa_multiplier;

architecture Behavioral of tb_mantissa_multiplier is

    -- Inputs
    signal fractionA : std_logic_vector(3 downto 0);
    signal fractionB : std_logic_vector(3 downto 0);

    -- Output
    signal mantissaResult : std_logic_vector(9 downto 0);

begin

    DUT: entity work.mantissa_multiplier
        port map(
            fractionA      => fractionA,
            fractionB      => fractionB,
            mantissaResult => mantissaResult
        );

    stimulus: process
    begin

        -- Test 1: 1.0000 * 1.0000 = 1
        fractionA <= "0000";
        fractionB <= "0000";
        wait for 10 ns;

        -- Test 2: 1.1000 * 1.0000 = 1.5
        fractionA <= "1000";
        fractionB <= "0000";
        wait for 10 ns;

        -- Test 3: 1.1000 * 1.1000 = 2.25
        fractionA <= "1000";
        fractionB <= "1000";
        wait for 10 ns;

        -- Test 4: 1.0100 * 1.1000 = 1.875
        fractionA <= "0100";
        fractionB <= "1000";
        wait for 10 ns;

        -- Test 5: 1.1111 * 1.1111
        fractionA <= "1111";
        fractionB <= "1111";
        wait for 10 ns;

        -- Test 6: 1.0010 * 1.0100
        fractionA <= "0010";
        fractionB <= "0100";
        wait for 10 ns;

        wait;

    end process;

end Behavioral;