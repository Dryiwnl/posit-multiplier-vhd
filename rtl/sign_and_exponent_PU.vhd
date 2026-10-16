--
-- Sign and Exponent Processing Unit - Posit (8,1)
--
-- Engineer: Matheus Viganó Schirrmann
--
-- Creation date: 01/09/2026
-- Last modification: 25/09/2026
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity sign_and_exponent_PU is
    port (
        signA          : in  std_logic;
        signB          : in  std_logic;

        kA             : in  signed(3 downto 0);
        kB             : in  signed(3 downto 0);

        exponentA      : in  std_logic;
        exponentB      : in  std_logic;

        kResult        : out signed(4 downto 0);
        signResult     : out std_logic;
        exponentResult : out std_logic
    );
end sign_and_exponent_PU;

architecture arch of sign_and_exponent_PU is

begin

    process(signA, signB, kA, kB, exponentA, exponentB)
        variable carry : std_logic;
    begin

        -- Cálculo do sinal resultante
        signResult <= signA XOR signB;

        -- Soma dos expoentes e verificação da possibilidade de carry
        exponentResult <= exponentA XOR exponentB;
        carry := exponentA AND exponentB;

        -- Pode ocorrer um valor kA + kB que não possa ser representado
        -- em 4 bits. Portanto, temporariamente, kResult utiliza 5 bits.
        -- Esse caso será tratado posteriormente no bloco de rounding.
        if carry = '1' then
            kResult <= resize(kA, 5) + resize(kB, 5) + 1;
        else
            kResult <= resize(kA, 5) + resize(kB, 5);
        end if;

    end process;

end architecture;
