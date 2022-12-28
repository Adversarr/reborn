// time: minisecond
void delay(int time) {
    int i; 
    int pivot;

    pivot = time * 20000; /* inst per ms */
    i = 0;
    while (i < pivot) {
        i = i + 1;
    }
}

int main(void) {
    int i;
    int left;
    int right;
    int l;
    int r;
    int offset;
    int temp;

    left = 0x00000FFF;
    right = 0x00FFF000;
    int* led_addr = 0xFFFF;
    led_addr = (led_addr << 16) + 0xFC60;
    *led_addr = 1;


    while (1) {
        i = 0;
        while (i < 24) {
            offset = 12 - i;
            if (offset < 0) {
                offset = -offset;
            }
            offset = 12 - offset;

            l = left >> offset;
            r = right << offset;
            temp = l ^ r;
            temp = temp ^ 0;

            $(0xFFFFFC60) = temp & 0x0000FFFF;
            $(0xFFFFFC64) = (temp >> 16) & 0x0000FFFF;

            delay(1000);

            i = i + 1;
        }
    }

    return 0;
}