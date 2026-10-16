--
-- Normalization After Mantissa Multiplication - Posit (8,1)
--
-- Engineer: Matheus Viganó Schirrmann
-- Creation date: 18/09/2026
-- Last modification: 25/09/2026
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity normalization is
    port (
        mantissaResult      : in  std_logic_vector(9 downto 0);
        kResult             : in signed(4 downto 0);
        exponentResult      : in std_logic;
        mantissaNormalized  : out std_logic_vector(9 downto 0);
        normalizationCarry  : out std_logic;
        kResultNormalized   : out signed(4 downto 0);
        exponentResultNormalized: out std_logic
    );
end normalization;

architecture arch of normalization is

-- Como estamos multiplicando duas mantissas que já estão na forma 1.f,
-- cada uma possui valor entre 1 <= MA < 2 e 1 <= MB < 2. Portanto, o resultado da
-- multiplicação fica entre 1 <= MAMB < 4.
--
-- Assim, antes da normalização, o resultado pode assumir as formas:
--
-- 01.xxxx -> já está normalizado
-- 10.xxxx -> necessita shift de 1 bit (muda a escala do número)
-- 11.xxxx -> necessita shift de 1 bit (muda a escala do número)

begin

    process(mantissaResult, kResult, exponentResult)
    begin
        kResultNormalized <= kresult;
        exponentResultNormalized <= exponentResult;
        if mantissaResult(9) = '1' then
            mantissaNormalized <= std_logic_vector(
                shift_right(unsigned(mantissaResult), 1)
            );
            normalizationCarry <= '1';
        else
            mantissaNormalized <= mantissaResult;
            normalizationCarry <= '0';
        end if;
        
-- Seguindo a mesma lógica da notação científica em base 10, ao normalizar a mantissa
-- através de um shift de 1 bit, um fator de 2^1 deve ser compensado na escala.
--
-- Verifica-se o bit 9 da mantissa multiplicada para saber se o shift é necessário:
-- se for 0 -> a mantissa já está normalizada e a escala permanece inalterada.
-- se for 1 e o expoente for 0 -> soma-se 1 ao expoente.
-- se for 1 e o expoente for 1 -> como o expoente possui apenas 1 bit, 1 + 1 gera
-- expoente 0 e carry. Esse carry é então passado para o ajuste "grosso" da escala,
-- incrementando k em 1.
        case mantissaResult(9) is
            when '0' => 
                kResultNormalized <= kResult;
                exponentResultNormalized <= exponentResult;
            
            when '1' =>
                if exponentResult = '0' then
                    exponentResultNormalized <= '1';
                 else 
                    exponentResultNormalized <= '0';
                    kResultNormalized <= kResult + 1;
                end if;
             when others =>
             null;
        end case;
        
    end process;

end architecture;
