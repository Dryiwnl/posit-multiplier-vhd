----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 29/09/2026
-- Last modification date: 29/09/2026
--
-- Module Name: tb_normalization
-- Description: Testbench for Posit (8,1) normalization
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_normalization is
end tb_normalization;

architecture Behavioral of tb_normalization is

    -- Inputs
    signal mantissaResult : std_logic_vector(9 downto 0);
    signal kResult        : signed(4 downto 0);
    signal exponentResult : std_logic;

    -- Outputs
    signal mantissaNormalized       : std_logic_vector(9 downto 0);
    signal normalizationCarry       : std_logic;
    signal kResultNormalized        : signed(4 downto 0);
    signal exponentResultNormalized : std_logic;

begin

    DUT: entity work.normalization
        port map(
            mantissaResult           => mantissaResult,
            kResult                  => kResult,
            exponentResult          => exponentResult,
            mantissaNormalized       => mantissaNormalized,
            normalizationCarry       => normalizationCarry,
            kResultNormalized        => kResultNormalized,
            exponentResultNormalized => exponentResultNormalized
        );

    stimulus: process
    begin

        -- Test 1: Mantissa ja normalizada, expoente 0
        mantissaResult <= "0110000000";
        kResult        <= to_signed(2, 5);
        exponentResult <= '0';

        wait for 10 ns;


        -- Test 2: Mantissa ja normalizada, expoente 1
        mantissaResult <= "0101000000";
        kResult        <= to_signed(-2, 5);
        exponentResult <= '1';

        wait for 10 ns;


        -- Test 3: Shift necessario, expoente 0
        -- O expoente deve passar para 1
        mantissaResult <= "1001000000";
        kResult        <= to_signed(1, 5);
        exponentResult <= '0';

        wait for 10 ns;


        -- Test 4: Shift necessario, expoente 1
        -- O expoente volta para 0 e k aumenta
        mantissaResult <= "1010000000";
        kResult        <= to_signed(2, 5);
        exponentResult <= '1';

        wait for 10 ns;


        -- Test 5: Shift com regime negativo
        mantissaResult <= "1100000000";
        kResult        <= to_signed(-3, 5);
        exponentResult <= '1';

        wait for 10 ns;


        -- Test 6: Sem shift, regime negativo
        mantissaResult <= "0111100000";
        kResult        <= to_signed(-2, 5);
        exponentResult <= '0';

        wait for 10 ns;

        wait;

    end process;

end Behavioral;