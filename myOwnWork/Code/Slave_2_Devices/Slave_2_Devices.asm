
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;Slave_2_Devices.c,32 :: 		void interrupt()
;Slave_2_Devices.c,34 :: 		if(PIR1.RCIF)
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt0
;Slave_2_Devices.c,36 :: 		while(uart1_data_ready()==0);                           //while NO data in receive register
L_interrupt1:
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt2
	GOTO       L_interrupt1
L_interrupt2:
;Slave_2_Devices.c,37 :: 		if(uart1_data_ready()==1)                               //if data is ready for reading
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
;Slave_2_Devices.c,39 :: 		tempReceiveData = UART1_Read();
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _tempReceiveData+0
;Slave_2_Devices.c,40 :: 		if(tempReceiveData == 'S')                           //received "S", enter transmitting mode
	MOVF       R0+0, 0
	XORLW      83
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
;Slave_2_Devices.c,42 :: 		count=0;
	CLRF       _count+0
;Slave_2_Devices.c,43 :: 		receiveData[count] = tempReceiveData;
	MOVF       _count+0, 0
	ADDLW      _receiveData+0
	MOVWF      FSR
	MOVF       _tempReceiveData+0, 0
	MOVWF      INDF+0
;Slave_2_Devices.c,44 :: 		count++;
	INCF       _count+0, 1
;Slave_2_Devices.c,45 :: 		}
L_interrupt4:
;Slave_2_Devices.c,46 :: 		if(tempReceiveData !='S' && tempReceiveData !='E')
	MOVF       _tempReceiveData+0, 0
	XORLW      83
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
	MOVF       _tempReceiveData+0, 0
	XORLW      69
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
L__interrupt40:
;Slave_2_Devices.c,48 :: 		receiveData[count] = tempReceiveData;
	MOVF       _count+0, 0
	ADDLW      _receiveData+0
	MOVWF      FSR
	MOVF       _tempReceiveData+0, 0
	MOVWF      INDF+0
;Slave_2_Devices.c,49 :: 		count++;
	INCF       _count+0, 1
;Slave_2_Devices.c,50 :: 		}
L_interrupt7:
;Slave_2_Devices.c,51 :: 		if(tempReceiveData == 'E')                           //Receive EVERYTHING indicate by byte E, then flagReceiveAllData turns into bit 1
	MOVF       _tempReceiveData+0, 0
	XORLW      69
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt8
;Slave_2_Devices.c,53 :: 		receiveData[count] = tempReceiveData;
	MOVF       _count+0, 0
	ADDLW      _receiveData+0
	MOVWF      FSR
	MOVF       _tempReceiveData+0, 0
	MOVWF      INDF+0
;Slave_2_Devices.c,54 :: 		count=0;
	CLRF       _count+0
;Slave_2_Devices.c,55 :: 		flagReceivedAllData = 1;
	MOVLW      1
	MOVWF      _flagReceivedAllData+0
