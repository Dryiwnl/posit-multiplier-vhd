--
-- Mantissa Multiplier - Posit (8,1)
--
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 18/09/2026
-- Last modification: 23/09/2026
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity mantissa_multiplier is
    port (
        fractionA      : in  std_logic_vector(3 downto 0);
        fractionB      : in  std_logic_vector(3 downto 0);
        mantissaResult : out std_logic_vector(9 downto 0)
    );
end mantissa_multiplier;

architecture arch of mantissa_multiplier is

begin

    process(fractionA, fractionB)
        variable fractionAaux : unsigned(4 downto 0);
        variable fractionBaux : unsigned(4 downto 0);
    begin

        fractionAaux := unsigned('1' & fractionA);
        fractionBaux := unsigned('1' & fractionB);

        mantissaResult <= std_logic_vector(fractionAaux * fractionBaux);

    end process;

end architecture;