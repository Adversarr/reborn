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

	s1 = 0; loop0: // for s1 = 0, ..., 11
		s0 = 0x02FAF080; loop_sleep0: // for s0 = 0x02FAF080, ..., 1
			// pass
			s0 = s0 - 1;
			if (s0 != 0) goto loop_sleep0;

		s2 = 0x00000FFF;
		s3 = 0x00FFF000;
		t1 = 12 - s1;
		s4 = s2 >> t1;
		s5 = s3 << t1;
		s6 = s4 ^ s5;
		s6 = s6 ^ 0;
		printf("$s1: %d\n", s1);
		printf("$s4: "); print_bin(s4);
		printf("$s5: "); print_bin(s5);
		printf("$s6: "); print_bin(s6);
		printf("\n");

		s1 = s1 + 1;
		if (s1 < 12) goto loop0;

	s1 = 0; loop1: // for s1 = 0, ..., 11
		s0 = 0x02FAF080; loop_sleep2: // for s0 = 0x02FAF080, ..., 1
			// pass
			s0 = s0 - 1;
			if (s0 != 0) goto loop_sleep2;
		s2 = 0x00000FFF;
		s3 = 0x00FFF000;
		s4 = s2 >> s1;
		s5 = s3 << s1;
		s6 = s4 | s5;
		printf("$s1: %d\n", s1);
		printf("$s4: "); print_bin(s4);
		printf("$s5: "); print_bin(s5);
		printf("$s6: "); print_bin(s6);
		printf("\n");

		s1 = s1 + 1;
	if (s1 < 12) goto loop1;

	return 0;
}