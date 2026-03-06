all: selfie

HOSTCC ?= cc

selfie: selfie.0 ../files/selfie$(XLEN).c
	./selfie.0 -c ../files/selfie$(XLEN).c -o selfie

selfie.0: ../files/selfie$(XLEN).c
	$(HOSTCC) -D"uint64_t = unsigned long" ../files/selfie$(XLEN).c -o selfie.0

clean:
	rm -f selfie selfie.0
