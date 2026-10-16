---------------------------------------
-- Packing - Posit (8,1)
-- Engineer: Matheus Viganó Schirrmann
-- Creation date: 25/09/2026
-- Last modification: 05/10/2026
-- Company: ProtoFPGA - UFSC
---------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Campos para o packing são regime | exp | fraction
-- O sinal será aplicado depois do rounding

entity posit_component_packing is
    port(
        k           : in  signed(4 downto 0);
        exponent    : in  std_logic;
        mantissa    : in  std_logic_vector(9 downto 0);

        positPacked : out std_logic_vector(7 downto 0);
        guardBit    : out std_logic;
        stickyBit   : out std_logic
    );
end posit_component_packing;

architecture Behavioral of posit_component_packing is
begin

    process(k, exponent, mantissa)

        variable k_int      : integer;
        variable m          : integer;
        variable posit_aux  : std_logic_vector(7 downto 0);
        variable guard_aux  : std_logic;
        variable sticky_aux : std_logic;
        variable frac_bits  : integer;

    begin

        k_int      := to_integer(k);
        posit_aux  := (others => '0');
        guard_aux  := '0';
        sticky_aux := '0';
        frac_bits  := 0;

        ------------------------------------------------
        -- Sign
        ------------------------------------------------
        -- O packing trabalha apenas com a magnitude.
        -- O sinal será aplicado depois do rounding.

        posit_aux(7) := '0';


        ------------------------------------------------
        -- Regime
        ------------------------------------------------

        if k_int < 0 then

            m := -k_int;

            -- Regime negativo:
            -- k = -1 -> 01
            -- k = -2 -> 001
            -- k = -3 -> 0001

            for i in 0 to 6 loop

                if i < m then
                    posit_aux(6-i) := '0';

                elsif i = m then
                    posit_aux(6-i) := '1';

                end if;

            end loop;

        else

            m := k_int + 1;

            -- Regime positivo:
            -- k = 0 -> 10
            -- k = 1 -> 110
            -- k = 2 -> 1110

            for i in 0 to 6 loop

                if i < m then
                    posit_aux(6-i) := '1';

                elsif i = m then
                    posit_aux(6-i) := '0';

                end if;

            end loop;

        end if;


        ------------------------------------------------
        -- Exponent
        ------------------------------------------------

        -- O expoente vem logo depois do regime.
        -- Percorremos todas as posições possíveis,
        -- mantendo os índices do vetor constantes.

        for i in 0 to 6 loop

            if i = (5-m) then
                posit_aux(i) := exponent;
            end if;

        end loop;


        ------------------------------------------------
        -- Fraction
        ------------------------------------------------

        if m <= 4 then
            frac_bits := 5-m;
        else
            frac_bits := 0;
        end if;

        -- Cada i representa um bit da fração original:
        --
        -- i=0 -> mantissa(7)
        -- i=1 -> mantissa(6)
        -- ...
        -- i=7 -> mantissa(0)

        for i in 0 to 7 loop

            for j in 0 to 6 loop

                if (i < frac_bits) and
                   (j = ((4-m)-i)) then

                    posit_aux(j) := mantissa(7-i);

                end if;

            end loop;

        end loop;


        ------------------------------------------------
        -- Guard Bit
        ------------------------------------------------

        -- Primeiro bit da fração que não coube.

        guard_aux := '0';

        for i in 0 to 7 loop

            if i = frac_bits then
                guard_aux := mantissa(7-i);
            end if;

        end loop;


        ------------------------------------------------
        -- Sticky Bit
        ------------------------------------------------

        -- OR de todos os bits depois do Guard Bit.

        sticky_aux := '0';

        for i in 0 to 7 loop

            if i > frac_bits then
                sticky_aux :=
                    sticky_aux OR mantissa(7-i);
            end if;

        end loop;


        ------------------------------------------------
        -- Outputs
        ------------------------------------------------

        positPacked <= posit_aux;
        guardBit    <= guard_aux;
        stickyBit   <= sticky_aux;

    end process;

end Behavioral;
