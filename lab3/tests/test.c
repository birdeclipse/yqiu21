
long int test_loop(long int a , long int b){
	long int i  = 	0;
	long int result	=	0;

	a++;
	b++;

	for (i=0; i<16;i++){
		result += a;
		result += b;
		a = a<<1;
		b = b<<1;
	}
	a= (a>>6);
	b= (b>>7);
	for (i=0;i<8;i++){
		result -= a;
		result -= b;
		a = a>>1;
		b = b>>1;
	}

	return result;
}
