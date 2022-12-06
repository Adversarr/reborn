
int main() {

start:
	uint32_t t0, t1, t2, t3, t4, t5, t6, t7;
	uint32_t s0, s1, s2, s3, s4, s5, s6, s7;

test_add:
	t0 = -6; // addi
	t1 = 5;
	t2 = 4; 
	t3 = t0 + t1; // add:  -1, overflow exception
	t4 = t0 + t1; // addu: -1
	t5 = t2 - t1; // sub:  -1, overflow exception
	t6 = t2 - t1; // subu: -1

test_bitwise:
	t0 = 3; // b'0011
	t1 = 6; // b'0110
	t2 = -5;
	t3 = t0 & t1;	// and: 2 (b'0010)
	t4 = t0 | t1;   // or:  7 (b'0111)
	t5 = t0 ^ t1;   // xor: 5 (b'0101)
	t6 = ~(t0 | t1) // nor: -8 (b'1111...1000)
	t7 = (t0 < t1); // slt: 1
	s0 = (t1 < t2); // slt: 0
	s1 = (t0 < t1); // sltu: 1
	s2 = (t1 < t2); // sltu: 1

test_shift:
	t0 = 2; // b'0010
	t1 = 5; // b'0101
	t2 = -6; // b'1111...1010
	t3 = t1 << 2;  // sll: 20  (b'0001_0100)
	t4 = t1 >> 2;  // srl: 1   (b'0000_0001)
	t5 = t2 >> 2;  // srl: 1   (b'0000_0001)
	t6 = t1 >> 2;  // sra: 1   (b'0000...0001)
	t7 = t2 >> 2;  // sra: -2  (b'1111...1110)
	s0 = t1 << t0; // sllv: 20 (b'0001_0100)
	s1 = t1 >> t0; // srlv: 1  (b'0000_0001)
	s2 = t2 >> t0; // srlv: 1  (b'0000_0001)
	s3 = t1 >> t0; // srav: 1  (b'0000...0001)
	s4 = t2 >> t0; // srav: -2 (b'1111...1110)

test_j
	goto test_add_i;

test_failed:
	goto test_failed; // j test_failed

test_success:
	t0 = 0x12345678;
	goto test_success;

test_add_i:
	t0 = -6; // addi
	t1 = 5;
	t2 = 4; 
	t3 = t0 + 5; // addi:  -1, overflow exception
	t4 = t0 + 5; // addiu: -1
	t3 = t0 + 0x8000; // addi: -4198, overflow exception
	t4 = t0 + 0x8000; // addiu: -4198

test_bitwise_i:
	t0 = 3; // b'0011
	t1 = 6; // b'0110
	t2 = -5;
	t3 = t0 & 6;   	// addi: 2 (b'0010)
	t4 = t0 | 6;   	// ori:  7 (b'0111)
	t5 = t0 ^ 6;   	// xori: 5 (b'0101)

test_lui:
	t0 = 0x1234;
	t0 = 0x1234 << 16;	// lui: 0x12340000

test_lw:
	// addi		$t0, $0, 1234
	// sw      $t0, 0xFC50 ($0) // load DIP_switch
	// addi		$t0, $0, 0
	// lw      $t0, 0xFC60 ($0) // save LED
	// addi		$t0, $0, 4567
	// lw      $t0, 0x1234 ($0) // load 
	// addi		$t0, $0, 0
	// sw      $t0, 0x1234 ($0) // save

test_beq:
	t0 = 1;
	t1 = 1;
	t2 = 2;
	if (t0 == t2) goto test_failed	// beq: ignore
	if (t0 == t1) goto test_bne		// beq: goto test_bne
	goto test_failed

test_bne:
	if (t0 != t1) goto test_failed	// bne: ignore
	if (t0 != t2) goto test_slti	// bne: test_slti
		goto test_failed

test_slti:
	t0 = 2;
	t1 = 2;
	t2 = -2;
	s1 = !!(t1 < 3) 	// slti:  1
	s1 = !!(t2 < -3) 	// slti:  0
	s1 = !!(t0 < 1) 	// sltui: 0
	s1 = !!(t0 < -3) 	// sltui: 1

test_jal:
	s0 = 0
	call test_jr; // jal test_jr
	t0 = 0xf1a9
	if (t0 != s0) goto test_failed // bne
	goto test_success

test_jr:
	s0 = 0xf1a9;
	return; // jr
	goto test_failed;
}