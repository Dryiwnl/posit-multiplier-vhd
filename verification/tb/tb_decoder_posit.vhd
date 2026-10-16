----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 28/09/2026
-- Last modification date: 28/09/2026
--
-- Module Name: tb_decoder_posit
-- Description: Testbench for Posit (8,1) decoder
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_decoder_posit is
end tb_decoder_posit;

architecture Behavioral of tb_decoder_posit is

    signal posit_in : std_logic_vector(7 downto 0);
    signal sign     : std_logic;
    signal k        : signed(3 downto 0);
    signal exponent : std_logic;
    signal fraction : std_logic_vector(3 downto 0);

begin

    DUT: entity work.decoder_posit
        port map(
            posit_in => posit_in,
            sign     => sign,
            k        => k,
            exponent => exponent,
            fraction => fraction
        );


    stimulus: process
    begin
        --TESTES:
        
        posit_in <= "00000000";
        wait for 10 ns;

        posit_in <= "01000000";
        wait for 10 ns;

        posit_in <= "11000000";
        wait for 10 ns;

        posit_in <= "01100000";
        wait for 10 ns;

        posit_in <= "00100000";
        wait for 10 ns;

        posit_in <= "01010100";
        wait for 10 ns;

        posit_in <= "10000000";
        wait for 10 ns;
        
        posit_in <= "11110110";
        wait for 10 ns;
        
        posit_in <= "00010101";
        wait for 10 ns;

        wait;

    end process;

end Behavioral;
