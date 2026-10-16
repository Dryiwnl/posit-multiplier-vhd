
---------------------------------------
-- Packing - Posit (8,1)
-- Engineer: Matheus Viganó Schirrmann
-- Creation date: 25/09/2026
-- Last modification: 16/10/2026
-- Company: ProtoFPGA - UFSC
---------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Campos: regime | exponent | fraction
-- O sinal sera aplicado depois do rounding

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

        -- Packing trabalha apenas com a magnitude.
        posit_aux(7) := '0';

        ------------------------------------------------
        -- Regime
        ------------------------------------------------

        if k_int < 0 then

            m := -k_int;

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

        for i in 0 to 7 loop

            if i = frac_bits then
                guard_aux := mantissa(7-i);
            end if;

        end loop;

        ------------------------------------------------
        -- Sticky Bit
        ------------------------------------------------

        for i in 0 to 7 loop

            if i > frac_bits then
                sticky_aux :=
                    sticky_aux OR mantissa(7-i);
            end if;

        end loop;

        -- Preserva o bit descartado durante a normalizacao.
        -- Esse bit foi armazenado em mantissa(9)
        -- pelo modulo normalization.

        sticky_aux := sticky_aux OR mantissa(9);

        ------------------------------------------------
        -- Rounding nos regimes extremos
        ------------------------------------------------
        --
        -- Para k = -6:
        -- 0x01 representa minpos
        -- 0x02 representa 4 * minpos
        --
        -- Para k = 5:
        -- 0x7E representa 4^5
        -- 0x7F representa 4^6
        --
        -- Nos dois casos, o ponto medio entre
        -- os valores representaveis e 2.5 vezes
        -- o menor valor.
        --
        -- Como a mantissa normalizada representa
        -- 1.f em Q1.8, 1.25 corresponde a 320.
        --
        -- Com expoente = 1:
        -- mantissa > 1.25 -> arredonda para cima.
        --
        -- Em empate exato (mantissa = 1.25):
        -- k = -6 -> escolhe 0x02 (par).
        -- k = 5  -> escolhe 0x7E (par).
        ------------------------------------------------

        if (k_int = -6) or (k_int = 5) then

            guard_aux  := '0';
            sticky_aux := '0';

            if (exponent = '1') and
               (
                 (unsigned(mantissa(8 downto 0)) >
                  to_unsigned(320, 9))
                 or
                 (
                   (k_int = -6) and
                   (unsigned(mantissa(8 downto 0)) =
                    to_unsigned(320, 9))
                 )
               ) then

                guard_aux := '1';

                -- Para k = 5, o LSB de posit_aux e 0.
                -- Sticky = 1 permite incrementar.
                --
                -- Para k = -6, o LSB de posit_aux e 1.
                -- Guard = 1 ja permite incrementar.

                if k_int = 5 then
                    sticky_aux := '1';
                end if;

            end if;

        end if;

        ------------------------------------------------
        -- Outputs / Saturation
        ------------------------------------------------

        if k_int < -6 then

            -- Underflow: menor Posit positivo
            positPacked <= x"01";
            guardBit    <= '0';
            stickyBit   <= '0';

        elsif k_int >= 6 then

            -- Overflow: maior Posit positivo
            positPacked <= x"7F";
            guardBit    <= '0';
            stickyBit   <= '0';

        else

            positPacked <= posit_aux;
            guardBit    <= guard_aux;
            stickyBit   <= sticky_aux;

        end if;

    end process;

end Behavioral;
