----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 29/09/2026
-- Last modification date: 29/09/2026
--
-- Module Name: tb_posit_rounding
-- Description: Testbench for Posit (8,1) rounding and sign application
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_posit_rounding is
end tb_posit_rounding;

architecture Behavioral of tb_posit_rounding is

    -- Inputs
    signal positPacked : std_logic_vector(7 downto 0);
    signal guardBit    : std_logic;
    signal stickyBit   : std_logic;
    signal sign        : std_logic;

    -- Output
    signal positRounded : std_logic_vector(7 downto 0);

begin

    DUT: entity work.posit_rounding
        port map(
            positPacked  => positPacked,
            guardBit     => guardBit,
            stickyBit    => stickyBit,
            sign         => sign,
            positRounded => positRounded
        );

    stimulus: process
    begin

        ------------------------------------------------
        -- Test 1: Sem arredondamento
        -- G=0, S=0
        -- Esperado: 40
        ------------------------------------------------

        positPacked <= x"40";
        guardBit    <= '0';
        stickyBit   <= '0';
        sign        <= '0';

        wait for 10 ns;


        ------------------------------------------------
        -- Test 2: Guard=0, Sticky=1
        -- Não arredonda
        -- Esperado: 64
        ------------------------------------------------

        positPacked <= x"64";
        guardBit    <= '0';
        stickyBit   <= '1';
        sign        <= '0';

        wait for 10 ns;


        ------------------------------------------------
        -- Test 3: Guard=1, Sticky=1
        -- Arredonda para cima
        -- Esperado: 66
        ------------------------------------------------

        positPacked <= x"65";
        guardBit    <= '1';
        stickyBit   <= '1';
        sign        <= '0';

        wait for 10 ns;


        ------------------------------------------------
        -- Test 4: Empate com L=0 (par)
        -- Mantém o valor
        -- Esperado: 64
        ------------------------------------------------

        positPacked <= x"64";
        guardBit    <= '1';
        stickyBit   <= '0';
        sign        <= '0';

        wait for 10 ns;


        ------------------------------------------------
        -- Test 5: Empate com L=1 (ímpar)
        -- Arredonda para o par
        -- Esperado: 66
        ------------------------------------------------

        positPacked <= x"65";
        guardBit    <= '1';
        stickyBit   <= '0';
        sign        <= '0';

        wait for 10 ns;


        ------------------------------------------------
        -- Test 6: Número negativo sem arredondamento
        -- Complemento de dois de 40 = C0
        ------------------------------------------------

        positPacked <= x"40";
        guardBit    <= '0';
        stickyBit   <= '0';
        sign        <= '1';

        wait for 10 ns;


        ------------------------------------------------
        -- Test 7: Número negativo com arredondamento
        -- 65 + 1 = 66
        -- Complemento de dois de 66 = 9A
        ------------------------------------------------

        positPacked <= x"65";
        guardBit    <= '1';
        stickyBit   <= '1';
        sign        <= '1';

        wait for 10 ns;


        ------------------------------------------------
        -- Test 8: Empate negativo com L=0
        -- Mantém 64 e aplica complemento de dois
        -- Esperado: 9C
        ------------------------------------------------

        positPacked <= x"64";
        guardBit    <= '1';
        stickyBit   <= '0';
        sign        <= '1';

        wait for 10 ns;

        wait;

    end process;

end Behavioral;
