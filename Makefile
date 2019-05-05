.DEFAULT_GOAL := default

qemu = compiled/qemu-system-riscv64

contain := \
	mkdir -p compiled && \
	docker run -it  \
		-v $(PWD)/compiled:/home/build/compiled \
		riscv

default: build

qemu: qemubuild
	$(qemu) -nographic -machine virt -kernel compiled/bbl \
		-drive file=compiled/rootfs.bin,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 \
		-netdev user,id=net0 -device virtio-net-device,netdev=net0


qemubuild:
	docker build -t riscv .
	@$(contain) bash -c "make qemulite -j8 &&  bash /home/build/freedom-u-sdk/install.sh"


build:
	@$(contain) make all -j8


.PHONY:  build qemubuild


