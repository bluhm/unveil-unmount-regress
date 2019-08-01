# $OpenBSD$

# Call unveil(2) in combination with unlink(2), chroot(2), chdir(2).
# Use unmount to check that the mountpoint leaks no vnode.
# There were vnode reference counting bugs in the kernel.

PROGS=		unveil-unlink unveil-chroot unveil-perm unveil-chdir
CLEANFILES=	diskimage

.PHONY: mount unconfig clean

diskimage: unconfig
	dd if=/dev/zero of=diskimage bs=512 count=4k
	vnconfig vnd0 diskimage
	newfs vnd0c

mount: diskimage
	@echo '\n======== $@ ========'
	mkdir -p /mnt/regress-unveil
	mount /dev/vnd0c /mnt/regress-unveil

unconfig:
	@echo '\n======== $@ ========'
	-umount -f /dev/vnd0c 2>/dev/null || true
	-rmdir /mnt/regress-unveil 2>/dev/null || true
	-vnconfig -u vnd0 2>/dev/null || true
	-rm -f stamp-setup

REGRESS_SETUP	=	${PROGS} mount
REGRESS_CLEANUP =	unconfig
REGRESS_TARGETS =

REGRESS_TARGETS +=	run-unlink
run-unlink:
	@echo '\n======== $@ ========'
	# unlink a file in an unveiled directory
	mkdir -p /mnt/regress-unveil/foo
	./unveil-unlink /mnt/regress-unveil/foo bar
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot
run-chroot:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil
	./unveil-chroot /mnt/regress-unveil /
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir
run-chroot-dir:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil/foo
	./unveil-chroot /mnt/regress-unveil/foo /
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-unveil-dir
run-chroot-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil/foo
	./unveil-chroot /mnt/regress-unveil /foo
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir-unveil-dir
run-chroot-dir-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil/foo/bar
	./unveil-chroot /mnt/regress-unveil/foo /bar
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-open
run-chroot-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil
	touch /mnt/regress-unveil/baz
	./unveil-chroot /mnt/regress-unveil / /baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir-open
run-chroot-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil/foo
	touch /mnt/regress-unveil/foo/baz
	./unveil-chroot /mnt/regress-unveil/foo / /baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-unveil-dir-open
run-chroot-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil/foo
	touch /mnt/regress-unveil/foo/baz
	./unveil-chroot /mnt/regress-unveil /foo /baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chroot-dir-unveil-dir-open
run-chroot-dir-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chroot environment
	mkdir -p /mnt/regress-unveil/foo/bar
	touch /mnt/regress-unveil/foo/bar/baz
	./unveil-chroot /mnt/regress-unveil/foo /bar /baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm
run-perm:
	@echo '\n======== $@ ========'
	# unveil in a perm environment
	mkdir -p /mnt/regress-unveil
	./unveil-perm "" /mnt/regress-unveil
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir
run-perm-dir:
	@echo '\n======== $@ ========'
	# unveil with permission
	mkdir -p /mnt/regress-unveil/foo
	./unveil-perm "" /mnt/regress-unveil/foo
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-open
run-perm-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	mkdir -p /mnt/regress-unveil
	touch /mnt/regress-unveil/baz
	./unveil-perm "" /mnt/regress-unveil baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir-open
run-perm-dir-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	mkdir -p /mnt/regress-unveil/foo
	touch /mnt/regress-unveil/foo/baz
	./unveil-perm "" /mnt/regress-unveil/foo baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-create-open
run-perm-create-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	mkdir -p /mnt/regress-unveil
	touch /mnt/regress-unveil/baz
	./unveil-perm "c" /mnt/regress-unveil baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir-create-open
run-perm-dir-create-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	mkdir -p /mnt/regress-unveil/foo
	touch /mnt/regress-unveil/foo/baz
	./unveil-perm "c" /mnt/regress-unveil/foo baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-write-open
run-perm-write-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	mkdir -p /mnt/regress-unveil
	touch /mnt/regress-unveil/baz
	./unveil-perm "w" /mnt/regress-unveil baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-perm-dir-write-open
run-perm-dir-write-open:
	@echo '\n======== $@ ========'
	# unveil with permission
	mkdir -p /mnt/regress-unveil/foo
	touch /mnt/regress-unveil/foo/baz
	./unveil-perm "w" /mnt/regress-unveil/foo baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir
run-chdir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil
	./unveil-chdir /mnt/regress-unveil .
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir
run-chdir-dir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil/foo
	./unveil-chdir /mnt/regress-unveil/foo .
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-unveil-dir
run-chdir-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil/foo
	./unveil-chdir /mnt/regress-unveil foo
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir-unveil-dir
run-chdir-dir-unveil-dir:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil/foo/bar
	./unveil-chdir /mnt/regress-unveil/foo bar
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-open
run-chdir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil
	touch /mnt/regress-unveil/baz
	./unveil-chdir /mnt/regress-unveil . baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir-open
run-chdir-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil/foo
	touch /mnt/regress-unveil/foo/baz
	./unveil-chdir /mnt/regress-unveil/foo  baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-unveil-dir-open
run-chdir-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil/foo
	touch /mnt/regress-unveil/foo/baz
	./unveil-chdir /mnt/regress-unveil foo baz
	umount /mnt/regress-unveil

REGRESS_TARGETS +=	run-chdir-dir-unveil-dir-open
run-chdir-dir-unveil-dir-open:
	@echo '\n======== $@ ========'
	# unveil in a chdir environment
	mkdir -p /mnt/regress-unveil/foo/bar
	touch /mnt/regress-unveil/foo/bar/baz
	./unveil-chdir /mnt/regress-unveil/foo bar baz
	umount /mnt/regress-unveil

.include <bsd.regress.mk>
