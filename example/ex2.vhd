---------------------------------------------------------------------------------
-- Library declaration
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------------------
-- Entity declaration
---------------------------------------------------------------------------------
entity ex2 is
  generic(
    reconf_pos  : std_logic_vector(1 downto 0) := "00";
    reconf_dir  : std_logic_vector(1 downto 0) := "00"        -- direction of connect
  );
  port(
    clk           : in  std_logic;      -- system clock
    en            : in  std_logic;      -- system enable
    rst_n         : in  std_logic;      -- system asynchronous reset, active low
    rcf_en        : in  std_logic;      -- reconfigured mode enable
    rcf_switch    : in  std_logic;      -- reconfigured mode: ip switch
    -- north port
    -- inport
    n_data_in     : in  std_logic_vector(33 downto 0);  -- data_in to north port.
    n_send_in     : in  std_logic_vector(1 downto 0);  -- send_in to north port.
    n_accept_in   : out std_logic_vector(1 downto 0);  -- accept_in from north port.
    -- outport
    n_data_out    : out std_logic_vector(33 downto 0);  -- data_out from north port.
    n_send_out    : out std_logic_vector(1 downto 0);  -- send_out from north port.
    n_accept_out  : in  std_logic_vector(1 downto 0);  -- accept_out to north port.
    -- east port
    -- inport
    e_data_in     : in  std_logic_vector(33 downto 0);  -- data_in to east port.
    e_send_in     : in  std_logic_vector(1 downto 0);  -- send_in to east port.
    e_accept_in   : out std_logic_vector(1 downto 0);  -- accept_in from east port.
    -- outport
    e_data_out    : out std_logic_vector(33 downto 0);  -- data_out from east port.
    e_send_out    : out std_logic_vector(1 downto 0);  -- send_out from east port.
    e_accept_out  : in  std_logic_vector(1 downto 0);  -- accept_out to east port.
    -- south port
    -- inport
    s_data_in     : in  std_logic_vector(33 downto 0);  -- data_in to south port.
    s_send_in     : in  std_logic_vector(1 downto 0);  -- send_in to south port.
    s_accept_in   : out std_logic_vector(1 downto 0);  -- accept_in from south port.
    -- outport
    s_data_out    : out std_logic_vector(33 downto 0);  -- data_out from south port.
    s_send_out    : out std_logic_vector(1 downto 0);  -- send_out from south port.
    s_accept_out  : in  std_logic_vector(1 downto 0);  -- accept_out to south port.
    -- west port
    -- inport
    w_data_in     : in  std_logic_vector(33 downto 0);  -- data_in to west port.
    w_send_in     : in  std_logic_vector(1 downto 0);  -- send_in to west port.
    w_accept_in   : out std_logic_vector(1 downto 0);  -- accept_in from west port.
    -- outport
    w_data_out    : out std_logic_vector(33 downto 0);  -- data_out from west port.
    w_send_out    : out std_logic_vector(1 downto 0);  -- send_out from west port.
    w_accept_out  : in  std_logic_vector(1 downto 0);  -- accept_out to west port.
    -- ip port
    -- inport
    l_data_in    : in  std_logic_vector(33 downto 0);  -- data_in to ip port.
    l_send_in    : in  std_logic_vector(1 downto 0);  -- send_in to ip port.
    l_accept_in  : out std_logic_vector(1 downto 0);  -- accept_in from ip port.
    -- outport
    l_data_out   : out std_logic_vector(33 downto 0);  -- data_out from ip port.
    l_send_out   : out std_logic_vector(1 downto 0);  -- send_out from ip port.
    l_accept_out : in  std_logic_vector(1 downto 0)  -- accept_out to ip port.
    );
end vsd_rero;

