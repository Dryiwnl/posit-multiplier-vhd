----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 29/09/2026
-- Last modification date: 29/09/2026
--
-- Module Name: tb_sign_and_exponent_PU
-- Description: Testbench for Posit (8,1) sign and exponent processing unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_sign_and_exponent_PU is
end tb_sign_and_exponent_PU;

architecture Behavioral of tb_sign_and_exponent_PU is

    -- Inputs
    signal signA     : std_logic;
    signal signB     : std_logic;
    signal kA        : signed(3 downto 0);
    signal kB        : signed(3 downto 0);
    signal exponentA : std_logic;
    signal exponentB : std_logic;

    -- Outputs
    signal kResult        : signed(4 downto 0);
    signal signResult     : std_logic;
    signal exponentResult : std_logic;

begin

    DUT: entity work.sign_and_exponent_PU
        port map(
            signA          => signA,
            signB          => signB,
            kA             => kA,
            kB             => kB,
            exponentA      => exponentA,
            exponentB      => exponentB,
            kResult        => kResult,
            signResult     => signResult,
            exponentResult => exponentResult
        );

    stimulus: process
    begin

        -- Test 1: Dois números positivos, sem carry
        -- Esperado: sign=0, k=3, exponent=1

        signA <= '0';
        signB <= '0';
        kA <= to_signed(1, 4);
        kB <= to_signed(2, 4);
        exponentA <= '0';
        exponentB <= '1';

        wait for 10 ns;


        -- Test 2: Sinais diferentes, sem carry
        -- Esperado: sign=1, k=1, exponent=1

        signA <= '0';
        signB <= '1';
        kA <= to_signed(2, 4);
        kB <= to_signed(-1, 4);
        exponentA <= '1';
        exponentB <= '0';

        wait for 10 ns;


        -- Test 3: Dois expoentes iguais a 1
        -- Esperado: sign=0, k=2, exponent=0

        signA <= '1';
        signB <= '1';
        kA <= to_signed(2, 4);
        kB <= to_signed(-1, 4);
        exponentA <= '1';
        exponentB <= '1';

        wait for 10 ns;


        -- Test 4: Dois regimes negativos, com carry
        -- Esperado: sign=1, k=-4, exponent=0

        signA <= '1';
        signB <= '0';
        kA <= to_signed(-3, 4);
        kB <= to_signed(-2, 4);
        exponentA <= '1';
        exponentB <= '1';

        wait for 10 ns;


        -- Test 5: Expoentes iguais a zero
        -- Esperado: sign=0, k=0, exponent=0

        signA <= '0';
        signB <= '0';
        kA <= to_signed(3, 4);
        kB <= to_signed(-3, 4);
        exponentA <= '0';
        exponentB <= '0';

        wait for 10 ns;


        -- Test 6: Soma de regimes positivos com carry
        -- Esperado: sign=1, k=7, exponent=0

        signA <= '1';
        signB <= '0';
        kA <= to_signed(3, 4);
        kB <= to_signed(3, 4);
        exponentA <= '1';
        exponentB <= '1';

        wait for 10 ns;

        wait;

    end process;

end Behavioral;
