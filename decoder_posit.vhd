--
-- A posit (8,1) Decoder 
--
--
--Engineer: Matheus Viganó Schirrmann
--
--
--30/08/2026
--Last modification: 30/08/2026
--
--

library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity decoder_posit is
  port (
    posit_in : in std_logic_vector(7 downto 0);
    sign : out std_logic;
    k: out signed (3 downto 0);  
    exponent: out std_logic;
    fraction: out std_logic_vector(3 downto 0) --quantidade máxima de bits para fraction (8-1(s)-1(es)-2(rg) = 4)
  ) ;
end decoder_posit ; 

architecture arch of decoder_posit is
begin
    --EXTRAÇÃO DO BIT DE SINAL
    sign <= posit_in(7);
    -------------------------

    process (posit_in)
        variable m : integer;
        variable posit_aux : std_logic_vector(7 downto 0);
        variable exponent_begin: integer;
    begin
        m:=0;
        posit_aux := posit_in;

        if posit_in = "00000000" then
            k <= to_signed(0,4);
            exponent <= '0';
            fraction <= (others => '0');
        elsif posit_in = "10000000" then
            k <= to_signed(0,4);
            exponent <= '0';
            fraction <= (others => '0');
        else
        --VERIFICA SE POSIT_IN É POSITIVO OU NEGATIVO. SE FOR NEGATIVO, TIRA-SE 2´S
        if posit_in(7) = '0' then
            posit_aux := posit_in;
        else
            posit_aux := std_logic_vector(unsigned(not posit_aux) + 1);
        end if;
        ---------------------------------------------------------------------------

        --CONTA DA STRING BINÁRIA DO REGIME PARA SEQUENCIA DE 0 E 1. CONVERSÃO PARA K NO FINAL.
        if posit_aux(6) = '0' then
            for i in 6 downto 0 loop
                if posit_aux(i) = '1' then
                    exit;
                end if;
                m:=m+1;
            end loop;
            exponent_begin := 6-m-1; 
            if exponent_begin >= 0 then
                exponent <= posit_aux(exponent_begin);
            else
                exponent <= '0';
            end if;      
            m:=m*(-1);
        else
            for i in 6 downto 0 loop
                if posit_aux(i) = '0' then
                    exit;
                end if;
                m:=m+1;
            end loop;
            exponent_begin := 6-m-1; 
            if exponent_begin >= 0 then
                exponent <= posit_aux(exponent_begin);
            else
                exponent <= '0';
            end if;
            m:= m-1;
        end if;
        k <= to_signed(m, 4);
        --------------------------------------------------------------------------------------
        fraction <= (others => '0');
        if exponent_begin > 0 then
            for i in 0 to 3 loop
                if i < exponent_begin then
                    fraction(3-i) <= posit_aux(exponent_begin-1-i);
                end if;
            end loop;
        end if;
    end if;

end process;


end architecture ;