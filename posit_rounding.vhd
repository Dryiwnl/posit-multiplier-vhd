---------------------------------------
-- Rounding - Posit (8,1)
-- Engineer: Matheus Viganó Schirrmann
-- Creation date: 28/09/2026
-- Last modification: 28/09/2026
-- Company: ProtoFPGA - UFSC
---------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity posit_rounding is
    port(
        positPacked : in  std_logic_vector(7 downto 0);
        guardBit    : in  std_logic;
        stickyBit   : in  std_logic;
        sign        : in  std_logic;

        positRounded : out std_logic_vector(7 downto 0)
    );
end posit_rounding;

architecture Behavioral of posit_rounding is
begin

    process(positPacked, guardBit, stickyBit, sign)

        variable roundUp     : std_logic;
        variable rounded_aux : std_logic_vector(7 downto 0);

    begin

        ------------------------------------------------
        -- Round to Nearest, Ties to Even
        ------------------------------------------------
        --
        -- L = positPacked(0)
        -- G = guardBit
        -- S = stickyBit
        --
        -- G = 0
        --     -> mantém
        --
        -- G = 1 e S = 1
        --     -> passou da metade -> soma 1
        --
        -- G = 1 e S = 0
        --     -> exatamente na metade
        --
        --     L = 0 -> mantém, pois já é par
        --     L = 1 -> soma 1, indo para o par
        ------------------------------------------------

        roundUp := guardBit AND
                   (stickyBit OR positPacked(0));


        ------------------------------------------------
        -- Rounding da magnitude
        ------------------------------------------------

        if roundUp = '1' then

            rounded_aux := std_logic_vector(
                unsigned(positPacked) + 1
            );

        else

            rounded_aux := positPacked;

        end if;


        ------------------------------------------------
        -- Aplicação do sinal
        ------------------------------------------------
        --
        -- O rounding é feito primeiro sobre a magnitude.
        --
        -- sign = 0 -> mantém a representação positiva
        -- sign = 1 -> complemento de dois
        ------------------------------------------------

        if sign = '0' then

            positRounded <= rounded_aux;

        else

            positRounded <= std_logic_vector(
                unsigned(not rounded_aux) + 1
            );

        end if;

    end process;

end Behavioral;