---------------------------------------------------------------------------------
-- Architecture description
---------------------------------------------------------------------------------
architecture rtl of vsd_rero is
  component vsd_nocr_inport is
     port (
      clk       : in  std_logic;                     -- System clock
      en        : in  std_logic;                     -- System enable signal
      rst_n     : in  std_logic;                     -- System asynchronous reset, active low

      data_in   : in  std_logic_vector(33 downto 0); -- Data in from previous router/IP.
      send_in   : in  std_logic_vector(1 downto 0);  -- send in from previous router/IP.
      accept_in : out std_logic_vector(1 downto 0);  -- accept in to previous router/IP.

      accept_out0 : in std_logic_vector(1 downto 0); -- accept out from outport 0
      accept_out1 : in std_logic_vector(1 downto 0); -- accept out from outport 1
      accept_out2 : in std_logic_vector(1 downto 0); -- accept out from outport 2
      accept_out3 : in std_logic_vector(1 downto 0); -- accept out from outport 3

      send_out0 : out std_logic_vector(1 downto 0);  -- send out to outport 0
      send_out1 : out std_logic_vector(1 downto 0);  -- send out to outport 1
      send_out2 : out std_logic_vector(1 downto 0);  -- send out to outport 2
      send_out3 : out std_logic_vector(1 downto 0);  -- send out to outport 3

      lock_out0 : out std_logic_vector(1 downto 0);  -- Lock out to outport 0
      lock_out1 : out std_logic_vector(1 downto 0);  -- Lock out to outport 1
      lock_out2 : out std_logic_vector(1 downto 0);  -- Lock out to outport 2
      lock_out3 : out std_logic_vector(1 downto 0);  -- Lock out to outport 3

      data_out0 : buffer  std_logic_vector(33 downto 0); -- Data out to crossbar 0
      dir_out0  : out     std_logic_vector(1 downto 0);  -- Select outport send to crossbar 0
      data_out1 : buffer  std_logic_vector(33 downto 0); -- Data out to crossbar 1
      dir_out1  : out     std_logic_vector(1 downto 0); -- Select outport send to crossbar 1

      rcf_en          : in  std_logic;
      rcf_data_out    : out std_logic_vector(33 downto 0);
      rcf_send_out    : out std_logic_vector(1 downto 0);
      rcf_accept_out  : in  std_logic_vector(1 downto 0));
  end component;

  component vsd_nocr_xbar is
    port (
      data_in0 : in std_logic_vector(33 downto 0);  -- data from inport 0
      dir_in0  : in std_logic_vector(1 downto 0);   -- direction from inport 0

      data_in1 : in std_logic_vector(33 downto 0);  -- data from inport 1
      dir_in1  : in std_logic_vector(1 downto 0);  -- direction from inport 1

      data_in2 : in std_logic_vector(33 downto 0);  -- data from inport 2
      dir_in2  : in std_logic_vector(1 downto 0);  -- direction from inport 2

      data_in3 : in std_logic_vector(33 downto 0);  -- data from inport 3
      dir_in3  : in std_logic_vector(1 downto 0);  -- direction from inport 3

      data_in4 : in std_logic_vector(33 downto 0);  -- data from inport 4
      dir_in4  : in std_logic_vector(1 downto 0);  -- direction from inport 4

      data_out0 : out std_logic_vector(33 downto 0);  -- data to outport 0
      dir_out0  : in  std_logic_vector(1 downto 0);  -- direction from outport 0

      data_out1 : out std_logic_vector(33 downto 0);  -- data to outport 1
      dir_out1  : in  std_logic_vector(1 downto 0);  -- direction from outport 1

      data_out2 : out std_logic_vector(33 downto 0);  -- data to outport 2
      dir_out2  : in  std_logic_vector(1 downto 0);  -- direction from outport 2

      data_out3 : out std_logic_vector(33 downto 0);  -- data to outport 3
      dir_out3  : in  std_logic_vector(1 downto 0);  -- direction from outport 3

      data_out4 : out std_logic_vector(33 downto 0);  -- data to outport 4
      dir_out4  : in  std_logic_vector(1 downto 0));  -- direction from outport 4
  end component;

  component vsd_nocr_outport is
    port (
         clk   : in std_logic;               -- System clock
         en    : in std_logic;               -- System Enable
         rst_n : in std_logic;               -- System reset, active low

         send_in0 : in std_logic_vector(1 downto 0);  -- send signal from port 0
         send_in1 : in std_logic_vector(1 downto 0);  -- send signal from port 1
         send_in2 : in std_logic_vector(1 downto 0);  -- send signal from port 2
         send_in3 : in std_logic_vector(1 downto 0);  -- send signal from port 3

         lock_in0 : in std_logic_vector(1 downto 0);  -- Lock send signal from port 0
         lock_in1 : in std_logic_vector(1 downto 0);  -- Lock send signal from port 1
         lock_in2 : in std_logic_vector(1 downto 0);  -- Lock send signal from port 2
         lock_in3 : in std_logic_vector(1 downto 0);  -- Lock send signal from port 3

         data_in0 : in std_logic_vector(33 downto 0);  -- Data_in from crossbar 0
         data_in1 : in std_logic_vector(33 downto 0);  -- data_in from crossbar 1

         accept_in0 : out std_logic_vector(1 downto 0);  -- accept signal to port 0
         accept_in1 : out std_logic_vector(1 downto 0);  -- accept signal to port 1
         accept_in2 : out std_logic_vector(1 downto 0);  -- accept signal to port 2
         accept_in3 : out std_logic_vector(1 downto 0);  -- accept signal to port 3

         dir_in0 : out std_logic_vector(1 downto 0);  -- Direction select to crossbar 0
         dir_in1 : out std_logic_vector(1 downto 0);  -- Direction select to crossbar 1

         data_out   : out std_logic_vector(33 downto 0);  -- Data out to next router/IP.
         send_out   : out std_logic_vector(1 downto 0);  -- send out to next router/IP.
         accept_out : in  std_logic_vector(1 downto 0);  -- send out to next router/IP.

         rcf_en          : in  std_logic;
         rcf_data_in     : in  std_logic_vector(33 downto 0);
         rcf_send_in     : in  std_logic_vector(1 downto 0);
         rcf_accept_in   : out std_logic_vector(1 downto 0));
  end component;

  component vsd_nocr_fixlink is
    generic(
      reconf_pos   : std_logic_vector(1 downto 0) := "00";       -- position of router
      reconf_dir  : std_logic_vector(1 downto 0) := "00"        -- direction of connect

    );
    port(
      rcf_switch          : in  std_logic;
      n_i_rcf_data_out    : in  std_logic_vector(33 downto 0); -- data from north in
      n_i_rcf_send_out    : in  std_logic_vector(1 downto 0);  -- send from north in
      n_i_rcf_accept_out  : out std_logic_vector(1 downto 0);  -- accept to north in
      e_i_rcf_data_out    : in  std_logic_vector(33 downto 0); -- data from north in
      e_i_rcf_send_out    : in  std_logic_vector(1 downto 0);  -- send from north in
      e_i_rcf_accept_out  : out std_logic_vector(1 downto 0);  -- accept to north in
      s_i_rcf_data_out    : in  std_logic_vector(33 downto 0); -- data from north in
      s_i_rcf_send_out    : in  std_logic_vector(1 downto 0);  -- send from north in
      s_i_rcf_accept_out  : out std_logic_vector(1 downto 0);  -- accept to north in
      w_i_rcf_data_out    : in  std_logic_vector(33 downto 0); -- data from north in
      w_i_rcf_send_out    : in  std_logic_vector(1 downto 0);  -- send from north in
      w_i_rcf_accept_out  : out std_logic_vector(1 downto 0);  -- accept to north in
      l_i_rcf_data_out    : in  std_logic_vector(33 downto 0); -- data from north in
      l_i_rcf_send_out    : in  std_logic_vector(1 downto 0);  -- send from north in
      l_i_rcf_accept_out  : out std_logic_vector(1 downto 0);  -- accept to north in
      n_o_rcf_data_in     : out std_logic_vector(33 downto 0); -- data to north out
      n_o_rcf_send_in     : out std_logic_vector(1 downto 0);  -- send to north out
      n_o_rcf_accept_in   : in  std_logic_vector(1 downto 0);  -- accept from north out
      e_o_rcf_data_in     : out std_logic_vector(33 downto 0); -- data to north out
      e_o_rcf_send_in     : out std_logic_vector(1 downto 0);  -- send to north out
      e_o_rcf_accept_in   : in  std_logic_vector(1 downto 0);  -- accept from north out
      s_o_rcf_data_in     : out std_logic_vector(33 downto 0); -- data to north out
      s_o_rcf_send_in     : out std_logic_vector(1 downto 0);  -- send to north out
      s_o_rcf_accept_in   : in  std_logic_vector(1 downto 0);  -- accept from north out
      w_o_rcf_data_in     : out std_logic_vector(33 downto 0); -- data to north out
      w_o_rcf_send_in     : out std_logic_vector(1 downto 0);  -- send to north out
      w_o_rcf_accept_in   : in  std_logic_vector(1 downto 0);  -- accept from north out
      l_o_rcf_data_in    : out std_logic_vector(33 downto 0); -- data to north out
      l_o_rcf_send_in    : out std_logic_vector(1 downto 0);  -- send to north out
      l_o_rcf_accept_in  : in  std_logic_vector(1 downto 0)  -- accept from north out
    );
  end component;

  signal n_i_data_in     : std_logic_vector(33 downto 0);
  signal n_i_send_in     : std_logic_vector(1 downto 0);
  signal n_i_accept_out0 : std_logic_vector(1 downto 0);
  signal n_i_accept_out1 : std_logic_vector(1 downto 0);
  signal n_i_accept_out2 : std_logic_vector(1 downto 0);
  signal n_i_accept_out3 : std_logic_vector(1 downto 0);
  signal n_i_accept_in   : std_logic_vector(1 downto 0);
  signal n_i_send_out0   : std_logic_vector(1 downto 0);
  signal n_i_send_out1   : std_logic_vector(1 downto 0);
  signal n_i_send_out2   : std_logic_vector(1 downto 0);
  signal n_i_send_out3   : std_logic_vector(1 downto 0);
  signal n_i_lock_out0   : std_logic_vector(1 downto 0);
  signal n_i_lock_out1   : std_logic_vector(1 downto 0);
  signal n_i_lock_out2   : std_logic_vector(1 downto 0);
  signal n_i_lock_out3   : std_logic_vector(1 downto 0);
  signal n_i_data_out0   : std_logic_vector(33 downto 0);
  signal n_i_dir_out0    : std_logic_vector(1 downto 0);
  signal n_i_data_out1   : std_logic_vector(33 downto 0);
  signal n_i_dir_out1    : std_logic_vector(1 downto 0);
  signal n_i_rcf_data_out : std_logic_vector(33 downto 0);
  signal n_i_rcf_send_out : std_logic_vector(1 downto 0);
  signal n_i_rcf_accept_out : std_logic_vector(1 downto 0);

  signal e_i_data_in     : std_logic_vector(33 downto 0);
  signal e_i_send_in     : std_logic_vector(1 downto 0);
  signal e_i_accept_out0 : std_logic_vector(1 downto 0);
  signal e_i_accept_out1 : std_logic_vector(1 downto 0);
  signal e_i_accept_out2 : std_logic_vector(1 downto 0);
  signal e_i_accept_out3 : std_logic_vector(1 downto 0);
  signal e_i_accept_in   : std_logic_vector(1 downto 0);
  signal e_i_send_out0   : std_logic_vector(1 downto 0);
  signal e_i_send_out1   : std_logic_vector(1 downto 0);
  signal e_i_send_out2   : std_logic_vector(1 downto 0);
  signal e_i_send_out3   : std_logic_vector(1 downto 0);
  signal e_i_lock_out0   : std_logic_vector(1 downto 0);
  signal e_i_lock_out1   : std_logic_vector(1 downto 0);
  signal e_i_lock_out2   : std_logic_vector(1 downto 0);
  signal e_i_lock_out3   : std_logic_vector(1 downto 0);
  signal e_i_data_out0   : std_logic_vector(33 downto 0);
  signal e_i_dir_out0    : std_logic_vector(1 downto 0);
  signal e_i_data_out1   : std_logic_vector(33 downto 0);
  signal e_i_dir_out1    : std_logic_vector(1 downto 0);
  signal e_i_rcf_data_out : std_logic_vector(33 downto 0);
  signal e_i_rcf_send_out : std_logic_vector(1 downto 0);
  signal e_i_rcf_accept_out : std_logic_vector(1 downto 0);

  signal s_i_data_in     : std_logic_vector(33 downto 0);
  signal s_i_send_in     : std_logic_vector(1 downto 0);
  signal s_i_accept_out0 : std_logic_vector(1 downto 0);
  signal s_i_accept_out1 : std_logic_vector(1 downto 0);
  signal s_i_accept_out2 : std_logic_vector(1 downto 0);
  signal s_i_accept_out3 : std_logic_vector(1 downto 0);
  signal s_i_accept_in   : std_logic_vector(1 downto 0);
  signal s_i_send_out0   : std_logic_vector(1 downto 0);
  signal s_i_send_out1   : std_logic_vector(1 downto 0);
  signal s_i_send_out2   : std_logic_vector(1 downto 0);
  signal s_i_send_out3   : std_logic_vector(1 downto 0);
  signal s_i_lock_out0   : std_logic_vector(1 downto 0);
  signal s_i_lock_out1   : std_logic_vector(1 downto 0);
  signal s_i_lock_out2   : std_logic_vector(1 downto 0);
  signal s_i_lock_out3   : std_logic_vector(1 downto 0);
  signal s_i_data_out0   : std_logic_vector(33 downto 0);
  signal s_i_dir_out0    : std_logic_vector(1 downto 0);
  signal s_i_data_out1   : std_logic_vector(33 downto 0);
  signal s_i_dir_out1    : std_logic_vector(1 downto 0);
  signal s_i_rcf_data_out : std_logic_vector(33 downto 0);
  signal s_i_rcf_send_out : std_logic_vector(1 downto 0);
  signal s_i_rcf_accept_out : std_logic_vector(1 downto 0);

  signal w_i_data_in     : std_logic_vector(33 downto 0);
  signal w_i_send_in     : std_logic_vector(1 downto 0);
  signal w_i_accept_out0 : std_logic_vector(1 downto 0);
  signal w_i_accept_out1 : std_logic_vector(1 downto 0);
  signal w_i_accept_out2 : std_logic_vector(1 downto 0);
  signal w_i_accept_out3 : std_logic_vector(1 downto 0);
  signal w_i_accept_in   : std_logic_vector(1 downto 0);
  signal w_i_send_out0   : std_logic_vector(1 downto 0);
  signal w_i_send_out1   : std_logic_vector(1 downto 0);
  signal w_i_send_out2   : std_logic_vector(1 downto 0);
  signal w_i_send_out3   : std_logic_vector(1 downto 0);
  signal w_i_lock_out0   : std_logic_vector(1 downto 0);
  signal w_i_lock_out1   : std_logic_vector(1 downto 0);
  signal w_i_lock_out2   : std_logic_vector(1 downto 0);
  signal w_i_lock_out3   : std_logic_vector(1 downto 0);
  signal w_i_data_out0   : std_logic_vector(33 downto 0);
  signal w_i_dir_out0    : std_logic_vector(1 downto 0);
  signal w_i_data_out1   : std_logic_vector(33 downto 0);
  signal w_i_dir_out1    : std_logic_vector(1 downto 0);
  signal w_i_rcf_data_out : std_logic_vector(33 downto 0);
  signal w_i_rcf_send_out : std_logic_vector(1 downto 0);
  signal w_i_rcf_accept_out : std_logic_vector(1 downto 0);

  signal l_i_data_in     : std_logic_vector(33 downto 0);
  signal l_i_send_in     : std_logic_vector(1 downto 0);
  signal l_i_accept_out0 : std_logic_vector(1 downto 0);
  signal l_i_accept_out1 : std_logic_vector(1 downto 0);
  signal l_i_accept_out2 : std_logic_vector(1 downto 0);
  signal l_i_accept_out3 : std_logic_vector(1 downto 0);
  signal l_i_accept_in   : std_logic_vector(1 downto 0);
  signal l_i_send_out0   : std_logic_vector(1 downto 0);
  signal l_i_send_out1   : std_logic_vector(1 downto 0);
  signal l_i_send_out2   : std_logic_vector(1 downto 0);
  signal l_i_send_out3   : std_logic_vector(1 downto 0);
  signal l_i_lock_out0   : std_logic_vector(1 downto 0);
  signal l_i_lock_out1   : std_logic_vector(1 downto 0);
  signal l_i_lock_out2   : std_logic_vector(1 downto 0);
  signal l_i_lock_out3   : std_logic_vector(1 downto 0);
  signal l_i_data_out0   : std_logic_vector(33 downto 0);
  signal l_i_dir_out0    : std_logic_vector(1 downto 0);
  signal l_i_data_out1   : std_logic_vector(33 downto 0);
  signal l_i_dir_out1    : std_logic_vector(1 downto 0);
  signal l_i_rcf_data_out : std_logic_vector(33 downto 0);
  signal l_i_rcf_send_out : std_logic_vector(1 downto 0);
  signal l_i_rcf_accept_out : std_logic_vector(1 downto 0);

  signal n_o_data_out   : std_logic_vector(33 downto 0);
  signal n_o_send_out   : std_logic_vector(1 downto 0);
  signal n_o_accept_out : std_logic_vector(1 downto 0);
  signal n_o_accept_in0 : std_logic_vector(1 downto 0);
  signal n_o_accept_in1 : std_logic_vector(1 downto 0);
  signal n_o_accept_in2 : std_logic_vector(1 downto 0);
  signal n_o_accept_in3 : std_logic_vector(1 downto 0);
  signal n_o_send_in0   : std_logic_vector(1 downto 0);
  signal n_o_send_in1   : std_logic_vector(1 downto 0);
  signal n_o_send_in2   : std_logic_vector(1 downto 0);
  signal n_o_send_in3   : std_logic_vector(1 downto 0);
  signal n_o_lock_in0   : std_logic_vector(1 downto 0);
  signal n_o_lock_in1   : std_logic_vector(1 downto 0);
  signal n_o_lock_in2   : std_logic_vector(1 downto 0);
  signal n_o_lock_in3   : std_logic_vector(1 downto 0);
  signal n_o_data_in0   : std_logic_vector(33 downto 0);
  signal n_o_dir_in0    : std_logic_vector(1 downto 0);
  signal n_o_data_in1   : std_logic_vector(33 downto 0);
  signal n_o_dir_in1    : std_logic_vector(1 downto 0);
  signal n_o_rcf_data_in : std_logic_vector(33 downto 0);
  signal n_o_rcf_send_in : std_logic_vector(1 downto 0);
  signal n_o_rcf_accept_in : std_logic_vector(1 downto 0);

  signal e_o_data_out   : std_logic_vector(33 downto 0);
  signal e_o_send_out   : std_logic_vector(1 downto 0);
  signal e_o_accept_out : std_logic_vector(1 downto 0);
  signal e_o_accept_in0 : std_logic_vector(1 downto 0);
  signal e_o_accept_in1 : std_logic_vector(1 downto 0);
  signal e_o_accept_in2 : std_logic_vector(1 downto 0);
  signal e_o_accept_in3 : std_logic_vector(1 downto 0);
  signal e_o_send_in0   : std_logic_vector(1 downto 0);
  signal e_o_send_in1   : std_logic_vector(1 downto 0);
  signal e_o_send_in2   : std_logic_vector(1 downto 0);
  signal e_o_send_in3   : std_logic_vector(1 downto 0);
  signal e_o_lock_in0   : std_logic_vector(1 downto 0);
  signal e_o_lock_in1   : std_logic_vector(1 downto 0);
  signal e_o_lock_in2   : std_logic_vector(1 downto 0);
  signal e_o_lock_in3   : std_logic_vector(1 downto 0);
  signal e_o_data_in0   : std_logic_vector(33 downto 0);
  signal e_o_dir_in0    : std_logic_vector(1 downto 0);
  signal e_o_data_in1   : std_logic_vector(33 downto 0);
  signal e_o_dir_in1    : std_logic_vector(1 downto 0);
  signal e_o_rcf_data_in : std_logic_vector(33 downto 0);
  signal e_o_rcf_send_in : std_logic_vector(1 downto 0);
  signal e_o_rcf_accept_in : std_logic_vector(1 downto 0);

  signal s_o_data_out   : std_logic_vector(33 downto 0);
  signal s_o_send_out   : std_logic_vector(1 downto 0);
  signal s_o_accept_out : std_logic_vector(1 downto 0);
  signal s_o_accept_in0 : std_logic_vector(1 downto 0);
  signal s_o_accept_in1 : std_logic_vector(1 downto 0);
  signal s_o_accept_in2 : std_logic_vector(1 downto 0);
  signal s_o_accept_in3 : std_logic_vector(1 downto 0);
  signal s_o_send_in0   : std_logic_vector(1 downto 0);
  signal s_o_send_in1   : std_logic_vector(1 downto 0);
  signal s_o_send_in2   : std_logic_vector(1 downto 0);
  signal s_o_send_in3   : std_logic_vector(1 downto 0);
  signal s_o_lock_in0   : std_logic_vector(1 downto 0);
  signal s_o_lock_in1   : std_logic_vector(1 downto 0);
  signal s_o_lock_in2   : std_logic_vector(1 downto 0);
  signal s_o_lock_in3   : std_logic_vector(1 downto 0);
  signal s_o_data_in0   : std_logic_vector(33 downto 0);
  signal s_o_dir_in0    : std_logic_vector(1 downto 0);
  signal s_o_data_in1   : std_logic_vector(33 downto 0);
  signal s_o_dir_in1    : std_logic_vector(1 downto 0);
  signal s_o_rcf_data_in : std_logic_vector(33 downto 0);
  signal s_o_rcf_send_in : std_logic_vector(1 downto 0);
  signal s_o_rcf_accept_in : std_logic_vector(1 downto 0);

  signal w_o_data_out   : std_logic_vector(33 downto 0);
  signal w_o_send_out   : std_logic_vector(1 downto 0);
  signal w_o_accept_out : std_logic_vector(1 downto 0);
  signal w_o_accept_in0 : std_logic_vector(1 downto 0);
  signal w_o_accept_in1 : std_logic_vector(1 downto 0);
  signal w_o_accept_in2 : std_logic_vector(1 downto 0);
  signal w_o_accept_in3 : std_logic_vector(1 downto 0);
  signal w_o_send_in0   : std_logic_vector(1 downto 0);
  signal w_o_send_in1   : std_logic_vector(1 downto 0);
  signal w_o_send_in2   : std_logic_vector(1 downto 0);
  signal w_o_send_in3   : std_logic_vector(1 downto 0);
  signal w_o_lock_in0   : std_logic_vector(1 downto 0);
  signal w_o_lock_in1   : std_logic_vector(1 downto 0);
  signal w_o_lock_in2   : std_logic_vector(1 downto 0);
  signal w_o_lock_in3   : std_logic_vector(1 downto 0);
  signal w_o_data_in0   : std_logic_vector(33 downto 0);
  signal w_o_dir_in0    : std_logic_vector(1 downto 0);
  signal w_o_data_in1   : std_logic_vector(33 downto 0);
  signal w_o_dir_in1    : std_logic_vector(1 downto 0);
  signal w_o_rcf_data_in : std_logic_vector(33 downto 0);
  signal w_o_rcf_send_in : std_logic_vector(1 downto 0);
  signal w_o_rcf_accept_in : std_logic_vector(1 downto 0);

  signal l_o_data_out   : std_logic_vector(33 downto 0);
  signal l_o_send_out   : std_logic_vector(1 downto 0);
  signal l_o_accept_out : std_logic_vector(1 downto 0);
  signal l_o_accept_in0 : std_logic_vector(1 downto 0);
  signal l_o_accept_in1 : std_logic_vector(1 downto 0);
  signal l_o_accept_in2 : std_logic_vector(1 downto 0);
  signal l_o_accept_in3 : std_logic_vector(1 downto 0);
  signal l_o_send_in0   : std_logic_vector(1 downto 0);
  signal l_o_send_in1   : std_logic_vector(1 downto 0);
  signal l_o_send_in2   : std_logic_vector(1 downto 0);
  signal l_o_send_in3   : std_logic_vector(1 downto 0);
  signal l_o_lock_in0   : std_logic_vector(1 downto 0);
  signal l_o_lock_in1   : std_logic_vector(1 downto 0);
  signal l_o_lock_in2   : std_logic_vector(1 downto 0);
  signal l_o_lock_in3   : std_logic_vector(1 downto 0);
  signal l_o_data_in0   : std_logic_vector(33 downto 0);
  signal l_o_dir_in0    : std_logic_vector(1 downto 0);
  signal l_o_data_in1   : std_logic_vector(33 downto 0);
  signal l_o_dir_in1    : std_logic_vector(1 downto 0);
  signal l_o_rcf_data_in : std_logic_vector(33 downto 0);
  signal l_o_rcf_send_in : std_logic_vector(1 downto 0);
  signal l_o_rcf_accept_in : std_logic_vector(1 downto 0);