;Slave_2_Devices.c,56 :: 		}
L_interrupt8:
;Slave_2_Devices.c,57 :: 		}
L_interrupt3:
;Slave_2_Devices.c,58 :: 		}
L_interrupt0:
;Slave_2_Devices.c,59 :: 		}
L_end_interrupt:
L__interrupt46:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;Slave_2_Devices.c,60 :: 		void main() {
;Slave_2_Devices.c,61 :: 		TRISB.B0 =0;                         //RB0 is output, shall become input if TRISB.B0=1
	BCF        TRISB+0, 0
;Slave_2_Devices.c,62 :: 		TRISB.B4 =0;
	BCF        TRISB+0, 4
;Slave_2_Devices.c,63 :: 		TRISB.B5 =0;
	BCF        TRISB+0, 5
;Slave_2_Devices.c,65 :: 		TRISB.B3 =0;                         //Bit RS485, output
	BCF        TRISB+0, 3
;Slave_2_Devices.c,67 :: 		oldstate = 0;
	BCF        _oldstate+0, BitPos(_oldstate+0)
;Slave_2_Devices.c,68 :: 		UART1_Init(9600);                    //init UART1 with baudrate 9600 (capable of transferring a maximum of 9600 bits per second)
	MOVLW      129
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;Slave_2_Devices.c,69 :: 		Delay_ms(100);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_main9:
	DECFSZ     R13+0, 1
	GOTO       L_main9
	DECFSZ     R12+0, 1
	GOTO       L_main9
	DECFSZ     R11+0, 1
	GOTO       L_main9
	NOP
	NOP
;Slave_2_Devices.c,71 :: 		RCIE_bit = 1;                        // enable interrupt on UART1 receive
	BSF        RCIE_bit+0, BitPos(RCIE_bit+0)
;Slave_2_Devices.c,72 :: 		TXIE_bit = 0;                        // disable interrupt on UART1 transmit
	BCF        TXIE_bit+0, BitPos(TXIE_bit+0)
;Slave_2_Devices.c,73 :: 		PEIE_bit = 1;                        // enable peripheral interrupts
	BSF        PEIE_bit+0, BitPos(PEIE_bit+0)
;Slave_2_Devices.c,74 :: 		GIE_bit = 1;                         // enable all interrupts
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;Slave_2_Devices.c,77 :: 		addressDevice1[0] = '0';             //device ID 1: 0
	MOVLW      48
	MOVWF      _addressDevice1+0
;Slave_2_Devices.c,78 :: 		addressDevice1[1] = '4';             //device ID 1: 1
	MOVLW      52
	MOVWF      _addressDevice1+1
;Slave_2_Devices.c,79 :: 		addressDevice2[0] = '0';
	MOVLW      48
	MOVWF      _addressDevice2+0
;Slave_2_Devices.c,80 :: 		addressDevice2[1] = '5';
	MOVLW      53
	MOVWF      _addressDevice2+1
;Slave_2_Devices.c,81 :: 		addressDevice3[0] = '0';
	MOVLW      48
	MOVWF      _addressDevice3+0
;Slave_2_Devices.c,82 :: 		addressDevice3[1] = '6';
	MOVLW      54
	MOVWF      _addressDevice3+1
;Slave_2_Devices.c,93 :: 		Delay_ms(100);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_main10:
	DECFSZ     R13+0, 1
	GOTO       L_main10
	DECFSZ     R12+0, 1
	GOTO       L_main10
	DECFSZ     R11+0, 1
	GOTO       L_main10
	NOP
	NOP
;Slave_2_Devices.c,111 :: 		Delay_ms(1000);
	MOVLW      26
	MOVWF      R11+0
	MOVLW      94
	MOVWF      R12+0
	MOVLW      110
	MOVWF      R13+0
L_main11:
	DECFSZ     R13+0, 1
	GOTO       L_main11
	DECFSZ     R12+0, 1
	GOTO       L_main11
	DECFSZ     R11+0, 1
	GOTO       L_main11
	NOP
;Slave_2_Devices.c,112 :: 		PORTB.RB0 =1;                       //trigger Relay1 on, LED on
	BSF        PORTB+0, 0
;Slave_2_Devices.c,113 :: 		PORTB.RB4 =1;
	BSF        PORTB+0, 4
;Slave_2_Devices.c,114 :: 		PORTB.RB5 =1;
	BSF        PORTB+0, 5
;Slave_2_Devices.c,115 :: 		Delay_ms(500);
	MOVLW      13
	MOVWF      R11+0
	MOVLW      175
	MOVWF      R12+0
	MOVLW      182
	MOVWF      R13+0
L_main12:
	DECFSZ     R13+0, 1
	GOTO       L_main12
	DECFSZ     R12+0, 1
	GOTO       L_main12
	DECFSZ     R11+0, 1
	GOTO       L_main12
	NOP
;Slave_2_Devices.c,116 :: 		PORTB.RB0 =0;                       //trigger Relay1 off, LED off
	BCF        PORTB+0, 0
;Slave_2_Devices.c,117 :: 		PORTB.RB4 =0;
	BCF        PORTB+0, 4
;Slave_2_Devices.c,118 :: 		PORTB.RB5 =0;
	BCF        PORTB+0, 5
;Slave_2_Devices.c,119 :: 		while(1)
L_main13:
;Slave_2_Devices.c,122 :: 		if(flagReceivedAllData==1){
	MOVF       _flagReceivedAllData+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main15
;Slave_2_Devices.c,123 :: 		flagReceivedAllData = 0;                                   //after begin function, set flag back to 0 to continue receiving data
	CLRF       _flagReceivedAllData+0
;Slave_2_Devices.c,150 :: 		if(receiveData[1] == '1' && receiveData[2] == '0' && receiveData[3] == 'D'){
	MOVF       _receiveData+1, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_main18
	MOVF       _receiveData+2, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main18
	MOVF       _receiveData+3, 0
	XORLW      68
	BTFSS      STATUS+0, 2
	GOTO       L_main18
L__main44:
;Slave_2_Devices.c,151 :: 		if(receiveData[4] == addressDevice1[0] && receiveData[5] == addressDevice1[1]){  //receiveData[4]=0 && receiveData[5]=1 => device 01
	MOVF       _receiveData+4, 0
	XORWF      _addressDevice1+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main21
	MOVF       _receiveData+5, 0
	XORWF      _addressDevice1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main21
L__main43:
;Slave_2_Devices.c,152 :: 		if(receiveData[9] == '1'){                                                   //receiveData[9]=1 => ON command
	MOVF       _receiveData+9, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_main22
;Slave_2_Devices.c,153 :: 		PORTB.RB0 =1;                                                            //trigger On pin RB0=> Relay1
	BSF        PORTB+0, 0
;Slave_2_Devices.c,154 :: 		}
L_main22:
;Slave_2_Devices.c,155 :: 		if(receiveData[9] == '0'){
	MOVF       _receiveData+9, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main23
;Slave_2_Devices.c,156 :: 		PORTB.RB0 =0;
	BCF        PORTB+0, 0
;Slave_2_Devices.c,157 :: 		}
L_main23:
;Slave_2_Devices.c,158 :: 		}
L_main21:
;Slave_2_Devices.c,159 :: 		if(receiveData[4] == addressDevice2[0] && receiveData[5] == addressDevice2[1]){   //receiveData[4]=0 && receiveData[5]=2
	MOVF       _receiveData+4, 0
	XORWF      _addressDevice2+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main26
	MOVF       _receiveData+5, 0
	XORWF      _addressDevice2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main26
L__main42:
;Slave_2_Devices.c,160 :: 		if(receiveData[9] == '1'){                                                    //device 02
	MOVF       _receiveData+9, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_main27
;Slave_2_Devices.c,161 :: 		PORTB.RB4 =1;                                                             //turn On Relay2
	BSF        PORTB+0, 4
;Slave_2_Devices.c,162 :: 		}
L_main27:
;Slave_2_Devices.c,163 :: 		if(receiveData[9] == '0'){
	MOVF       _receiveData+9, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main28
;Slave_2_Devices.c,164 :: 		PORTB.RB4 =0;
	BCF        PORTB+0, 4
;Slave_2_Devices.c,165 :: 		}
L_main28:
;Slave_2_Devices.c,166 :: 		}
L_main26:
;Slave_2_Devices.c,167 :: 		if(receiveData[4] == addressDevice3[0] && receiveData[5] == addressDevice3[1]){
	MOVF       _receiveData+4, 0
	XORWF      _addressDevice3+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main31
	MOVF       _receiveData+5, 0
	XORWF      _addressDevice3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main31
L__main41:
;Slave_2_Devices.c,168 :: 		if(receiveData[9] == '1'){
	MOVF       _receiveData+9, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_main32
;Slave_2_Devices.c,169 :: 		PORTB.RB5 =1;
	BSF        PORTB+0, 5
;Slave_2_Devices.c,170 :: 		}
L_main32:
;Slave_2_Devices.c,171 :: 		if(receiveData[9] == '0'){
	MOVF       _receiveData+9, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main33
;Slave_2_Devices.c,172 :: 		PORTB.RB5 =0;
	BCF        PORTB+0, 5
;Slave_2_Devices.c,173 :: 		}
L_main33:
;Slave_2_Devices.c,174 :: 		}
L_main31:
;Slave_2_Devices.c,175 :: 		}
L_main18:
;Slave_2_Devices.c,176 :: 		}
L_main15:
;Slave_2_Devices.c,178 :: 		}
	GOTO       L_main13
