// This is booth's famous 2-bit pair algorithm
// It uses a pattern matching system for determining the multplication

module op_mul_64(input [63:0] Ain, Bin, output reg [127:0] Zout);
    reg [2:0] pattern;
    reg signed [63:0] multiplier_storage;
    reg signed [63:0] multiplicand_storage;
    reg signed [127:0] product_storage;

    integer i;

    always @ (*) begin
        product_storage = 128'b0;
        multiplier_storage = $signed(Ain);
        multiplicand_storage = $signed(Bin);
        multiplicand_storage = multiplicand_storage << 1;
        pattern = multiplier_storage[2:0];

        for (i = 0; i < 32; i = i + 1) begin
            case (pattern)
                // "000" and "111" are ignored, since they are 0 x M
                3'b001, 3'b010: product_storage = product_storage + multiplicand_storage;
                3'b011:         product_storage = product_storage + (multiplicand_storage << 1);
                3'b100:         product_storage = product_storage - (multiplicand_storage << 1);
                3'b101, 3'b110: product_storage = product_storage - multiplicand_storage;
                default: ; // 000 or 111, do nothing
            endcase

            multiplicand_storage = multiplicand_storage << 2;
            multiplier_storage = multiplier_storage >>> 2;
            pattern = multiplier_storage[2:0];
        end

        Zout = product_storage;
    end
endmodule


module op_mul_32(input [31:0] Ain, Bin, output reg [63:0] Zout);
    reg [2:0] pattern;
    reg signed [31:0] multiplier_storage;
    reg signed [31:0] multiplicand_storage;
    reg signed [63:0] product_storage;

    integer i;

    always @ (*) begin
        product_storage = 64'b0;
        multiplier_storage = $signed(Ain);
        multiplicand_storage = $signed(Bin);
        multiplicand_storage = multiplicand_storage << 1;
        pattern = multiplier_storage[2:0];

        for (i = 0; i < 16; i = i + 1) begin
            case (pattern)
                // "000" and "111" are ignored, since they are 0 x M
                3'b001, 3'b010: product_storage = product_storage + multiplicand_storage;
                3'b011:         product_storage = product_storage + (multiplicand_storage << 1);
                3'b100:         product_storage = product_storage - (multiplicand_storage << 1);
                3'b101, 3'b110: product_storage = product_storage - multiplicand_storage;
                default: ; // 000 or 111, do nothing
            endcase

            multiplicand_storage = multiplicand_storage << 2;
            multiplier_storage = multiplier_storage >>> 2;
            pattern = multiplier_storage[2:0];
        end

        Zout = product_storage;
    end
endmodule

// This was a version of it I wrote in VHDL...
// Not doing that again.
/*
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity op_mul_32 is 
	port(
		M: in std_logic_vector(31 DOWNTO 0); -- Multiplicand
		Q: in std_logic_vector(31 DOWNTO 0); -- Multiplier
		P: out std_logic_vector(63 DOWNTO 0)
	);
end entity;

architecture behavior of op_mul_32 is

begin
	process (M, Q)
		-- we will be adding onto the product_storage
		variable product_storage : signed (63 downto 0); -- this is our result
		
		-- this is used to keep track of what 2-bit pair pattern to select from
		variable multiplier_storage : signed (31 downto 0);
		
		-- this is to check what we will be adding
		variable multiplicand_storage : signed (31 downto 0);
		
		-- this is used simply as the pattern to match for when pairing
		variable M_bit_pattern : signed (2 downto 0);
	begin
		-- setup our variables
		product_storage := x"0000_0000_0000_0000";
		multiplier_storage := signed(Q);
		multiplicand_storage := signed(M);
		multiplicand_storage := multiplicand_storage sll 1;
		M_bit_pattern := multiplier_storage(2 downto 0);
		
		-- since this is 2-bit pairing, we need to only travel half the amount of bits
		for i in 0 to 15 loop
			
			-- check what pattern to use
			case M_bit_pattern is
				-- "000" and "111" are ignored, since they are 0 x M
				when "001" => -- +1 x M
					product_storage := product_storage + multiplicand_storage;
				when "010" => -- +1 x M
					product_storage := product_storage + multiplicand_storage;
				when "011" => -- +2 x M
					product_storage := product_storage + (multiplicand_storage + multiplicand_storage);
				when "100" => -- -2 x M
					product_storage := product_storage - (multiplicand_storage + multiplicand_storage);
				when "101" => -- -1 x M
					product_storage := product_storage - (multiplicand_storage);
				when "110" => -- -1 x M
					product_storage := product_storage - (multiplicand_storage);
				when others => null;
			end case;
			
			-- shift our multiplicand by 2, we will use this again to add onto it based
			-- on how the pattern is
			multiplicand_storage := multiplicand_storage sll 2;
			multiplier_storage := multiplier_storage srl 2; -- shifting to the right to remove pattern
			M_bit_pattern := multiplier_storage(2 downto 0); -- grabbing a new pattern
		end loop;
		
		P <= std_logic_vector(product_storage);
	end process;
end architecture;
*/