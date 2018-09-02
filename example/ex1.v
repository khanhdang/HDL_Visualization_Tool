/*
* Project: OASIS
* Module : SECDED encoder module
* Revisions:
*            2015.12.16: First version.
*            2016.01.16: RAB, BLoD, SER, ECC, LAFT are completed
*/

module TWOD_PPC_enc_4_4(
  clk,
  reset,
  nack,
  data_in,
  data_out,
  f
);

parameter COL_NUM = 4;
parameter ROW_NUM = 4;
parameter OUTPUT_REG = 0;

input clk, reset;

input nack;
input  [COL_NUM*ROW_NUM-1:0] data_in;
output reg [(COL_NUM+1)*(ROW_NUM+1)-1:0] data_out;
reg [(COL_NUM+1)*(ROW_NUM+1)-1:0] prereg_data_out;
output f;

reg [1:0] r_tier1 [ROW_NUM-1:0];
reg [1:0] c_tier1 [COL_NUM-1:0];

reg [COL_NUM-1:0] c;
reg [ROW_NUM-1:0] r;
reg ur,uc;

reg f;

always @ (*) begin
  c_tier1[0][0] = data_in[0]^data_in[4];
  c_tier1[0][1] = data_in[8]^data_in[12];
  c_tier1[1][0] = data_in[1]^data_in[5];
  c_tier1[1][1] = data_in[9]^data_in[13];
  c_tier1[2][0] = data_in[2]^data_in[6];
  c_tier1[2][1] = data_in[10]^data_in[14];
  c_tier1[3][0] = data_in[3]^data_in[7];
  c_tier1[3][1] = data_in[11]^data_in[15];

  r_tier1[0][0] = data_in[0]^data_in[1];
  r_tier1[0][1] = data_in[2]^data_in[3];
  r_tier1[1][0] = data_in[4]^data_in[5];
  r_tier1[1][1] = data_in[6]^data_in[7];
  r_tier1[2][0] = data_in[8]^data_in[9];
  r_tier1[2][1] = data_in[10]^data_in[11];
  r_tier1[3][0] = data_in[12]^data_in[13];
  r_tier1[3][1] = data_in[14]^data_in[15];
end

always @(*) begin
  c[0] = c_tier1[0][0] ^ c_tier1[0][1];
  c[1] = c_tier1[1][0] ^ c_tier1[1][1];
  c[2] = c_tier1[2][0] ^ c_tier1[2][1];
  c[3] = c_tier1[3][0] ^ c_tier1[3][1];

  r[0] = r_tier1[0][0] ^ r_tier1[0][1];
  r[1] = r_tier1[1][0] ^ r_tier1[1][1];
  r[2] = r_tier1[2][0] ^ r_tier1[2][1];
  r[3] = r_tier1[3][0] ^ r_tier1[3][1];
end

always @ (*) begin
  uc = c[0] ^ c[1] ^ c[2] ^ c[3];
  ur = r[0] ^ r[1] ^ r[2] ^ r[3];
end

always @ (*) begin
  f = (uc ^ ur) | nack;
end

integer i,j;
always @ (*) begin
  for (i=0; i<ROW_NUM; i=i+1) begin
    for (j=0; j<COL_NUM; j=j+1) begin
      prereg_data_out[i*(COL_NUM+1)+j] = data_in [(i*COL_NUM)+j];
    end
    prereg_data_out[(i+1)*(COL_NUM+1)-1] = r[i];
  end
  prereg_data_out[(ROW_NUM)*(COL_NUM+1)+COL_NUM-1:(ROW_NUM)*(COL_NUM+1)] = c;
  prereg_data_out[(ROW_NUM)*(COL_NUM+1)+COL_NUM] = uc;
end
generate
if (OUTPUT_REG == 1) begin
  always @ (posedge clk) begin
    if (reset)
      data_out <= 0;
    else
      data_out <= prereg_data_out;
  end
end else begin
  always @(*) begin
    data_out = prereg_data_out;
  end
end
endgenerate
endmodule