;Slave_2_Devices.c,179 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_RS485_send:

;Slave_2_Devices.c,183 :: 		void RS485_send (char dat[])
;Slave_2_Devices.c,186 :: 		PORTB.RB3 =1;                 //bit RS485 on, transmitting
	BSF        PORTB+0, 3
;Slave_2_Devices.c,187 :: 		for (i=0; i<=10;i++){
	CLRF       RS485_send_i_L0+0
	CLRF       RS485_send_i_L0+1
L_RS485_send34:
	MOVLW      128
	MOVWF      R0+0
	MOVLW      128
	XORWF      RS485_send_i_L0+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__RS485_send49
	MOVF       RS485_send_i_L0+0, 0
	SUBLW      10
L__RS485_send49:
	BTFSS      STATUS+0, 0
	GOTO       L_RS485_send35
;Slave_2_Devices.c,188 :: 		while(UART1_Tx_Idle()==0);    //while data has NOT been transmitted
L_RS485_send37:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_RS485_send38
	GOTO       L_RS485_send37
L_RS485_send38:
;Slave_2_Devices.c,189 :: 		UART1_Write(dat[i]);          //transmit a byte with index i in loop for
	MOVF       RS485_send_i_L0+0, 0
	ADDWF      FARG_RS485_send_dat+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;Slave_2_Devices.c,187 :: 		for (i=0; i<=10;i++){
	INCF       RS485_send_i_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       RS485_send_i_L0+1, 1
;Slave_2_Devices.c,190 :: 		}
	GOTO       L_RS485_send34
L_RS485_send35:
;Slave_2_Devices.c,191 :: 		Delay_ms(100);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_RS485_send39:
	DECFSZ     R13+0, 1
	GOTO       L_RS485_send39
	DECFSZ     R12+0, 1
	GOTO       L_RS485_send39
	DECFSZ     R11+0, 1
	GOTO       L_RS485_send39
	NOP
	NOP
;Slave_2_Devices.c,192 :: 		PORTB.RB3 =0;                 //bit RS485 into idle state
	BCF        PORTB+0, 3
;Slave_2_Devices.c,193 :: 		}
L_end_RS485_send:
	RETURN
; end of _RS485_send
