-- Exhaustive Posit(8,1) multiplier verification using independent Python vectors.
-- Run GHDL from C:\FPGA\Posit_8_1_vivado
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use std.env.all;

entity tb_posit_exhaustive is
end entity;

architecture sim of tb_posit_exhaustive is
    signal positA      : std_logic_vector(7 downto 0) := (others => '0');
    signal positB      : std_logic_vector(7 downto 0) := (others => '0');
    signal positResult : std_logic_vector(7 downto 0);
begin
    dut: entity work.posit_multiplier_top
        port map (
            positA => positA,
            positB => positB,
            positResult => positResult
        );

    stimulus: process
        file vectors : text open read_mode is "verification/posit8_es1_all_pairs.txt";
        variable ln : line;
        variable a, b, expected : std_logic_vector(7 downto 0);
        variable cases, errors : natural := 0;
    begin
        while not endfile(vectors) loop
            readline(vectors, ln);
            hread(ln, a);
            hread(ln, b);
            hread(ln, expected);
            positA <= a;
            positB <= b;
            wait for 1 ns;
            cases := cases + 1;
            if positResult /= expected then
                errors := errors + 1;
                if errors <= 20 then
                    report "Mismatch A=" & to_hstring(a) &
                           " B=" & to_hstring(b) &
                           " expected=" & to_hstring(expected) &
                           " got=" & to_hstring(positResult)
                           severity warning;
                end if;
            end if;
        end loop;
        report "TOTAL=" & integer'image(cases) &
               " CORRECT=" & integer'image(cases - errors) &
               " ERRORS=" & integer'image(errors) severity note;
        assert cases = 65536 report "Vector file is incomplete" severity failure;
        assert errors = 0 report "Exhaustive Posit verification failed" severity failure;
        finish;
    end process;
end architecture;
