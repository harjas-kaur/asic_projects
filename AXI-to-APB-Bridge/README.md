# Internship_IERY
This repository consists of all the prerequisites of the main AXI to APB project done as a part of our internship. We have designed and implemented it in Verilog. 
These include :
- Synchronous FIFO
- Asynchronous FIFO
-  Basic communication protocols:
   - SPI
   - I2c
   - UART
# Quick links :
- Files:
  - [Synchronous FIFO RTL](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/Synchronous%20FIFO.v)
  - [Synchronous FIFO testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/SynchronousFIFO_TB.v)
  - [Asynchronous FIFO RTL](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/Asynchronous%20FIFO.v)
  - [Asynchronous FIFO testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/AsynchronousFIFO_TB.v)
  - [SPI RTL](SPI.v)
  - [SPI testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/SPI%20tb.v)
  - [I2C RTL](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/i2c_master.v)
  - [I2C testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/i2c_master_tb.v)
  - [UART RTL](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/uart.v)
  - [UART testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/uart_tb.v)
  
- Navigation through the report :
  - [Introduction to FIFO](#1)
  - [Synchronous FIFO](#2)
     - [Operation](#3)
     - [Verilog Code](#4)
     - [Simulation Results](#5)
  - [Asynchronous FIFO](#6)
     - [Operation](#7)
     - [Verilog Code](#8)
     - [Simulation Results](#9)
  - [Communication Protocols](#10)
     - [SPI](#11)
       - [Block Diagram](#12)
       - [Timing Diagram](#13)
       - [State Diagram](#14)
       - [Verilog Code](#15)
       - [Simulation Results](#16)
     - [I2C](#17)
       - [Block Diagram](#18)
       - [Timing Diagram](#19)
       - [State Diagram](#20)
       - [Verilog Code](#21)
       - [Simulation Results](#22)
    - [UART](#23)
       - [Block Diagram](#24)
       - [Bit Rule](#25)
       - [State Diagram](#26)
       - [Verilog Code](#27)
       - [Simulation Results](#28)

<a name="1"></a>  
## FIFO 
FIFO, which stands for First In First Out, is a widely used and valuable design component serving the purpose of synchronization and facilitating communication between modules. 
Depth of FIFO: The depth of a FIFO refers to the number of slots or rows it contains, determining its storage capacity.
Width of FIFO: The width of a FIFO pertains to the number of bits that can be accommodated within each slot or row, defining its data storage capability.

FIFOs come in two primary types:
1. Synchronous FIFO
2. Asynchronous FIFO

These two types of FIFOs play pivotal roles in ensuring orderly data flow and synchronization between components in various digital systems.

<a name="2"></a>  
## SYNCHRONOUS FIFO 

In Synchronous FIFO, data read and write operations use the same clock frequency. Usually, they are used with high clock frequency to support high-speed systems.

<img width="568" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/650105c6-3ef0-4273-9c43-944c1aa3e8cf"> 

<a name="3"></a>  
### Synchronous FIFO Operation

Signals:
- wr_en: write enable
- wr_data: write data
- full: FIFO is full
- empty: FIFO is empty
- rd_en: read enable
- rd_data: read data
- w_ptr: write pointer
- r_ptr: read pointer    

**FIFO write operation:**
FIFO can store/write the wr_data at every posedge of the clock based on wr_en signal till it is full. The write pointer gets incremented on every data write in FIFO memory.

**FIFO read operation:**
The data can be taken out or read from FIFO at every posedge of the clock based on the rd_en signal till it is empty. The read pointer gets incremented on every data read from FIFO memory.

**Empty condition** 
w_ptr == r_ptr i.e. Write and read pointers has the same value.

**Full condition**
The full condition means every slot in the FIFO is occupied, but then w_ptr and r_ptr will again have the same value. Thus, it is not possible to determine whether it is a full or empty condition. 
Thus, the last slot of FIFO is intentionally kept empty, and the full condition can be written as ((w_ptr+1’b1) == r_ptr)

<a name="4"></a>  
### Synchronous FIFO Verilog Code
- [Design](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/Synchronous%20FIFO.v)
- [Testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/SynchronousFIFO_TB.v)

<a name="5"></a>  
### Simulation Results

<img width="909" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/421ce543-3ffe-4d9a-9393-fb4ac56783eb">


<a name="6"></a>  
## ASYNCHRONOUS FIFO

In asynchronous FIFO, data read and write operations use different clock frequencies. Since write and read clocks are not synchronized, it is referred to as asynchronous FIFO. Usually, these are used in systems where data need to pass from one clock domain to another which is generally termed as ‘clock domain crossing’. Thus, asynchronous FIFO helps to synchronize data flow between two systems working on different clocks.

<img width="608" alt="asyncfifo" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/66f921be-4309-496b-a2fe-962429a6c9fe">

<a name="7"></a>  
### Asynchronous FIFO Operation

**Signals:**
- wr_en: write enable
- wr_data: write data
- full: FIFO is full
- empty: FIFO is empty
- rd_en: read enable
- rd_data: read data
- b_wptr: binary write pointer
- g_wptr: gray write pointer
- b_wptr_next: binary write pointer next
- g_wptr_next: gray write pointer next
- b_rptr: binary read pointer
- g_rptr: gray read pointer
- b_rptr_next: binary read pointer next
- g_rptr_next: gray read pointer next
- b_rptr_sync: binary read pointer synchronized
- b_wptr_sync: binary write pointer synchronized

**Write Operation:** In the case of an asynchronous FIFO, the write operation is associated with the write clock domain. This means that the write pointer, which tracks the location where data is being written into the FIFO, is aligned with the write clock's timing.

**Read Operation:** Conversely, the read operation in an asynchronous FIFO is synchronized with the read clock domain. In this context, the read pointer, responsible for identifying the position from which data is being read, is aligned with the read clock's timing.

**Metastability Challenge:** Managing asynchronous FIFOs introduces a critical challenge related to metastability. The fact that write and read pointers operate in separate clock domains necessitates a mechanism for safely transferring data and status information between these domains.

**Mitigating Metastability:** To address this concern, we employ synchronizers, which are typically implemented using flip-flops. Specifically, we opt for a "2 flip-flop synchronizer" design. However, it's important to note that a single "2FF synchronizer" can effectively resolve metastability for just one bit.

**Multiple Synchronizers:** Given that both write and read pointers comprise multiple bits, we must employ multiple instances of the "2FF synchronizer." Each synchronizer handles a distinct bit of the pointers.

<img width="473" alt="2ffsynch" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/5f7ad223-30ef-4e13-98bb-43db05b8267b">

**Full and Empty Conditions:**
Efficiently detect full and empty conditions directly using gray-coded write and read pointers, eliminating the need for additional hardware to convert them into binary form.

Full condition - wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

Empty condition - rempty = (g_wptr_sync == g_rptr_next);

<a name="8"></a>  
### Asynchronous FIFO Verilog Code
- [Design](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/Asynchronous%20FIFO.v)
- [Testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/AsynchronousFIFO_TB.v)

<a name="9"></a>  
### Simulation Results

<img width="911" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/68bb2c4d-dd8a-421d-9b08-28aa892b69b3">


<a name="10"></a>  
## Communication protocols 
<a name="11"></a>  
## SPI - Serial Peripheral Interface

The Serial Peripheral Interface, SPI, is an interface specification for synchronous serial data transfer, using a clock.
- SPI supports half/full duplex serial communication.
- It is synchronous communication protocol.
- Four wire communication protocol.
- Most cases, one master multiple slave protocol but also supports multiple master configuration
- It supports max speed up to 10Mbps
- Master provides clock for synchronisation
- It supports 8 and 16 bit format.

  <a name="12"></a>  
 ### Block Diagram
 <img width="188" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/65e56af4-4552-4269-89fe-7d39897e3d5c">
 <img width="240" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/c4ba84bd-5251-4c66-a227-c2636c48e2e4">

<a name="13"></a>  
 ### Timing diagram / CPOL, CPHA
 <img width="401" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/c221bcdb-a943-4f73-9cfa-142f86a9b6dd">

<a name="14"></a>  
 ### State Diagram 
<img width="400" alt="spisd" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/a09744f9-4980-47d8-8e84-894da7e8dfa2">

 <a name="15"></a>  
### SPI Verilog Code
- [Design](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/SPI.v)
- [Testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/SPI%20tb.v)

<a name="16"></a>  
### Simulation results
<img width="784" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/21aeda57-bdb4-4dc7-b663-a22329d88afb">

<a name="17"></a>  
## I2C - Inter-Integrated Circuit
 - Serial Communication Protocol : I2C is an interface specification for synchronous serial data transfer, using a clock.
 -  Half/Full Duplex Suppor : I2C supports both half-duplex and full-duplex serial communication modes.
 -  Synchronous Communication : It is a synchronous communication protocol, utilizing a shared clock signal for synchronization.
 -  Two-Wire Communication Protocol: I2C is a two-wire protocol, consisting of a data line (SDA) and a clock line (SCL) for communication.
    - Serial Data Line (SDA): SDA is used for bidirectional data transfer between the master and slave devices.
    - Serial Clock Line (SCL): SCL provides the clock signal that synchronizes the data transfer between the master and slave devices.
- Master-Slave Configuration : In most cases, I2C follows a one-master-multiple-slaves protocol, but it also supports multiple master configurations.
- Maximum Speed : I2C supports maximum speeds of up to several Mbps, commonly ranging from 100 kbps (standard mode) to 3.4 Mbps (high-speed mode).
- Clock Source : The master device provides the clock signal for synchronization.
- Data Formats : I2C supports both 8-bit and 16-bit data formats for communication.

<a name="18"></a>  
 ### Block Diagram
<img width="466" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/2d896bf2-6086-4570-ba5d-b0a9937b570b">

<a name="19"></a>  
 ### Timing diagram 
<img width="695" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/19e0147e-7fdf-4b8c-af6c-5ece2d02aecf">

<a name="20"></a>  
 ### State Diagram 
<img width="459" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/56e3a421-5a9d-4da2-8954-afe6f2b77355">

 <a name="21"></a>  
### I2C Verilog Code
- [Design](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/i2c_master.v)
- [Testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/i2c_master_tb.v)

  <a name="22"></a>  
### Simulation results
![image](https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/0211bbb2-44be-4c53-84b9-2249f860d601)

<a name="23"></a>  
## UART - Universal Asynchronous Receiver/Transmitter

A UART (Universal Asynchronous Receiver/Transmitter) is a hardware module that enables asynchronous serial communication by converting parallel data to serial data, allowing electronic devices to transmit and receive data with start and stop bits for synchronization.

- Serial Communication : UART enables asynchronous serial communication.
- Two-Wire : Typically uses two wires (TX and RX) for data exchange.
- Point-to-Point : Primarily used for direct communication between two devices.
- Baud Rate : Requires a common baud rate for synchronization.
- Start and Stop Bits : Employs start and stop bits for data framing.
- Character Format : Supports variable character formats, often 8-N-1 (8 data bits, no parity, 1 stop bit).
- Full-Duplex : Allows simultaneous data transmission and reception.
- Versatile : Widely used in microcontroller, sensor, and peripheral communication.
- No Shared Clock : Unlike SPI or I2C, UART doesn't use a shared clock signal.
- No Addressing : Lacks built-in addressing; devices must coordinate data transfer.

<a name="24"></a>  
 ### Block Diagram
<img width="308" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/fb633a11-a5f2-4d80-a470-c5fedd1e780e">


<a name="25"></a>  
 ### Bit Rule
 <img width="323" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/40578d44-d088-4ed0-a4e1-bfbbca28600e">

<a name="26"></a>  
 ### State Diagram 
 Tx:
<img width="322" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/6e3eca25-7419-4dc3-a213-e98cf510a531">

RX:
<img width="328" alt="image" src="https://github.com/SanjanaHoskote/Internship_IERY/assets/128903809/8d61053b-901d-4817-8da4-96e81a1c2213">


<a name="27"></a>  
### UART Verilog Code
- [Design](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/uart.v)
- [Testbench](https://github.com/SanjanaHoskote/Internship_IERY/blob/main/uart_tb.v)

  <a name="28"></a>  
### Simulation results
<ss>


# AMBA-Protocols
AMBA (Advanced Microcontroller Bus Architecture) is a widely used and well-established set of protocols developed by ARM (now part of NVIDIA) for designing and interfacing components in a System-on-Chip (SoC) environment. AMBA protocols facilitate efficient communication between various IP (Intellectual Property) blocks within an SoC, such as processors, memory controllers, peripherals, and more.
The 2 protocols that I have designed using verilog RTL :
* APB (Advanced Peripheral Bus)
* AXI (Advanced eXtensible Interface)
# Quick Links 
- Files
   - [APB Design file](apb.v)
   - [APB Testbench](apb_tb.v)
   - [AXI slave design file](axi_slave.v)
   - [AXI testbench](axi_slave_tb.v)
- Navigation through the report
   - [Introduction to APB](#apb-advanced-peripheral-bus-protocol)
   - [APB master operation](#apb-master-operations)
   - [APB design using verilog RTL](#design-uisng-verilog-rtl)
   - [APB Simulation results](#simulation-using-xilinx-vivado)
   - [Introduction to AXI](#axi-advanced-extensible-interface-protocol)
   - [AXI slave operation](#axi-slave-operation)
   - [AXI slave design using verilog RTL](#axi-slave-design-using-verilog-rtl)
   - [AXI simulation results](#simulation-results)

# APB (Advanced Peripheral Bus) Protocol 
APB is a lower-performance protocol designed for connecting slower peripheral devices, such as simple I/O peripherals and control interfaces. It operates at a slower clock speed compared to AXI and is intended for components that do not require high bandwidth.
APB features include:
* A simpler and lower-overhead protocol compared to AXI.
* Single-channel interface with fewer signal lines.
* Designed for low-power and simpler peripherals.
* Suitable for peripherals that do not require high-speed data transfers.
## APB master operations 
- Write :
     - In an APB transaction, a write operation involves sending a request to a peripheral to write data to a specific register or memory location. The below timing diagram shows how the operartion is performed.

       <img width="356" alt="image" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/e8302965-448d-4859-8c75-08e9856e4f51">

- Read :
     - Read operation refers to the process of reading data from a peripheral component connected to an APB bus by a master.

       <img width="343" alt="image" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/a00a2bff-4d21-4dea-8300-0127df152e8a">

## Design uisng verilog RTL
- [apb.v](apb.v) : Design file
     - `PCLK` : The clock signal for synchronizing data transfers between the master and peripheral.
     - `PSEL` : Indicates whether the peripheral is selected for a read or write operation.
     - `PENABLE` : Signals that the data on the bus is valid and can be captured by the peripheral.
     - `PWRITE` : Specifies whether the operation is a read (0) or write (1).
     - `PWDATA` : Carries the data to be written to the peripheral during a write operation.
     - `PRDATA` : Contains the data read from the peripheral during a read operation.
     - `PADDR` : Specifies the address of the peripheral register to be accessed.
     - `PREADY` : Indicates that the peripheral is ready to accept data during a write operation or that valid data is available during a read operation. 

- [apb_tb.v](apb_tb.v) : Testbench file
- Operating states :
     - Shows the operating states of the APB interface.

       <img width="271" alt="image" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/c94bed88-7d0f-49cc-a593-c5591ee1de8f">

## Simulation using Xilinx Vivado
- Simulation output :
     - Behavioural Simulation.

       <img width="744" alt="waveform" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/9b64dafe-c8db-415d-8788-79517d35d2a7">

       
# AXI (Advanced eXtensible Interface) protocol 
AXI is a high-performance, high-bandwidth protocol designed for connecting high-performance IP components, such as processors and memory controllers. It is designed to support the needs of high-frequency, high-throughput systems while providing features to ensure data integrity and minimize latency. AXI has several versions, including AXI4 and AXI4-Lite, each with specific characteristics.
AXI features include:
* Separate read and write channels to allow concurrent data transfers.
* Support for out-of-order transactions to improve efficiency.
* Burst transfers for efficient data movement.
* Multiple transaction types (read, write, exclusive, etc.).
* Support for multiple outstanding transactions to maximize throughput.

## AXI slave operation 
- Write :
    - write operation timing diagram.

      <img width="341" alt="image" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/46f83d64-3927-44bb-866b-a490fca5dbb0">

- Read :
    - read operation timing diagram.

      <img width="342" alt="image" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/fcc3da14-5469-49a3-9508-d881a8b45a2f">

## AXI slave design using verilog RTL
- [axi_slave.v](axi_slave.v) : AXI slave interface design file
    - Read channel
        - `ARADDR` : Specifies the address for a read transaction.
        - `ARLEN` : Indicates the number of data transfers within a read burst.
        - `ARSIZE` : Specifies the size of each data transfer in a read burst.
        - `ARBURST` : Specifies the type of read burst (e.g., incrementing, wrapping).
        - `ARVALID` : Indicates that valid read address information is available.
        - `ARREADY` : Indicates that the slave is ready to accept the read address.
        - `RDATA` : Carries the data read from the slave.
        - `RRESP` : Indicates the response status of the read transaction (e.g., OKAY[1], ERROR[0]).
        - `RLAST` : Indicates the last data beat in a read burst.
        - `RVALID` : Indicates that valid read data is available.
        - `RREADY` : Indicates that the master is ready to accept the read data.
   - Write channel
       - `AWADDR` : Specifies the address for a write transaction.
       - `AWLEN` : Indicates the number of data transfers within a write burst.
       - `AWSIZE` : Specifies the size of each data transfer in a write burst.
       - `AWBURST` : Specifies the type of write burst (e.g., incrementing, wrapping).
       - `AWVALID` : Indicates that valid write address information is available.
       - `AWREADY` : Indicates that the slave is ready to accept the write address.
       - `WDATA` : Carries the data to be written by the master.
       - `WLAST` : Indicates the last data beat in a write burst.
       - `WVALID` : Indicates that valid write data is available.
       - `WREADY` : Indicates that the slave is ready to accept the write data.
       - `BRESP` : Indicates the response status of the write transaction (e.g., OKAY, ERROR).
       - `BVALID` : Indicates that a valid write response is available.
       - `BREADY` : Indicates that the master is ready to accept the write response.
- [axi_slave_tb.v](axi_slave_tb.v) : Testbench file.

## Simulation Results 
Simulation results from Xilinx Vivado 2014.4

<img width="744" alt="image" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/e3ada7d6-4bab-4818-9bfc-2829ae37affa">
<img width="745" alt="image" src="https://github.com/karthikkbs05/AMBA-Protocols/assets/129792064/951d4861-5df0-4098-8d35-bc670f27d3dc">

# AXI-to-APB-bridge
Welcome to the documentation for the AXI to APB Bridge project. Over the course of four months, our team embarked on a journey to create a basic AXI to APB Bridge with minimum signals, a fundamental piece in bridging the gap between different communication protocols within the realm of digital electronics.

## Quick links
- Files :
  - [APB to AXI bridge design module](bridge.v)
  - [Testbench module](bridge_tb.v)
- Navigation through the report :
  - [Project background](#project-background)
  - [Introduction to AXI to APB bridge](#understanding-axi-to-apb-bridge)
  - [Design using verilog RTL](#design-using-verilog-rtl)
  - [Simulation output](#simulation-output)

## Project background
- In the realm of digital design and system-on-chip (SoC) development, different components often communicate using various communication protocols. One such vital communication interface is the Advanced eXtensible Interface (AXI) and Advanced Peripheral Bus (APB) protocols, commonly used in FPGA and SoC design. The AXI protocol is a high-performance, high-frequency interface that enables communication between various IP blocks and memory in modern systems, while the APB protocol is a lower-frequency interface typically used for interfacing with peripheral components. Bridging these two protocols is essential for achieving seamless communication and ensuring the interoperability of different modules within a digital system.
- You can check out the design of AXI and APB protocols here :
    - [AXI protocol and APB protocol designs](https://github.com/karthikkbs05/AMBA-Protocols)
- You can check out the design of basic communication protocols here :
    - [SPI,I2C and UART protocol designs](https://github.com/SanjanaHoskote/Internship_IERY)

## Understanding AXI to APB bridge 
This section provides an in-depth understanding of the bridge's architecture, functionality, and the core principles governing its operation.
### Bridge architecture
- **AXI Slave Interface:**
   - This interface connects to the AXI master, serving as the entry point for AXI transactions into the bridge. It adheres to the AXI protocol specifications, including the AXI Read and Write channels. AXI transactions initiated by the AXI master are received and processed by this interface.
- **APB Master Interface:**
   - On the other side, the APB Master interface connects to up to four APB slaves. It functions as the exit point for translated transactions, allowing the bridge to communicate with APB-compliant peripheral devices. This interface adheres to the APB protocol, facilitating APB Read and Write operations to the connected slaves.
- Figure below shows the architecture of AXI to APB bridge.
  
    <img width="285" alt="image" src="https://github.com/karthikkbs05/AXI-to-APB-bridge/assets/129792064/c26cd8da-8895-4012-986c-a15e1041a2fa">

  
### Core funtionality
- **Read Transactions:**
   - When the AXI master initiates a read transaction, the bridge interprets the AXI Read channel signals and converts them into an appropriate APB Read operation. The read data from the selected APB slave is then conveyed back to the AXI master.
- **Write Transactions:**
   - Similarly, for AXI write transactions, the bridge translates the AXI Write channel signals into an APB Write operation. The data to be written is converted into APB format and sent to the selected APB slave.
- **Address Decoding:**
   - The bridge includes address decoding logic that maps AXI addresses to the respective APB slaves. This mapping ensures that AXI transactions are correctly routed to the intended APB peripherals based on the address range.
- **Data width:**
   - In the design, the data bus of AXI and APB are of same width.

## Design using verilog RTL 
- [bridge.v](bridge.v): Design module.
- [bridge_tb.v](bridge_tb.v): testbench module.
- Operation states.

    - Below figure shows the operation states of the bridge.

      <img width="258" alt="image" src="https://github.com/karthikkbs05/AXI-to-APB-bridge/assets/129792064/f75990f8-e18e-4e3d-a7f7-2c8826168b9d">

 ## Simulation output
Compiled and simulated using iverilog. GTKwave is used as simulation viewer.


![Screenshot from 2023-09-02 15-46-07](https://github.com/karthikkbs05/AXI-to-APB-bridge/assets/129792064/56f6255c-c991-4cde-ad8f-b0c6d2c2583f)


      