begin
  -- @brief: map inport from north port
  n_i_vsd_nocr_inport_inst : vsd_nocr_inport
    port map(
      clk         => clk,
      en          => en,
      rst_n       => rst_n,
      data_in     => n_i_data_in,
      send_in     => n_i_send_in,
      accept_out0 => n_i_accept_out0,
      accept_out1 => n_i_accept_out1,
      accept_out2 => n_i_accept_out2,
      accept_out3 => n_i_accept_out3,
      accept_in   => n_i_accept_in,
      send_out0   => n_i_send_out0,
      send_out1   => n_i_send_out1,
      send_out2   => n_i_send_out2,
      send_out3   => n_i_send_out3,
      lock_out0   => n_i_lock_out0,
      lock_out1   => n_i_lock_out1,
      lock_out2   => n_i_lock_out2,
      lock_out3   => n_i_lock_out3,
      data_out0   => n_i_data_out0,
      dir_out0    => n_i_dir_out0,
      data_out1   => n_i_data_out1,
      dir_out1    => n_i_dir_out1,
      rcf_en      => rcf_en,
      rcf_data_out  => n_i_rcf_data_out,
      rcf_send_out  => n_i_rcf_send_out,
      rcf_accept_out  => n_i_rcf_accept_out
      );
  map_interface_north_in: block
  begin
    n_i_data_in     <= n_data_in;
    n_i_send_in     <= n_send_in;
    n_accept_in     <= n_i_accept_in;
    -- map internal signal
    n_i_accept_out0 <= l_o_accept_in0;
    n_i_accept_out1 <= e_o_accept_in0;
    n_i_accept_out2 <= s_o_accept_in0;
    n_i_accept_out3 <= w_o_accept_in0;
  end block;
  -- @brief: map inport from east port
  e_i_vsd_nocr_inport_inst : vsd_nocr_inport
    port map(
      clk         => clk,
      en          => en,
      rst_n       => rst_n,
      data_in     => e_i_data_in,
      send_in     => e_i_send_in,
      accept_out0 => e_i_accept_out0,
      accept_out1 => e_i_accept_out1,
      accept_out2 => e_i_accept_out2,
      accept_out3 => e_i_accept_out3,
      accept_in   => e_i_accept_in,
      send_out0   => e_i_send_out0,
      send_out1   => e_i_send_out1,
      send_out2   => e_i_send_out2,
      send_out3   => e_i_send_out3,
      lock_out0   => e_i_lock_out0,
      lock_out1   => e_i_lock_out1,
      lock_out2   => e_i_lock_out2,
      lock_out3   => e_i_lock_out3,
      data_out0   => e_i_data_out0,
      dir_out0    => e_i_dir_out0,
      data_out1   => e_i_data_out1,
      dir_out1    => e_i_dir_out1,
      rcf_en      => rcf_en,
      rcf_data_out  => e_i_rcf_data_out,
      rcf_send_out  => e_i_rcf_send_out,
      rcf_accept_out  => e_i_rcf_accept_out
      );
  -- map interface
  map_interface_east_in: block
  begin
    e_i_data_in     <= e_data_in;
    e_i_send_in     <= e_send_in;
    e_accept_in     <= e_i_accept_in;
    -- map internal signal
    e_i_accept_out1 <= l_o_accept_in1;
    e_i_accept_out0 <= n_o_accept_in1;
    e_i_accept_out2 <= s_o_accept_in1;
    e_i_accept_out3 <= w_o_accept_in1;
  end block;
  -- @brief: map inport from south port
  s_i_vsd_nocr_inport_inst : vsd_nocr_inport
    port map(
      clk         => clk,
      en          => en,
      rst_n       => rst_n,
      data_in     => s_i_data_in,
      send_in     => s_i_send_in,
      accept_out0 => s_i_accept_out0,
      accept_out1 => s_i_accept_out1,
      accept_out2 => s_i_accept_out2,
      accept_out3 => s_i_accept_out3,
      accept_in   => s_i_accept_in,
      send_out0   => s_i_send_out0,
      send_out1   => s_i_send_out1,
      send_out2   => s_i_send_out2,
      send_out3   => s_i_send_out3,
      lock_out0   => s_i_lock_out0,
      lock_out1   => s_i_lock_out1,
      lock_out2   => s_i_lock_out2,
      lock_out3   => s_i_lock_out3,
      data_out0   => s_i_data_out0,
      dir_out0    => s_i_dir_out0,
      data_out1   => s_i_data_out1,
      dir_out1    => s_i_dir_out1,
      rcf_en      => rcf_en,
      rcf_data_out  => s_i_rcf_data_out,
      rcf_send_out  => s_i_rcf_send_out,
      rcf_accept_out  => s_i_rcf_accept_out
      );
  map_interface_south_in: block
  begin
    s_i_data_in     <= s_data_in;
    s_i_send_in     <= s_send_in;
    s_accept_in     <= s_i_accept_in;
  -- map internal signal
    s_i_accept_out2 <= l_o_accept_in2;
    s_i_accept_out0 <= n_o_accept_in2;
    s_i_accept_out1 <= e_o_accept_in2;
    s_i_accept_out3 <= w_o_accept_in2;
  end block;
  -- @brief: map inport from west port
  w_i_vsd_nocr_inport_inst : vsd_nocr_inport
    port map(
      clk         => clk,
      en          => en,
      rst_n       => rst_n,
      data_in     => w_i_data_in,
      send_in     => w_i_send_in,
      accept_out0 => w_i_accept_out0,
      accept_out1 => w_i_accept_out1,
      accept_out2 => w_i_accept_out2,
      accept_out3 => w_i_accept_out3,
      accept_in   => w_i_accept_in,
      send_out0   => w_i_send_out0,
      send_out1   => w_i_send_out1,
      send_out2   => w_i_send_out2,
      send_out3   => w_i_send_out3,
      lock_out0   => w_i_lock_out0,
      lock_out1   => w_i_lock_out1,
      lock_out2   => w_i_lock_out2,
      lock_out3   => w_i_lock_out3,
      data_out0   => w_i_data_out0,
      dir_out0    => w_i_dir_out0,
      data_out1   => w_i_data_out1,
      dir_out1    => w_i_dir_out1,
      rcf_en      => rcf_en,
      rcf_data_out  => w_i_rcf_data_out,
      rcf_send_out  => w_i_rcf_send_out,
      rcf_accept_out  => w_i_rcf_accept_out
      );
  map_interface_west_in: block
  begin
    -- map interface
    w_i_data_in     <= w_data_in;
    w_i_send_in     <= w_send_in;
    w_accept_in     <= w_i_accept_in;
    -- map internal signal
    w_i_accept_out3 <= l_o_accept_in3;
    w_i_accept_out0 <= n_o_accept_in3;
    w_i_accept_out1 <= e_o_accept_in3;
    w_i_accept_out2 <= s_o_accept_in3;
  end block;
  -- @brief: map inport from ip port
  l_i_vsd_nocr_inport_inst : vsd_nocr_inport
    port map(
      clk         => clk,
      en          => en,
      rst_n       => rst_n,
      data_in     => l_i_data_in,
      send_in     => l_i_send_in,
      accept_out0 => l_i_accept_out0,
      accept_out1 => l_i_accept_out1,
      accept_out2 => l_i_accept_out2,
      accept_out3 => l_i_accept_out3,
      accept_in   => l_i_accept_in,
      send_out0   => l_i_send_out0,
      send_out1   => l_i_send_out1,
      send_out2   => l_i_send_out2,
      send_out3   => l_i_send_out3,
      lock_out0   => l_i_lock_out0,
      lock_out1   => l_i_lock_out1,
      lock_out2   => l_i_lock_out2,
      lock_out3   => l_i_lock_out3,
      data_out0   => l_i_data_out0,
      dir_out0    => l_i_dir_out0,
      data_out1   => l_i_data_out1,
      dir_out1    => l_i_dir_out1,
      rcf_en      => rcf_en,
      rcf_data_out  => l_i_rcf_data_out,
      rcf_send_out  => l_i_rcf_send_out,
      rcf_accept_out  => l_i_rcf_accept_out
      );
  map_interface_l_in: block
  begin
    l_i_data_in     <= l_data_in;
    l_i_send_in     <= l_send_in;
    l_accept_in     <= l_i_accept_in;
    -- map internal signal
    l_i_accept_out0 <= n_o_accept_in0;
    l_i_accept_out1 <= e_o_accept_in1;
    l_i_accept_out2 <= s_o_accept_in2;
    l_i_accept_out3 <= w_o_accept_in3;
  end block;
  -- @brief: map outport of north port
  n_o_vsd_nocr_outport_inst : vsd_nocr_outport
    port map(
      clk        => clk,
      en         => en,
      rst_n      => rst_n,
      send_in0   => n_o_send_in0,
      send_in1   => n_o_send_in1,
      send_in2   => n_o_send_in2,
      send_in3   => n_o_send_in3,
      lock_in0   => n_o_lock_in0,
      lock_in1   => n_o_lock_in1,
      lock_in2   => n_o_lock_in2,
      lock_in3   => n_o_lock_in3,
      data_in0   => n_o_data_in0,
      data_in1   => n_o_data_in1,
      accept_in0 => n_o_accept_in0,
      accept_in1 => n_o_accept_in1,
      accept_in2 => n_o_accept_in2,
      accept_in3 => n_o_accept_in3,
      dir_in0    => n_o_dir_in0,
      dir_in1    => n_o_dir_in1,
      data_out   => n_o_data_out,
      send_out   => n_o_send_out,
      accept_out => n_o_accept_out,
      rcf_en      => rcf_en,
      rcf_data_in  => n_o_rcf_data_in,
      rcf_send_in  => n_o_rcf_send_in,
      rcf_accept_in  => n_o_rcf_accept_in
      );
  map_interface_north_out: block
  begin
    -- map interface
    n_data_out     <= n_o_data_out;
    n_send_out     <= n_o_send_out;
    n_o_accept_out <= n_accept_out;
    -- map internal signal
    n_o_send_in0   <= l_i_send_out0;
    n_o_send_in1   <= e_i_send_out0;
    n_o_send_in2   <= s_i_send_out0;
    n_o_send_in3   <= w_i_send_out0;

    n_o_lock_in0 <= l_i_lock_out0;
    n_o_lock_in1 <= e_i_lock_out0;
    n_o_lock_in2 <= s_i_lock_out0;
    n_o_lock_in3 <= w_i_lock_out0;
  end block;
  -- @brief: map outport of east port
  e_o_vsd_nocr_outport_inst : vsd_nocr_outport
    port map(
      clk        => clk,
      en         => en,
      rst_n      => rst_n,
      send_in0   => e_o_send_in0,
      send_in1   => e_o_send_in1,
      send_in2   => e_o_send_in2,
      send_in3   => e_o_send_in3,
      lock_in0   => e_o_lock_in0,
      lock_in1   => e_o_lock_in1,
      lock_in2   => e_o_lock_in2,
      lock_in3   => e_o_lock_in3,
      data_in0   => e_o_data_in0,
      data_in1   => e_o_data_in1,
      accept_in0 => e_o_accept_in0,
      accept_in1 => e_o_accept_in1,
      accept_in2 => e_o_accept_in2,
      accept_in3 => e_o_accept_in3,
      dir_in0    => e_o_dir_in0,
      dir_in1    => e_o_dir_in1,
      data_out   => e_o_data_out,
      send_out   => e_o_send_out,
      accept_out => e_o_accept_out,
      rcf_en      => rcf_en,
      rcf_data_in  => e_o_rcf_data_in,
      rcf_send_in  => e_o_rcf_send_in,
      rcf_accept_in  => e_o_rcf_accept_in
      );
  map_interface_east_out: block
  begin
    -- map interface
    e_data_out     <= e_o_data_out;
    e_send_out     <= e_o_send_out;
    e_o_accept_out <= e_accept_out;
    -- map internal signal
    e_o_send_in1   <= l_i_send_out1;
    e_o_send_in0   <= n_i_send_out1;
    e_o_send_in2   <= s_i_send_out1;
    e_o_send_in3   <= w_i_send_out1;

    e_o_lock_in1 <= l_i_lock_out1;
    e_o_lock_in0 <= n_i_lock_out1;
    e_o_lock_in2 <= s_i_lock_out1;
    e_o_lock_in3 <= w_i_lock_out1;
  end block;
  -- @brief: map outport of south port
  s_o_vsd_nocr_outport_inst : vsd_nocr_outport
    port map(
      clk        => clk,
      en         => en,
      rst_n      => rst_n,
      send_in0   => s_o_send_in0,
      send_in1   => s_o_send_in1,
      send_in2   => s_o_send_in2,
      send_in3   => s_o_send_in3,
      lock_in0   => s_o_lock_in0,
      lock_in1   => s_o_lock_in1,
      lock_in2   => s_o_lock_in2,
      lock_in3   => s_o_lock_in3,
      data_in0   => s_o_data_in0,
      data_in1   => s_o_data_in1,
      accept_in0 => s_o_accept_in0,
      accept_in1 => s_o_accept_in1,
      accept_in2 => s_o_accept_in2,
      accept_in3 => s_o_accept_in3,
      dir_in0    => s_o_dir_in0,
      dir_in1    => s_o_dir_in1,
      data_out   => s_o_data_out,
      send_out   => s_o_send_out,
      accept_out => s_o_accept_out,
      rcf_en      => rcf_en,
      rcf_data_in  => s_o_rcf_data_in,
      rcf_send_in  => s_o_rcf_send_in,
      rcf_accept_in  => s_o_rcf_accept_in
      );
  map_interface_south_out: block
  begin
    -- map interface
    s_data_out     <= s_o_data_out;
    s_send_out     <= s_o_send_out;
    s_o_accept_out <= s_accept_out;
    -- map internal signal
    s_o_send_in2   <= l_i_send_out2;
    s_o_send_in0   <= n_i_send_out2;
    s_o_send_in1   <= e_i_send_out2;
    s_o_send_in3   <= w_i_send_out2;

    s_o_lock_in2 <= l_i_lock_out2;
    s_o_lock_in0 <= n_i_lock_out2;
    s_o_lock_in1 <= e_i_lock_out2;
    s_o_lock_in3 <= w_i_lock_out2;
  end block;
  -- @brief: map outport of west port
  w_o_vsd_nocr_outport_inst : vsd_nocr_outport
    port map(
      clk        => clk,
      en         => en,
      rst_n      => rst_n,
      send_in0   => w_o_send_in0,
      send_in1   => w_o_send_in1,
      send_in2   => w_o_send_in2,
      send_in3   => w_o_send_in3,
      lock_in0   => w_o_lock_in0,
      lock_in1   => w_o_lock_in1,
      lock_in2   => w_o_lock_in2,
      lock_in3   => w_o_lock_in3,
      data_in0   => w_o_data_in0,
      data_in1   => w_o_data_in1,
      accept_in0 => w_o_accept_in0,
      accept_in1 => w_o_accept_in1,
      accept_in2 => w_o_accept_in2,
      accept_in3 => w_o_accept_in3,
      dir_in0    => w_o_dir_in0,
      dir_in1    => w_o_dir_in1,
      data_out   => w_o_data_out,
      send_out   => w_o_send_out,
      accept_out => w_o_accept_out,
      rcf_en      => rcf_en,
      rcf_data_in  => w_o_rcf_data_in,
      rcf_send_in  => w_o_rcf_send_in,
      rcf_accept_in  => w_o_rcf_accept_in
      );
  map_interface_west_out: block
  begin
    -- map interface
    w_data_out     <= w_o_data_out;
    w_send_out     <= w_o_send_out;
    w_o_accept_out <= w_accept_out;
    -- map internal signal
    w_o_send_in3   <= l_i_send_out3;
    w_o_send_in0   <= n_i_send_out3;
    w_o_send_in1   <= e_i_send_out3;
    w_o_send_in2   <= s_i_send_out3;

    w_o_lock_in3 <= l_i_lock_out3;
    w_o_lock_in0 <= n_i_lock_out3;
    w_o_lock_in1 <= e_i_lock_out3;
    w_o_lock_in2 <= s_i_lock_out3;
  end block;
  -- @brief: map outport of ip port
  l_o_vsd_nocr_outport_inst : vsd_nocr_outport
    port map(
      clk        => clk,
      en         => en,
      rst_n      => rst_n,
      send_in0   => l_o_send_in0,
      send_in1   => l_o_send_in1,
      send_in2   => l_o_send_in2,
      send_in3   => l_o_send_in3,
      lock_in0   => l_o_lock_in0,
      lock_in1   => l_o_lock_in1,
      lock_in2   => l_o_lock_in2,
      lock_in3   => l_o_lock_in3,
      data_in0   => l_o_data_in0,
      data_in1   => l_o_data_in1,
      accept_in0 => l_o_accept_in0,
      accept_in1 => l_o_accept_in1,
      accept_in2 => l_o_accept_in2,
      accept_in3 => l_o_accept_in3,
      dir_in0    => l_o_dir_in0,
      dir_in1    => l_o_dir_in1,
      data_out   => l_o_data_out,
      send_out   => l_o_send_out,
      accept_out => l_o_accept_out,
      rcf_en      => rcf_en,
      rcf_data_in  => l_o_rcf_data_in,
      rcf_send_in  => l_o_rcf_send_in,
      rcf_accept_in  => l_o_rcf_accept_in
      );
  map_interface_l_out: block
  begin
  -- map interface
    l_data_out     <= l_o_data_out;
    l_send_out     <= l_o_send_out;
    l_o_accept_out <= l_accept_out;
    -- map internal signal
    l_o_send_in0   <= n_i_send_out0;
    l_o_send_in1   <= e_i_send_out1;
    l_o_send_in2   <= s_i_send_out2;
    l_o_send_in3   <= w_i_send_out3;

    l_o_lock_in0 <= n_i_lock_out0;
    l_o_lock_in1 <= e_i_lock_out1;
    l_o_lock_in2 <= s_i_lock_out2;
    l_o_lock_in3 <= w_i_lock_out3;
  end block;
  -- @brief: crossbar for virtual channel 0
  vsd_noc_xbar_inst_vc0 : vsd_nocr_xbar
    port map(
      data_in0 => n_i_data_out0,
      dir_in0  => n_i_dir_out0,
      data_in1 => e_i_data_out0,
      dir_in1  => e_i_dir_out0,
      data_in2 => s_i_data_out0,
      dir_in2  => s_i_dir_out0,
      data_in3 => w_i_data_out0,
      dir_in3  => w_i_dir_out0,
      data_in4 => l_i_data_out0,
      dir_in4  => l_i_dir_out0,
      data_out0 => n_o_data_in0,
      dir_out0  => n_o_dir_in0,
      data_out1 => e_o_data_in0,
      dir_out1  => e_o_dir_in0,
      data_out2 => s_o_data_in0,
      dir_out2  => s_o_dir_in0,
      data_out3 => w_o_data_in0,
      dir_out3  => w_o_dir_in0,
      data_out4 => l_o_data_in0,
      dir_out4  => l_o_dir_in0
      );

  -- @brief: crossbar for virtual channel 1
  vsd_noc_xbar_inst_vc1 : vsd_nocr_xbar
    port map(
      data_in0 => n_i_data_out1,
      dir_in0  => n_i_dir_out1,
      data_in1 => e_i_data_out1,
      dir_in1  => e_i_dir_out1,
      data_in2 => s_i_data_out1,
      dir_in2  => s_i_dir_out1,
      data_in3 => w_i_data_out1,
      dir_in3  => w_i_dir_out1,
      data_in4 => l_i_data_out1,
      dir_in4  => l_i_dir_out1,
      data_out0 => n_o_data_in1,
      dir_out0  => n_o_dir_in1,
      data_out1 => e_o_data_in1,
      dir_out1  => e_o_dir_in1,
      data_out2 => s_o_data_in1,
      dir_out2  => s_o_dir_in1,
      data_out3 => w_o_data_in1,
      dir_out3  => w_o_dir_in1,
      data_out4 => l_o_data_in1,
      dir_out4  => l_o_dir_in1
      );
  vsd_nocr_fixlink_inst : vsd_nocr_fixlink
    generic map(
      reconf_pos =>  reconf_pos,
      reconf_dir =>  reconf_dir
    )
    port map(
    rcf_switch          => rcf_switch,
    n_i_rcf_data_out    => n_i_rcf_data_out,
    n_i_rcf_send_out    => n_i_rcf_send_out,
    n_i_rcf_accept_out  => n_i_rcf_accept_out,
    e_i_rcf_data_out    => e_i_rcf_data_out,
    e_i_rcf_send_out    => e_i_rcf_send_out,
    e_i_rcf_accept_out  => e_i_rcf_accept_out,
    s_i_rcf_data_out    => s_i_rcf_data_out,
    s_i_rcf_send_out    => s_i_rcf_send_out,
    s_i_rcf_accept_out  => s_i_rcf_accept_out,
    w_i_rcf_data_out    => w_i_rcf_data_out,
    w_i_rcf_send_out    => w_i_rcf_send_out,
    w_i_rcf_accept_out  => w_i_rcf_accept_out,
    l_i_rcf_data_out   => l_i_rcf_data_out,
    l_i_rcf_send_out   => l_i_rcf_send_out,
    l_i_rcf_accept_out => l_i_rcf_accept_out,
    n_o_rcf_data_in     => n_o_rcf_data_in,
    n_o_rcf_send_in     => n_o_rcf_send_in,
    n_o_rcf_accept_in   => n_o_rcf_accept_in,
    e_o_rcf_data_in     => e_o_rcf_data_in,
    e_o_rcf_send_in     => e_o_rcf_send_in,
    e_o_rcf_accept_in   => e_o_rcf_accept_in,
    s_o_rcf_data_in     => s_o_rcf_data_in,
    s_o_rcf_send_in     => s_o_rcf_send_in,
    s_o_rcf_accept_in   => s_o_rcf_accept_in,
    w_o_rcf_data_in     => w_o_rcf_data_in,
    w_o_rcf_send_in     => w_o_rcf_send_in,
    w_o_rcf_accept_in   => w_o_rcf_accept_in,
    l_o_rcf_data_in    => l_o_rcf_data_in,
    l_o_rcf_send_in    => l_o_rcf_send_in,
    l_o_rcf_accept_in  => l_o_rcf_accept_in
    );
end rtl;
