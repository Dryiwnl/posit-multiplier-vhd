----------------------------------------------------------------------------------
-- Company: ProtoFPGA - UFSC
-- Engineer: Matheus Viganó Schirrmann
-- Create Date: 23.09.2026 04:45:32
-- Module Name: posit_multiplier_top - Behavioral
-- Project Name: Posit multiplier (8,1)
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity posit_multiplier_top is
port (
    positA: in std_logic_vector(7 downto 0);
    positB: in std_logic_vector(7 downto 0);
    positResult : out std_logic_vector(7 downto 0)
);
end posit_multiplier_top;

architecture Behavioral of posit_multiplier_top is

signal signA: std_logic;
signal kA: signed (3 downto 0);
signal exponentA: std_logic;
signal fractionA: std_logic_vector(3 downto 0);

signal signB: std_logic;
signal kB: signed (3 downto 0);
signal exponentB: std_logic;
signal fractionB: std_logic_vector(3 downto 0);

signal signResult: std_logic;
signal kResult: signed(4 downto 0);
signal exponentResult: std_logic;

signal mantissaResult: std_logic_vector(9 downto 0);

signal mantissaNormalized: std_logic_vector(9 downto 0);
signal normalizationCarry: std_logic;
signal kResultNormalized: signed(4 downto 0);
signal exponentResultNormalized: std_logic;

signal positPacked: std_logic_vector(7 downto 0);
signal guardBit: std_logic;
signal stickyBit: std_logic;

signal positRounded: std_logic_vector(7 downto 0);

begin

--instancia do decoderA dentro do top
decoderA_inst: entity work.decoder_posit
    port map(
        posit_in => positA,
        sign => signA,
        k => kA,
        exponent => exponentA,
        fraction => fractionA    
    );

--instancia do decoderB dentro do top
decoderB_inst: entity work.decoder_posit
    port map(
        posit_in => positB,
        sign => signB,
        k => kB,
        exponent => exponentB,
        fraction => fractionB    
    );
    
--instancia do processing unit de sign e expoent dentro do top
 sign_and_exponent_PU_inst: entity work.sign_and_exponent_PU
    port map(
        signA => signA,
        signB => signB,
        
        kA => kA,
        kB => kB,
        
        exponentA => exponentA,
        exponentB => exponentB,
        
        signResult => signResult,
        kresult => kresult,
        exponentResult => exponentResult
    );
  
--instancia do mantissa multiplier dentro do top  
mantissa_multiplier_inst: entity work.mantissa_multiplier
    port map(
        fractionA => fractionA,
        fractionB => fractionB,
        mantissaResult => mantissaResult
    );
    
normalization_inst: entity work.normalization
    port map(
        mantissaResult => mantissaResult,
        mantissaNormalized => mantissaNormalized,
        kResult => kResult,
        exponentResult => exponentResult,
        normalizationCarry => normalizationCarry,
        kResultNormalized => kResultNormalized,
        exponentResultNormalized => exponentResultNormalized
    );
    
posit_packing_inst: entity work.posit_component_packing
    port map(
       k => kResultNormalized,
       exponent    => exponentResultNormalized,
       mantissa    => mantissaNormalized, 
       positPacked => positPacked,
       guardBit => guardBit,
       stickyBit => stickyBit
    );
    
posit_rounding_ints: entity work.posit_rounding
    port map(
        positPacked => positPacked,
        guardBit => guardBit,
        stickyBit => stickyBit,
        positRounded => positRounded,
        sign => signResult   
    );
    
    
    positResult <= positRounded;
end Behavioral;
