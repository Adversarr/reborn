#include <stdio.h>
#include <stdint.h>

void print_bin(uint32_t n) {
    int i;
    for(i=sizeof(n)*8-1; i>=0; i --)
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

int main() {
	uint32_t t0, t1, t2, t3, t4, t5, t6, t7;
	uint32_t s0, s1, s2, s3, s4, s5, s6, s7;

	s1 = 7;
	s2 = 6;
	printf("$s1 = %d\n", s1);
	printf("$s2 = %d\n", s2);

	// s0[0:7] <- s1[0:3] x s2[0:3]
	s0 = 0;
	t2 = s1 & 1;
	if (t2 == 0) goto skip1;
		s0 = s0 + s2;
	skip1:
	s1 = s1 >> 1;
	t2 = s1 & 1;
	if (t2 == 0) goto skip2;
	    s2 = s2 << 1;
	    s0 = s0 + s2;
	skip2:
	s1 = s1 >> 1;
	t2 = s1 & 1;
	if (t2 == 0) goto skip3;
	    s2 = s2 << 1;
	    s0 = s0 + s2;
	skip3:
	s1 = s1 >> 1;
	t2 = s1 & 1;
	if (t2 == 0) goto skip4;
	    s2 = s2 << 1;
	    s0 = s0 + s2;
	skip4:


	printf("$s0 = %d\n", s0);



	return 0;
}