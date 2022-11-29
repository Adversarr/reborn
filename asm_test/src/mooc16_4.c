#include <stdio.h>
#include <stdint.h>

// SW23/SW22/SW21为功能选择，含义如下表：
// SW23    SW22    SW21    动作 
// X       0       0       无动作 
// 0       0       1       将SW15~SW0这16位作为输入赋值给VAL 
// 0       1       0       VAL=VAL+1 （每隔约1秒动作一次） 
// 0       1       1       VAL=VAL-1（每隔约1秒动作一次） 
// 1       0       1       VAL左移1位（每隔约1秒动作一次） 
// 1       1       0       VAL逻辑右移1位（每隔约1秒动作一次） 
// 1       1       1       VAL算术右移1位（每隔约1秒动作一次）   

void scan_bin(uint32_t *n) {
	char src[128];
 	scanf("%s", src);
 	*n = 0;
    for (int i=sizeof(*n)*8-1, j = 0; i >= 0; j++)
    {
    	char c = src[j];
    	if (c != '1' && c != '0') 
    		continue;
    	uint32_t bit = c != '0';
        *n = *n | (bit << i);
        i--;
    }
}

void print_bin_(uint32_t n, int high, int low) {
    int i;
    for(i=high; i>=low; i --)
    {
        if (n & (1 << i))
        	printf("1");
        else
        	printf("0");
        if (i % 4 == 0 && i != 0)
        	printf("_");
    }
    printf("\n");
}

void print_bin(uint32_t n) {
	print_bin_(n, 31, 0);
}

int main() {
	uint32_t t0, t1, t2, t3, t4, t5, t6, t7;
	uint32_t s0, s1, s2, s3, s4, s5, s6, s7;


	// s0 <- VAL
	// s1[23:0] <- SW[23:0]
start:
	s0 = 0; action:
		t0 = 0x0000FFFF;
		s0 = t0 & s0;

		printf("VAL[15:0]: ");
		print_bin_(s0, 15, 0);

		// slepp 1 second
		t0 =  1000000; loop_sleep:
			t0 = t0 - 1;
			if (t0 != 0) goto loop_sleep;

		// s1[23:0] <- SW[23:0]
		printf("input SW: ");
		scan_bin(&s1);
		t0 = s1 >> 21;
		t0 = t0 & 7;

		printf("SW[23:21]: ");
		print_bin_(s1, 23, 21);

		if (t0 == 0) goto case0;
		if (t0 == 1) goto case1;
		if (t0 == 2) goto case2;
		if (t0 == 3) goto case3;
		if (t0 == 4) goto case4;
		if (t0 == 5) goto case5;
		if (t0 == 6) goto case6;
		if (t0 == 7) goto case7;

		case0:
		case4:
			goto action;
		case1:
			printf("SW[15:0]: ");
			print_bin_(s1, 15, 0);
			s0 = s1;
			goto action;
		case2:
			s0 = s0 + 1;
			goto action;
		case3:
			s0 = s0 - 1;
			goto action;
		case5:
			s0 = s0 << 1;
			goto action;
		case6:
			s0 = s0 >> 1;
			goto action;
		case7:
			t0 = s0 & 0x00008000;
			s0 = s0 >> 1;
			s0 = s0 | t0;
			goto action;


	return 0;
}